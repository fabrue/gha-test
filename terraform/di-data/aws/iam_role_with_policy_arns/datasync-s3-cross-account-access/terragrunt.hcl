include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  create = include.locals.environment == "lab" ? true : false

  name = "datasync-s3-cross-account-access"
  principals = [
    {
      type = "Service"
      identifiers = [
        "datasync.amazonaws.com"
      ]
    }
  ]
  statements = [
    {
      actions = [
        "iam:PassRole",
        "kms:Decrypt",
        "kms:Encrypt",
        "s3:*",
        "kms:DescribeKey",
        "datasync:*",
        "kms:GenerateDataKey*"
      ]
      effect    = "Allow"
      resources = ["*"]
    },
  ]
}
