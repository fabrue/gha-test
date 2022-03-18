include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../../bootstrap"]
}

locals {
  bucket_name = "backup-data-lab-data-lake-aboutyou-cloud"
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
          Sid    = "Permissions on objects"
          Effect = "Allow"
          Action = [
            "s3:ReplicateDelete",
            "s3:ReplicateObject"
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}/*",
          ],
          Principal = {
            AWS = "arn:aws:iam::${include.root.locals.aws_vars.locals.account_ids["data-lab"]}:role/ayou-backup"
          }
        },
        {
          Sid    = "Permissions on bucket"
          Effect = "Allow"
          Action = [
            "s3:List*",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning"
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}",
          ],
          Principal = {
            AWS = "arn:aws:iam::${include.root.locals.aws_vars.locals.account_ids["data-lab"]}:role/ayou-backup"
          }
        },
        {
          Sid    = "Change object ownership"
          Effect = "Allow"
          Action = [
            "s3:ObjectOwnerOverrideToBucketOwner"
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}/*",
          ],
          Principal = {
            AWS = include.root.locals.aws_vars.locals.account_ids["data-lab"]
          }
        },
      ]
    }
  )
}
