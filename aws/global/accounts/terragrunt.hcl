include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::ssh://git@github.com/FidoMoney/terraform-modules.git//aws-terraform-accounts?ref=dev"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("vars.yaml")))
}

inputs = {
  org_id    = local.common_vars.common.org_id
  org_units = local.common_vars.Environments.global.Resources.org_units.inputs
  accounts  = local.common_vars.Environments.global.Resources.accounts.inputs
}
