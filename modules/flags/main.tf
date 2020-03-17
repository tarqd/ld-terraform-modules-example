variable "project_key" {
  type = string
  description = "Project key for all created flags"
}

variable "tags" {
  type = set(string)
  default = [ "terraform" ]
  description = "Tags that will be set for all created flags"
}

variable "additional_tags" {
  type = set(string)
  default = []
  description = "Additional tags that will be merged with the value of tags"
}

variable "maintainer_id" {
  type = string
  default = null
  description = "Default maintainer id for created flags"
}

variable "flags" {
  type = any
  description = "Map of flag resource names => flag properties."
}

output "flags" {
  value = launchdarkly_feature_flag.flags
}

locals {
  # hack around terraforms type system
  # here you can define the types for the flags input
  variations_for = {
    for key, value in var.flags:
      key =>  try(
         # if it's a list of a single type, turn it into an object
        [
        for value in tolist(
          # if it's a boolean flag and variations is null, use defaults
          (lookup(value, "variations", null) == null && value.kind == "boolean") 
            ? [true, false] 
            : tolist(value.variations)
        ):
        {
          value: value,
          name: null,
          description: null
        }
      ],
      # if it's a map or object, set the missing keys to null
      [ 
        for variation in value.variations:
          {
            value: variation.value,
            name: lookup(variation, "name", null)
            description: lookup(variation, "description", null)
          }
      ],
        value.template.variations 
      )
      
  }
}


resource launchdarkly_feature_flag "flags" {
  for_each = var.flags
  project_key = var.project_key
  # combine key prefix and key
  key = join("-", concat(
      lookup(each.value, "key_prefix", null) != null 
      ? compact(flatten([each.value.key_prefix])) 
      : [],
      # if a key is not specified in flag.props, use the key from the list
      # but change terraform_style to launchdarkly-style
      [
        coalesce(lookup(each.value, "key", null), lower(replace(each.key, "_", "-")))
          
      ]
  ))
  # generate a name if one is not provided
  name = try(
    each.value.name,
    title(join(" ", compact(split("-", each.key))))
  )

  description = try(
    each.value.description,
    each.value.template.description,
    null
  )

  # combine base tags + additional_tags + props.additional_tags
  tags = setunion(
      try(
        toset(each.value.tags),
        toset(each.value.template.tags),
        toset(var.tags)
      ),
      lookup(each.value, "additional_tags", []),
      lookup(try(each.value.template,{}), "additional_tags", []),
      var.additional_tags
  )

  include_in_snippet = try(
    each.value.client_side,
    each.value.template.client_side,
    null
  )


  temporary = try(
    each.value.temporary,
    each.value.template.temporary,
    null
  )

  variation_type = try(
    each.value.kind,
    each.value.template.kind,
    null
  )


  dynamic "variations" {
    for_each = local.variations_for[each.key]
    content {
      value = lookup(variations.value, "value")
      name = lookup(variations.value, "name", null)
      description = lookup(variations.value, "description", null)

    }
  }

}



