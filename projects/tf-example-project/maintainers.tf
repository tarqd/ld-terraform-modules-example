# grab team member info for maintainers
data "launchdarkly_team_member" "maintainers" {
  for_each = var.maintainers
  email = each.value
}
