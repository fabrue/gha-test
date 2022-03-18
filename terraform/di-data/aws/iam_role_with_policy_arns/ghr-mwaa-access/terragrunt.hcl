include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "mwaa_environment" {
  config_path = "../../../service/aws-mwaa/default-v2"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    aws_mwaa_environment_arn = "arn:aws::::mock"
  }
}

inputs = {
  create = include.locals.environment == "prod"
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

  statements = [
    {
      actions = [
        "airflow:UpdateEnvironment",
        "airflow:GetEnvironment"
      ],
      effect    = "Allow",
      resources = ["${dependency.mwaa_environment.outputs.aws_mwaa_environment_arn}"]
    },
    {
      actions = [
        "airflow:ListEnvironments"
      ],
      effect    = "Allow",
      resources = ["*"]
    },
    {
      actions = [
        "ec2:DescribeSubnets"
      ],
      effect    = "Allow",
      resources = ["*"]
    },
  ]
}
