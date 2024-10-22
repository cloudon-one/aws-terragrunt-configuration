include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "vpc" {
  config_path = "../../../vpc/us/dev"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-redis?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(get_terragrunt_dir())
  location      = basename(dirname(get_terragrunt_dir()))
  resource      = basename(dirname(dirname(get_terragrunt_dir())))
  resource_vars = local.common_vars["Environments"]["${local.location}-${local.environment}"]["Resources"]["${local.resource}"]
}

inputs = merge(
  local.resource_vars["inputs"],
  {
    cluster_id         = "${local.location}-${local.environment}-${local.resource}"
    subnet_ids         = dependency.vpc.outputs.elasticache_subnets
    security_group_ids = dependency.vpc.outputs.redis_sg_id
    subnet_group_name  = dependency.vpc.outputs.elasticache_subnet_group_name
  }
)