include {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../bootstrap"]
}

locals {
  bucket_name               = format("airflow-v2-dags.%s.%s.%s", include.locals.aws_vars.locals.region, include.locals.target_aws_account_name, include.locals.aws_vars.locals.root_domain)
  iam_role_dags_manager_arn = format("arn:aws:iam::%s:role/mwaa-dags-manager", include.locals.aws_vars.locals.account_ids["management"])
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
  attach_policy                         = true
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = [include.locals.aws_vars.locals.account_ids["management"]]
          }
          Action = [
            "s3:GetObject*",
            "s3:List*",
            "s3:AbortMultipartUpload",
            "s3:PutObject*",
            "s3:DeleteObject",
          ]
          Resource = [
            "arn:aws:s3:::${local.bucket_name}",
            "arn:aws:s3:::${local.bucket_name}/*"
          ],
          Condition = {
            StringLike = {
              "aws:PrincipalARN" = [
                local.iam_role_dags_manager_arn,
              ]
            }
          },
        }
      ]
    }
  )
}
