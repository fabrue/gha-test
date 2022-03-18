include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../bootstrap"]
}

dependency "ayou_backup_role" {
  config_path = "../../iam_role_with_policy_arns/ayou-backup"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:iam::00000000000:role/foo"
  }
}

locals {
  bucket_name = format("data-lake-aboutyou-cloud.%s.%s", replace(include.root.locals.target_aws_account_name, "-", "."), include.root.locals.aws_vars.locals.root_domain)
}

inputs = {
  create_bucket = true

  bucket                                = local.bucket_name
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  force_destroy                         = false
  restrict_public_buckets               = true
  enable_lifecycle_rule_version_cleanup = true
  enable_lifecycle_rule_tiering         = true
  enable_default_sse                    = true
  versioning = {
    enabled = true
  }

  # Explicitly deny bucket deletion
  attach_policy = true
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "ExplicitlyDenyBucketDeletion"
          Effect = "Deny"
          Action = [
            "s3:DeleteBucket"
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}",
          ],
          Principal = {
            AWS = "*"
          }
        },
        {
          Sid    = "AllowDatasyncAccessToBucket"
          Effect = "Allow"
          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads"
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}",
          ],
          Principal = {
            AWS = include.root.locals.aws_vars.locals.account_ids["data-lab"]
          }

          Condition = {
            ArnEquals = {
              "aws:PrincipalArn" = [
                "arn:aws:iam::${include.root.locals.aws_vars.locals.account_ids["data-lab"]}:role/datasync-s3-cross-account-access",
                "arn:aws:iam::${include.root.locals.aws_vars.locals.account_ids["data-lab"]}:role/terraform-exec*" # Allow Lab Account here, required by Terraform when initially applying Datasync Location
              ]
            }
          }
        },
        {
          Sid    = "AllowDatasyncAccessToObjects"
          Effect = "Allow"
          Action = [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListMultipartUploadParts",
            "s3:GetObjectTagging",
            "s3:PutObjectTagging",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}/*",
          ],
          Principal = {
            AWS = include.root.locals.aws_vars.locals.account_ids["data-lab"]
          }

          Condition = {
            ArnEquals = {
              "aws:PrincipalArn" = [
                "arn:aws:iam::${include.root.locals.aws_vars.locals.account_ids["data-lab"]}:role/datasync-s3-cross-account-access",
                "arn:aws:iam::${include.root.locals.aws_vars.locals.account_ids["data-lab"]}:role/terraform-exec*" # Allow Lab Account here, required by Terraform when initially applying Datasync Location
              ]
            }
          }
        }
      ]
    }
  )
  replication_configuration = {
    role = dependency.ayou_backup_role.outputs.arn

    rules = [
      {
        id       = "replicate-to-mgmt-account"
        status   = "Enabled"
        priority = 10

        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        destination = {
          bucket             = "arn:aws:s3:::backup-data-${include.root.locals.environment}-data-lake-aboutyou-cloud"
          storage_class      = "STANDARD"
          replica_kms_key_id = "arn:aws:kms:eu-central-1:${get_aws_account_id()}:alias/aws/s3"
          account_id         = include.root.locals.aws_vars.locals.account_ids["management"]
          access_control_translation = {
            owner = "Destination"
          }
          replication_time = {
            status  = "Enabled"
            minutes = 15
          }
          metrics = {
            status  = "Enabled"
            minutes = 15
          }
          # Ensure that this value is set to false! Otherwise accidentially deleted objects in source bucket will
          # also be deleted in backup bucket
          delete_marker_replication_status = false
        }
      }
    ]
  }
}
