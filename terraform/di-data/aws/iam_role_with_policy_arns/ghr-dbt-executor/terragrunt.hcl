include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = "${include.root.locals.environment}-${basename(get_terragrunt_dir())}"
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
        "repo:${include.root.locals.github_organization_name}/data-intelligence-2020-dags:*",
        "repo:${include.root.locals.github_organization_name}/data-intelligence-2020-dbt:*",
      ]
    },
  ]
DUMMY CHANGE
  # FIXME: more restrictive permissions?
  statements = [
    {
      actions = [
        "redshift:View*",
        "redshift:List*",
        "redshift:Describe*"
      ],
      effect    = "Allow",
      resources = ["arn:aws:redshift:eu-central-1:${get_aws_account_id()}:cluster:tt-${include.root.locals.environment}-data-redshift"]
    },
    {
      actions = [
        "redshift:GetClusterCredentials"
      ],
      effect = "Allow",
      resources = [
        "arn:aws:redshift:eu-central-1:${get_aws_account_id()}:dbuser:tt-${include.root.locals.environment}-data-redshift/${include.root.locals.environment}_data_admin",
        "arn:aws:redshift:eu-central-1:${get_aws_account_id()}:dbuser:tt-${include.root.locals.environment}-data-redshift/di_apollo",
        "arn:aws:redshift:*:${get_aws_account_id()}:dbname:*/*"
      ]
    }
  ]
}
