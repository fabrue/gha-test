include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name                 = "${include.locals.environment}-${basename(get_terragrunt_dir())}"
  max_session_duration = "7200"
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
        "repo:tom-tailor-group/data:*",
      ]
    },
  ]

  # FIXME: more restrictive policy
  statements = [
    {
      actions = [
        "*"
      ],
      effect    = "Allow",
      resources = ["*"]
    }
  ]
}
