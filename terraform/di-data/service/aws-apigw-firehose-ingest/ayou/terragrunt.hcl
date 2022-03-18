include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "lambda_authorizer" {
  config_path                             = "../../../aws/lambda_function/ayou_webhook_basic_auth"
  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    lambda_function_name    = "foobar"
    lambda_function_version = "42"
  }
}

dependency "kinesis_target_bucket" {
  config_path                             = "../../../aws/s3/data-lake-aboutyou-cloud"
  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:s3:::bucket"
  }
}

dependency "sns" {
  config_path                             = "../../../aws/sns/env-cloudwatch-alarms"
  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    sns_topic_arn = "arn:aws:sns:eu-central-1:0000000000:topic-name"
  }
}

locals {
  name                         = "ayou-webhook"
  prefix                       = include.root.locals.target_aws_account_name
  kinesis_firehose_stream_name = "ayou"
  route53_domain               = "${replace(include.root.locals.target_aws_account_name, "-", ".")}.${include.root.locals.aws_vars.locals.root_domain}"
}

inputs = {
  name                                            = local.name
  aws_lambda_function_authorizer_invoke_name      = dependency.lambda_authorizer.outputs.lambda_function_name
  aws_lambda_function_authorizer_invoke_qualifier = dependency.lambda_authorizer.outputs.lambda_function_version
  create_route53_record                           = true
  route53_domain                                  = local.route53_domain
  domain_name                                     = "${local.name}.${local.route53_domain}"
  get_certificate_domain                          = "*.${local.route53_domain}"
  get_certificate                                 = true
  s3_bucket_arn                                   = dependency.kinesis_target_bucket.outputs.arn
  kinesis_firehose_stream_name                    = local.kinesis_firehose_stream_name
  api_gw_resource_name                            = "order-confirmed"
  extended_s3_configuration_prefix                = "stage=${include.root.locals.environment}/!{timestamp:yyyy/MM/dd/HH/}"
  extended_s3_configuration_error_output_prefix   = "error/!{firehose:error-output-type}/stage=${include.root.locals.environment}/!{timestamp:yyyy/MM/dd/HH/}"
  api_gw_alarm_actions                            = [dependency.sns.outputs.sns_topic_arn]
  api_gw_ok_actions                               = [dependency.sns.outputs.sns_topic_arn]
  request_template                                = <<EOF
#set($msgBody = $util.parseJson($input.body))
#set($msgId = $msgBody.messageId)
{
    "Record" : {
      "Data": "$util.base64Encode($input.body)"
    },
    "PartitionKey": "ayou",
    "DeliveryStreamName": "${local.kinesis_firehose_stream_name}"
}
EOF
}
