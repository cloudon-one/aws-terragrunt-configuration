terraform {
  extra_arguments "common" {
    commands = get_terraform_commands_that_need_vars()
  }
  extra_arguments "non-interactive" {
    commands = [
      "hclfmt",
      "validate",
      "plan",
      "apply"
    ]
    arguments = [
      "-compact-warnings", 
    ]
  }
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("vars.yaml")))
}

remote_state {
    backend = "s3"
    generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.common_vars.common.owner}-${local.location}-${local.environment}-${local.common_vars.common.statebucketsuffix}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.common_vars.common.default_region
    encrypt        = true
  }
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
  region = "${local.common_vars.common.default_region}"
  assume_role {
    role_arn = "${local.common_vars.common.terraform_role_arn}"
  }
}
EOF
}