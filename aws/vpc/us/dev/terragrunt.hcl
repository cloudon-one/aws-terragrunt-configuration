include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::ssh://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-vpc?ref=dev-yaar"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  region        = local.common_vars.common.default_region
  environment   = basename(get_terragrunt_dir())
  location      = basename(dirname(get_terragrunt_dir()))
  resource      = basename(dirname(dirname(get_terragrunt_dir())))
  resource_vars = try(
    local.common_vars["Environments"]["${local.location}-${local.environment}"]["Resources"]["${local.resource}"],
    {}
  )

  # Extract VPC configurations and region from resource_vars
  vpcs_config = try(local.resource_vars["inputs"]["vpcs"], [])

  # Create the VPCs list with the correct vpc_name
  vpcs = [
    for vpc in local.vpcs_config : merge(vpc, {
      vpc_name = "${local.location}-${local.environment}-${local.resource}"
      tags = merge(try(vpc.tags, {}), {
        Name        = "${local.location}-${local.environment}-${local.resource}"
        Environment = local.environment
      })
    })
  ]
}

inputs = merge(
  try(local.resource_vars["inputs"], {}),
  {
    vpcs = local.vpcs
  }
)
