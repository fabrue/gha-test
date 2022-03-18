include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  # list of accounts allowed to assume terraform-exec role
  allowed_account_ids = compact([
    include.root.locals.aws_vars.locals.account_ids["management"],
    get_aws_account_id(),
  ])
  allowed_principal_arns = concat(
    formatlist("arn:aws:iam::%s:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_AdministratorAccess_*", local.allowed_account_ids),
    [format("arn:aws:iam::%s:role/terraform-exec", include.root.locals.aws_vars.locals.account_ids["management"])],
  )
  allowed_users = [
    # "arn:aws:iam::${get_aws_account_id()}:user/github-actions" # TODO: create iam user for GH pipeline
  ]
}

# `get_aws_roles.sh` gets name or arn of role via aws cli
inputs = {
  s3_bucket_name                            = include.root.locals.remote_state_name
  aws_assume_role_identifier_arns           = compact(concat(local.allowed_principal_arns, local.allowed_users))
  aws_access_state_s3bucket_identifier_arns = local.allowed_principal_arns
  principals_aws_identifiers                = local.allowed_account_ids
  enable_github_oidc_connector              = true
  allowed_github_repositorys                = include.root.locals.tf_exec_allowed_github_repositorys
  principals = [
    {
      type        = "AWS"
      identifiers = local.allowed_account_ids
    },
  ]
}
