include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "sns_topic" {
  config_path                             = "../../../sns/env-cloudwatch-alarms"
  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    sns_topic_arn = "arn:aws:sns:eu-central-1:0000000000:topic-name"
  }
}

inputs = {
  endpoint  = include.root.locals.monitoring_mail_address
  protocol  = "email"
  topic_arn = dependency.sns_topic.outputs.sns_topic_arn
}
