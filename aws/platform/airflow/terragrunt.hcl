include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/k8s-platform-modules.git//k8s-platform-airflow?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  tool          = basename(get_terragrunt_dir())
  platform      = basename(dirname(get_terragrunt_dir()))
  resource_vars = local.common_vars["Platform-tools"]["${local.account}"]["Resources"]["${local.resource}"]
}

inputs = merge(
  local.resource_vars["inputs"],{
#    vpc_id             = dependecy.outputs.vpc.vpc_id
#    private_subnet_ids = dependecy.outputs.vpc.private_subnet_ids
#    eks_cluster_name   = dependecy.outputs.eks.eks_cluster.name
  }
)



  
