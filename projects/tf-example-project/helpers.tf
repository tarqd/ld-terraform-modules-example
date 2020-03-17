# little helpers to make writing flags easier
locals {
  # map maintainer roles to launchdarkly member ids
  maintainers = { for k,v in data.launchdarkly_team_member.maintainers : k => v.id } 
}