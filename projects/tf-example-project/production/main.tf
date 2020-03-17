# flags wrapped with helpers for writing rules
module "extended_flags" {
  source = "../../../modules/extend-flags"
  flags = var.flags
}

# just to make typing easier
locals {
  flags = module.extended_flags.flags
  env = var.env_key
  project = var.project_key
}

# create segments 
resource launchdarkly_segment "example" {
  key = "example"
  project_key = local.project
  env_key = local.env
  name = "Example Segment"
  tags = [ "terraform" ]
}

# create rules
resource launchdarkly_feature_flag_environment "simple" {
  flag_id = flags.simple.id
  env = local.env

  targeting_enabled = true

  flag_fallthrough {
    variation = local.flags.simple.var.by_value.true
  }

  off_variation {
    variation = local.flags.simple.var.by_value.false
  }

}
