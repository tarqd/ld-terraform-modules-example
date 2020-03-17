
variable "default_environment_tags" {
  type = set(string)
  default = ["terraform"]
}

variable "tags" {
  type = set(string)
  default = [ "terraform" ]
}

variable "name" {
  type = string
  default = null
}

variable "key" {
  type = string
}

variable "additional_tags" {
  type = set(string)
  default = []
}



# these environments are created when the project is first created
# but then changes are ignored
# we need to do this due to some weirdness with how the terraform handles 
# the default environments that can cause you to accidentally recreate the project
#  treat this as a playground/test env
variable "initial_environments" {
  type = list(object({
    key = string
    name = string
    description = string
    require_comments = bool
    confirm_changes = bool
    additional_tags = set(string)
    color = string
  }))

  default = [{
      key = "test",
      name = "Test"
      color = "f5a623",
      description = "Test Environment - Created but not managed by terraform."
      additional_tags = null,
      # null allows override from ui
      require_comments = null,
      confirm_changes = null
    }
  ]
}


variable "environments" {
  type = map(object({
    name = string
    description = string
    require_comments = bool
    confirm_changes = bool
    additional_tags = set(string)
    color = string
  }))

  default = {
    production = {
      name = "Production",
      description = null,
      color = "417505",
      additional_tags = null
      require_comments = true,
      confirm_changes = true
    }
    staging = {
      name = "Staging"
      color = "f5a623",
      description = null,
      additional_tags = null,
      # null allows override from ui
      require_comments = null,
      confirm_changes = null
    }
  }
}

# environments to add in addition to "environments"
variable "additional_environments" {
  type = map(object({
    name = string
    description = string
    require_comments = bool
    confirm_changes = bool
    additional_tags = set(string)
    color = string
  }))
  default = null
}


# some pre-processing
locals {
  project_name = var.name != null ? var.name : title(replace(var.key, "/-/", " "))
  initial_environments = [
     for k, v in var.initial_environments : {
       # use key from env map if one is not set
       # camelCase/Title Case to kebab-case
       key = v.key
       # turn key into name if one isn't provided
       name = coalesce(v.name, title(replace(v.key, "-", " ")))
       tags = setunion(var.default_environment_tags, coalesce(v.additional_tags, toset([])))
       require_comments = v.require_comments
       confirm_changes = v.confirm_changes
       color = v.color
     }
  ]

  environments = {
     for k, v in merge(var.environments, coalesce(var.additional_environments, {})) : k => {
       # use key from env map if one is not set
       # snake_case to kebab-case
       key = lower(replace(replace(k, "/_|\\s+/", "-"), "/[^\\w-_]+/", ""))
       # turn key into name if one isn't provided
       # a little gross because we need to repeat ourselves
       # kebab-case to Title Case
       name = coalesce(v.name, title(replace(lower(replace(replace(k, "/_|\\s+/", "-"), "/[^\\w-_]+/", "")), "-", " ")))
       tags = setunion(var.default_environment_tags, coalesce(v.additional_tags, toset([])))
       require_comments = v.require_comments
       confirm_changes = v.confirm_changes
       color = v.color
     }
   }


}

resource "launchdarkly_project" "project" {
  key = var.key
  name = local.project_name
  tags = setunion(var.tags, var.additional_tags)
  dynamic "environments" {
    for_each = local.initial_environments
    content {
      key = environments.value.key
      name = environments.value.name
      tags = environments.value.tags
      require_comments = environments.value.require_comments
      confirm_changes = environments.value.confirm_changes
      color = environments.value.color
    }
  }

  lifecycle {
    ignore_changes = [
      environments
    ]
  }
}

resource "launchdarkly_environment" "environments" {
  for_each = local.environments
  project_key = launchdarkly_project.project.key
  key = each.value.key
  name = each.value.name
  tags = each.value.tags
  require_comments = each.value.require_comments
  confirm_changes = each.value.confirm_changes
  color = each.value.color
}


output "project" {
  value = launchdarkly_project.project
}
output "environments" {
  value = launchdarkly_environment.environments
}

output "key" {
  value = launchdarkly_project.project.key
}
