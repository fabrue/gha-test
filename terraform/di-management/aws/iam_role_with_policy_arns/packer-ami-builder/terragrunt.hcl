include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = "${basename(get_terragrunt_dir())}"
  actions = [
    "sts:AssumeRoleWithWebIdentity",
    "sts:TagSession",
  ]

  principals = [
    {
      type        = "Federated"
      identifiers = [format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", get_aws_account_id())]
    },
    {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  ]

  conditions = [
    {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${include.root.locals.github_organization_name}/data-intelligence-cloud-infrastructure:*",
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
