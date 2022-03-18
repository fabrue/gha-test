include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../../aws/bootstrap"]
}

locals {
  iam_role_arn = format("arn:aws:iam::%s:role/mwaa-dags-manager", get_aws_account_id()) # Can't use dependency here due to cycle with user and role
}

inputs = {
  name = basename(get_terragrunt_dir())
  statements = [
    {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      effect = "Allow"
      resources = [
        local.iam_role_arn
      ]
    },
  ]
}
