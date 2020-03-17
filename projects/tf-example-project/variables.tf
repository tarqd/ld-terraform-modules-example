# allow adding or overriding templates

# map of specified roles to maintainer emails
# enforces that it is completely filled out with the object type
# you could also use a map for weaker guarantees
variable "maintainers" {
  type = object({
    default = string
    mobile = string
  })
  description = "Maps roles to a maintainer email"
}

variable "templates" {
  type = map(object({
      key_prefix = string
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
    }))
  default = {}
  description = "Overrides and adds flag templates for use in flag creation. Templates can be created with the root-level template module"
}
