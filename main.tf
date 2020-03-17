


provider "launchdarkly" {
   version     = "~> 1.1.0"
   access_token = var.launchdarkly_access_token
}


module "example-project" {
  source = "./projects/tf-example-project"
  maintainers = {
    default = var.default_maintainer_email
    mobile = var.default_maintainer_email
  }
}
