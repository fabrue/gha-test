include "root" {
  path   = find_in_parent_folders()
  expose = true
}


terraform {
  source = "git::https://github.com/philips-labs/terraform-aws-github-runner.git///?ref=v0.35.0"
}

dependency "github_app_id" {
  config_path = "../../../aws/ssm_parameter_data/github_app_id"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    value = "foobar"
  }
}

dependency "github_app_private_key" {
  config_path = "../../../aws/ssm_parameter_data/github_app_private_key"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    value = "foobar-base64-encoded-string"
  }
}DUMMY CHANGE


dependency "github_app_webhook_secret" {
  config_path = "../../../aws/ssm_parameter_data/github_app_webhook_secret"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    value = "foobar"
  }
}


inputs = {
  aws_region = "eu-central-1"
  vpc_id     = "vpc-0ae61018fd6f90d6b"
  subnet_ids = ["subnet-035f0fe0b6391fd29", "subnet-0bca5cbfee92f7ceb", "subnet-079085b96d2b9659e"]

  # Used (among other things) to create role name. Role names must be unique. So choose likely unique name and not just 'management'
  environment = "tt-management"

  # Organization: tom-tailor-group
  github_app = {
    key_base64     = dependency.github_app_private_key.outputs.value
    id             = dependency.github_app_id.outputs.value
    webhook_secret = dependency.github_app_webhook_secret.outputs.value
  }

  lambda_s3_bucket      = "shared-resources.mgmt.infrastructure.tt.apollo.tom-tailor.com"
  syncer_lambda_s3_key  = "resources/github-actions-runner/v0.35.0/runner-binaries-syncer.zip"
  webhook_lambda_s3_key = "resources/github-actions-runner/v0.35.0/webhook.zip"
  runners_lambda_s3_key = "resources/github-actions-runner/v0.35.0/runners.zip"

  enable_organization_runners = true
  # Clashes with Pool config?
  runners_maximum_count = "3"
  instance_types        = ["c5.large"]
  key_name              = "iac@tom-tailor"
  delay_webhook_event   = 0
  enable_ssm_on_runners = true

  instance_target_capacity_type  = "on-demand"
  scale_down_schedule_expression = "cron(0/15 * * * ? *)" # Check every 15 Minutes if runner instance is busy, if not shut it down
  pool_runner_owner              = "tom-tailor-group"
  pool_config = [{
    size                = 2                     # size of the pool
    schedule_expression = "cron(0/3 * * * ? *)" # At this "frequency" the "tt-management-pool"-Lambda function is triggered
  }]
  enable_ephemeral_runners = true

  scale_up_reserved_concurrent_executions = "10"

  runner_run_as = "ubuntu"

  # Pre-built AMI, look at packer/gha-ubuntu-github-solution for more information
  ami_filter = { name = ["gha-ubuntu-runner-20220222124546"] }
  ami_owners = ["764392568064"]

  # Pre-built AMI contains startup script in /var/lib/cloud/scripts/per-boot - so do not use userdata here
  enabled_userdata = false

  block_device_mappings = {
    # Set the block device name for Ubuntu root device
    device_name = "/dev/sda1"
  }

  # Must be greater or equal than Pre-built AMI size
  volume_size = 101

  runner_log_files = [
    {
      "log_group_name" : "self-hosted-ubuntu-syslog",
      "prefix_log_group" : true,
      "file_path" : "/var/log/syslog",
      "log_stream_name" : "{instance_id}"
    },
    {
      "log_group_name" : "self-hosted-ubuntu-user_data",
      "prefix_log_group" : true,
      "file_path" : "/var/log/user-data.log",
      "log_stream_name" : "{instance_id}/user_data"
    },
    {
      "log_group_name" : "self-hosted-ubuntu-runner",
      "prefix_log_group" : true,
      "file_path" : "/opt/actions-runner/_diag/Runner_**.log",
      "log_stream_name" : "{instance_id}/runner"
    }
  ]

  tags = {
    function = "github-workflow-runner"
  }
}
