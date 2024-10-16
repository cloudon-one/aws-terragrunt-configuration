include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "git::ssh://git@github.com:cloudon-one/aws-terraform-modules.git//aws-terraform-tgw?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  resource      = basename(dirname(get_terragrunt_dir())))
  resource_vars = local.common_vars["Environments"]["Resources"]["${local.resource}"]
}

inputs = merge(
  local.resource_vars["inputs"],
  {
    name = "${local.location}-${local.resource}"
    vpc_id = dependency.vpc.outputs.vpc_id
    subnet_ids = dependency.vpc.outputs.private_subnets
  }
)