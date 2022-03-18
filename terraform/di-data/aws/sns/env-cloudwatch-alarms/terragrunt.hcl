include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  topic_name = "${include.root.locals.target_aws_account_name}-cloudwatch-alarms"
}

inputs = {
  name           = local.topic_name
  display_name   = local.topic_name
  create_kms_cmk = true # CloudWatch cannot work with AWS managed KMS Key, so create custom one (https://aws.amazon.com/de/premiumsupport/knowledge-center/cloudwatch-receive-sns-for-alarm-trigger/)

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid": "Allow_Publish_Alarms",
      "Effect": "Allow",
      "Principal":
        {
            "Service": [
                "cloudwatch.amazonaws.com"
            ]
        },
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
        "arn:aws:sns:eu-central-1:${get_aws_account_id()}:${local.topic_name}"
      ]
    },
    {
      "Sid": "DefaultPolicy",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish"
      ],
      "Resource": "arn:aws:sns:eu-central-1:${get_aws_account_id()}:${local.topic_name}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${get_aws_account_id()}"
        }
      }
    }
  ]
}
EOF
}
