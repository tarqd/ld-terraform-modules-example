

  variable "base_template" {
    type = object({
      key_prefix = list(string)
      additional_tags = set(string)
      temporary = bool
      client_side = bool
      kind = string
      maintainer_id = string
      variations = list(object({
        name = string
        value = any
         description = string
        }))
    })
    default = {
      key_prefix = null
      additional_tags = []
      temporary = null
      client_side = null
      kind = null
      maintainer_id = null
      variations = null
    }
  }

  variable "key_prefix" {
    type = any
    default = null
  }

  variable "additional_tags" {
    type = set(string)
    default = null
  }

  variable "temporary" {
    type = bool
    default = null
  }

  variable "client_side" {
    type = bool 
    default = null
  }

  variable "kind" {
    type = string
    default = null
  }

  variable "maintainer_id" {
    type = string
    default = null
  }

variable "variations" {
  type = list(object({
    name = string
    value = any
    description = string
  }))
  default = null
}

output "template" {
  value = {
    key_prefix = var.key_prefix == null ? var.base_template.key_prefix : compact(flatten([var.key_prefix]))
    additional_tags = setunion(var.base_template.additional_tags, coalesce(var.additional_tags, toset([])))
    temporary = try(coalesce(var.temporary, var.base_template.temporary), null)
    client_side = try(coalesce(var.client_side, var.base_template.client_side), null)
    kind = try(coalesce(var.kind, var.base_template.kind), null)
    maintainer_id = try(coalesce(var.maintainer_id, var.base_template.maintainer_id), null)
    variations = try(coalesce(var.variations, var.base_template.variations), null)
  }
}