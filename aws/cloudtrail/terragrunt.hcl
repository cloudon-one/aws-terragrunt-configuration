terraform {
  source = "git@git@github.com:cloudon-one/aws-terraform-modules.git/aws-terraform-cloudtrail"
}

include "common" {
  path = "${get_terragrunt_dir()}/common.hcl"
}

locals {
  common_vars     = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment     = basename(get_terragrunt_dir())
  resource        = basename(dirname(get_terragrunt_dir()))
  resource_vars   = local.common_vars.resource["aws"]["${local.resource}"]["${local.environment}"]["resources"]["${local.resource}"]
}

inputs = merge(local.resource_vars["inputs"], {})
