include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::ssh://git@github.com:cloudon-one/aws-terraform-modules.git//aws-terraform-iam/policies"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("vars.yaml")))
}