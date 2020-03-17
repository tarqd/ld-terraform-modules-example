module "flags" {
  source = "../../modules/flags"
  project_key = module.project.key
  flags = {
    simple = {
      kind = "boolean"
      maintainer_id = local.maintainers.default
    }

    simple_killswitch = {
      key = "simple"
      kind = "boolean"
      key_prefix = "killswitch"
      name = "Kill Switch: Simple"
      description = "Kill switch for Simple Flag"
      additional_tags = ["ui-killswitch"]
      variations = [{
        value = true
        name = "Kill Feature"
        description = "Simple Flag will serve the off variation"
      },
      {
        value = false
        name = "Allow Feature"
        description = "Simple Flag will continue normal evaluation"
      }]
    }

    multivariant = {
      # name is optional, it'll be generated from the key unless you override it
      name = "Multi-variant flag"
      kind = "string"
      # additional_tags will merge with the default tags provided by the flag module
      additional_tags = [ "multivariant" ]
      # variations can be lists of a single type
      variations = [ "green", "yellow", "red" ]
    }

    # the key in LD will be android-example
    android_example = {
      name = "Android-Specific Flag"
      description = "This flag was created from a flag template"
      kind = "boolean"
      template = local.templates.android
    }
  }
}

resource launchdarkly_feature_flag "flag_from_resource" {
  project_key = module.project.key
  variation_type = "boolean"
  key = "flag-from-resource"
  name = "Flag from resource"
  description = "You can also mix with flags created without the module"
  variations {
    value = true
  }
  variations {
    value = false
  }
}
