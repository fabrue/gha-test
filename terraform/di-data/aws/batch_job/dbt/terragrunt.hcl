include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "batch_environment_dbt" {
  config_path = "../../batch/dbt"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    batch_job_queue_this_arn = "arn:aws::::mock"
  }
}

dependency "batch_execution_role_generic" {
  config_path = "../../iam_role_with_policy_arns/batch-execution-role"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws::::mock"
  }
}

dependency "github_deploy_key" {
  config_path = "../../ssm_parameter_data/github_deploy_key_di_2020_dags"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    name = "/mock/value"
  }
}

terraform {
  # From where does Terragrunt get the terraform (module) code
  source = "git::https://github.com/datadrivers/fx-terraform-module-aws-batch-job.git//?ref=feat/add-fargate-support"
}

locals {
  redshift_policy_admin_arn = format("arn:aws:iam::%s:policy/%s-redshift-users-loader-admin", include.root.locals.target_aws_account_id, include.root.locals.name_prefix)
}

inputs = {
  prefix = "${include.root.locals.target_aws_account_name}-"

  job_create    = true
  name          = "dbt"
  job_queue_arn = dependency.batch_environment_dbt.outputs.batch_job_queue_this_arn
  platform_capabilities = [
    "FARGATE",
  ]
  execution_role_extras_policies = [local.redshift_policy_admin_arn]
  ## schedule_expression            = "cron(0 0 * * ? 1970)"
  # Valid Fargate CPU/Memory combinations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  properties = {
    "image" : "${include.root.locals.aws_vars.locals.account_ids["management"]}.dkr.ecr.eu-central-1.amazonaws.com/data-intelligence-dbt:${include.root.locals.environment}",
    "resourceRequirements" : [
      { "type" : "VCPU", "value" : "1" },
      { "type" : "MEMORY", "value" : "3072" }
    ],
    "fargatePlatformConfiguration" : {
      "platformVersion" : "1.4.0",
    },
    "executionRoleArn" : dependency.batch_execution_role_generic.outputs.arn, # The Amazon Resource Name (ARN) of the execution role that AWS Batch can assume. For jobs that run on Fargate resources, you must provide an execution role.
    "environment" : [
      {
        "name" : "DEPLOYMENT_ENVIRONMENT", "value" : include.root.locals.environment
      }
    ],
    "secrets" : [
      {
        "name" : "SECRET_PRIVATE_KEY", "valueFrom" : dependency.github_deploy_key.outputs.name
      }
    ]
  }
}
