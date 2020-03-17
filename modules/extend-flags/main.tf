# takes a map of feature flags and returns a map of helpers

# alias => flag 
variable "flags" {
  type = map(object({
      id = string
      key = string
      name = string
      tags = set(string)
      include_in_snippet = bool
      variation_type = string
      # ideally this would be an object 
      # but terraform complains if the resource didn't have name/description defined
      variations = list(map(any))
  }))
}

# defined as a local 
# if you add other extensions you can reference the extended versions
# using local.flags
locals {
  flags = {
    for k, v in var.flags: 
      k => {
        id = v.id
        key = v.key
        name = v.name
        kind = v.variation_type
        variation_type = v.variation_type
        client_side = v.include_in_snippet
        include_in_snippet = v.include_in_snippet
        tags = v.tags
        # could be used for lookup 
        # example:
        # values(flags)[*]
        slug = try(lower(replace(replace(v.key, "/[\\s-_]+/", "_"), "/[^\\w_]+/", "")), null)
        variations = v.variations
        # variation lookup helpers, maybe could use a better name
        var = { 
          by_name = {
            for k, v in v.variations:
              try(coalesce(v.name, title(v.value)), null) => k 
          }
          by_value = {
            for k, v in v.variations:
              try(tostring(v.value), null) => k if try(tostring(v.value), null) != null
          }
          by_slug =  {
              for k, v in v.variations:
                try(lower(replace(replace(coalesce(v.name, tostring(v.value)), "/[\\s-_]+/", "_"), "/[^\\w_]+/", "")), null) => k
                if try(lower(replace(replace(coalesce(v.name, tostring(v.value)), "/[\\s-_]+/", "_"), "/[^\\w_]+/", "")), null) != null
          }
        }
      }
  }
}

# same as input but with extra aliases
# you may add extra information here if you wish
output "flags" {
  value = local.flags
}

