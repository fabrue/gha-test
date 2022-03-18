include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "webhook_username" {
  config_path                             = "../../ssm_parameter_data/ayou_webhook_username"
  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    value = "foo"
  }
}

dependency "webhook_password_ssm_name" {
  config_path                             = "../../ssm_parameter_data/ayou_webhook_password"
  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    name = "/foo/bar"
  }
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git///?ref=v2.32.0"
}

locals {
  prefix = "${include.root.locals.target_aws_account_name}-"
}

inputs = {
  function_name = "${local.prefix}ayou-webhook-basic-auth"
  description   = "Used as API gateway authorizer"
  runtime       = "nodejs14.x"
  handler       = "index.handler"
  source_path = [
    {
      path = "${get_parent_terragrunt_dir()}/../lambda/cmd/ayou_webhook_basic_auth/"
    }
  ]

  environment_variables = {
    WEBHOOK_USERNAME          = dependency.webhook_username.outputs.value
    WEBHOOK_PASSWORD_SSM_NAME = dependency.webhook_password_ssm_name.outputs.name
    LOG_LAMBDA_EVENT          = false
  }

  attach_policy_statements = true
  policy_statements = {
    ssm_access = {
      effect = "Allow"
      actions = [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ]
      resources = ["arn:aws:ssm:eu-central-1:${get_aws_account_id()}:parameter/aboutyou/webhook/order-confirmed/password"]
    }
  }

}
