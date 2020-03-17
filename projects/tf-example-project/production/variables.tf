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
variable "project_key" {
  type = string
}
variable "env_key" {
  type = string
}