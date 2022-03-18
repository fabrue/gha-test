include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  create = include.locals.environment == "lab"
  name   = "${include.locals.environment}-${basename(get_terragrunt_dir())}"
  actions = [
    "sts:AssumeRoleWithWebIdentity",
    "sts:TagSession",
  ]

  principals = [
    {
      type        = "Federated"
      identifiers = [format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", get_aws_account_id())]
    }
  ]

  conditions = [
    {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:tom-tailor-group/data-intelligence-cloud-infrastructure:*",
      ]
    },
  ]

  # FIXME: more restrictive permissions?
  statements = [
    {
      actions = [
        "datasync:CreateLocationS3",
        "datasync:CreateLocationFsxWindows",
        "datasync:CreateTask",
        "datasync:CreateLocationEfs",
        "datasync:ListAgents",
        "datasync:CreateAgent",
        "datasync:ListLocations",
        "datasync:CreateLocationSmb",
        "datasync:ListTaskExecutions",
        "datasync:ListTasks",
        "datasync:CreateLocationObjectStorage",
        "datasync:CreateLocationNfs"
      ],
      effect    = "Allow",
      resources = ["*"]
    },
    {
      actions = [
        "datasync:*"
      ],
      effect = "Allow",
      resources = [
        "arn:aws:datasync:*:*:task/*",
        "arn:aws:datasync:*:*:location/*",
        "arn:aws:datasync:*:*:agent/*"
      ]
    },
    {
      actions = [
        "datasync:*"
      ],
      effect = "Allow",
      resources = [
        "arn:aws:datasync:*:*:task/*/execution/*"
      ]
    },
    {
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:ListBucket",
        "s3:ListMultipartUploadParts"
      ],
      effect = "Allow",
      resources = [
        "arn:aws:s3:::data-lake-store.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-ecom-arvato.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-ecom-caperwhite.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-ecom-novomind.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-ecom-sap.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-ecom-tradebyte.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-ecom-tteshop.data.lab.tt.apollo.tom-tailor.com",
        "arn:aws:s3:::data-lake-store.data.lab.tt.apollo.tom-tailor.com/*",
        "arn:aws:s3:::data-lake-ecom-arvato.data.lab.tt.apollo.tom-tailor.com/*",
        "arn:aws:s3:::data-lake-ecom-caperwhite.data.lab.tt.apollo.tom-tailor.com/*",
        "arn:aws:s3:::data-lake-ecom-novomind.data.lab.tt.apollo.tom-tailor.com/*",
        "arn:aws:s3:::data-lake-ecom-sap.data.lab.tt.apollo.tom-tailor.com/*",
        "arn:aws:s3:::data-lake-ecom-tradebyte.data.lab.tt.apollo.tom-tailor.com/*",
        "arn:aws:s3:::data-lake-ecom-tteshop.data.lab.tt.apollo.tom-tailor.com/*"
      ]
    }
  ]
}
