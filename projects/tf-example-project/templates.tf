# you define some flag templates

# exposes external and local templates by prefix 
# you can define them as objects or via the module
# objects need the full definition due to limitations in terraform
# use null to leave at default
locals {
  templates = merge({
    mobile = module.template_mobile.template
    android = module.template_android.template
  }
  , coalesce(var.templates, {}))
}


module "template_mobile" {
  source = "../../modules/template"
  additional_tags = [ "mobile" ]
}

# templates can inherit from other templates
# fields defined here will override the base template
# with the exception with additional_tags, which will be merged with the base template
module "template_android" {
  source = "../../modules/template"
  base_template = module.template_mobile.template
  key_prefix = "android"
  additional_tags = [ "android" ]
}

