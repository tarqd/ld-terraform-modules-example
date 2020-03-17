# Example of a simple project



# project module outputs information about the project and envs
# use project modules to create templates or add buisiness specific logic such as
# configuring pagerduty, webhooks and a base of custom roles
# this example one just creates a set of standard environments and tags
module "project" {
  source = "../../modules/project"
  key = "my-application"
  additional_environments = {
    # the reason for making this a key/value pair instead of a list is to prevent re-ordering
    # from destroying existing environments
    # you can pass null as the key and it will use the key in additional_environments as the LD key
    development = {
      key = "development"
      name = "Development"
      description = "Environment for developers"
      color = "0000ff"
      additional_tags = [ "some-extra-tags-here" ]
      require_comments = false
      confirm_changes = false
    }
  }
}


# see flags.tf for flag creation

# prepare flags for use with rules by augmenting them with helpers
# and additional context

module "development_rules" {
  source = "./development"
  # you can combine module-created flags with resource-created flags with merge
  # only required if you don't always use the module
  # other you can do:
  # flags = module.<instance of flag module >.flags
  flags = module.flags.flags
  project_key = module.project.key
  env_key = module.project.environments.development.key
}






