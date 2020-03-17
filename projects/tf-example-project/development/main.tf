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
resource launchdarkly_feature_flag_environment "simple_killswitch" {
  flag_id = local.flags.simple_killswitch.id
  env_key = local.env

  targeting_enabled = false
  flag_fallthrough {
    variation = local.flags.simple_killswitch.var.by_slug.kill_feature
  }
  off_variation = local.flags.simple_killswitch.var.by_slug.allow_feature
  
  lifecycle {
    # allow the UI to modify targeting on/off without terraform trampling it
    ignore_changes = [ targeting_enabled ]
  }
}

resource launchdarkly_feature_flag_environment "simple" {
  flag_id = local.flags.simple.id
  env_key = local.env

  targeting_enabled = true
  prerequisites {
    flag_key = local.flags.simple_killswitch.key
    variation = local.flags.simple_killswitch.var.by_slug.allow_feature
  }
  rules {
    clauses {
      attribute = "segmentMatch"
      op        = "segmentMatch"
      values    = [launchdarkly_segment.example.key]
      negate    = false
    }
    variation = local.flags.simple.var.by_value.false

  }

  flag_fallthrough {
    variation = local.flags.simple.var.by_value.true
  }

  off_variation = local.flags.simple.var.by_value.false

}
