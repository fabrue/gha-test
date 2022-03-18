include {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  account_ids                      = [include.locals.aws_vars.locals.account_ids["data-lab"], include.locals.aws_vars.locals.account_ids["data-test"], include.locals.aws_vars.locals.account_ids["data-prod"]]
  allowed_administrators           = formatlist("arn:aws:iam::%s:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_AdministratorAccess_*", local.account_ids)
  kms_key_eligibled_principals     = formatlist("arn:aws:iam::%s:root", local.account_ids)
  kms_key_eligibled_emr_roles      = formatlist("arn:aws:iam::%s:role/EMR_DefaultRole", local.account_ids)
  kms_key_cross_account_principals = concat(local.allowed_administrators, local.kms_key_eligibled_emr_roles)
}

inputs = {
  alias       = "alias/${include.locals.environment}-packer-cross-account-ami-sharing"
  environment = include.locals.environment
  enabled     = true
  description = "KMS key used by Packer to enable cross account AMI sharing"
  policy      = <<EOT
{
    "Id": "kms-policy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${get_aws_account_id()}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(local.kms_key_eligibled_principals)}
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "aws:PrincipalArn": ${jsonencode(local.kms_key_cross_account_principals)}
                }
            }
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(local.kms_key_eligibled_principals)}
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                },
                "ArnLike": {
                    "aws:PrincipalArn": ${jsonencode(local.kms_key_cross_account_principals)}
                }
            }
        }
    ]
}
  EOT
}
