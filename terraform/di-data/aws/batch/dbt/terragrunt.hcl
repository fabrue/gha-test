include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc-outputs/default"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    private_subnets = [""]
  }
}


terraform {
  # From where does Terragrunt get the terraform (module) code
  source = "git::https://github.com/datadrivers/fx-terraform-module-aws-batch.git//?ref=feat/add-fargate-environment"
}


locals {
}

inputs = {
  prefix = "${include.root.locals.target_aws_account_name}-"

  compute_environment_name_prefix      = "Fargate-"
  compute_resource_type                = "FARGATE"
  compute_resource_max_vcpus           = 16
  compute_resource_subnet_ids          = dependency.vpc.outputs.private_subnets
  ecs_instance_profile_create          = false
  service_linked_role_spot_create      = false
  service_linked_role_spotfleet_create = false
}
