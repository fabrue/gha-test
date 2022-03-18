include {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../../aws/bootstrap"]
}

dependency "iam_user" {
  config_path = "../../../aws/iam_user_with_policy_arns/data-intelligence-2020-dags@github-actions"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws::::mock"
  }
}


locals {
  bucket_arns_mwaa_v1 = formatlist("arn:aws:s3:::airflow-dags.${include.locals.aws_vars.locals.region}.%s.${include.locals.aws_vars.locals.root_domain}", [
    "data-lab",
    "data-test",
    "data-prod",
  ])
  bucket_arns_mwaa_v2 = formatlist("arn:aws:s3:::airflow-v2-dags.${include.locals.aws_vars.locals.region}.%s.${include.locals.aws_vars.locals.root_domain}", [
    "data-lab",
    "data-test",
    "data-prod",
  ])

  # bucketname_env_combinations = setproduct(["airflow-dags", "airflow-v2-dags"], ["data-lab", "data-test", "data-prod", ])
  # bucket_arns_mwaa            = [for bucketname, env in local.bucketname_env_combinations : format("arn:aws:s3:::%v.${include.locals.aws_vars.locals.region}.%v.${include.locals.aws_vars.locals.root_domain}", bucketname, env)]
  bucket_arns_mwaa = concat(local.bucket_arns_mwaa_v1, local.bucket_arns_mwaa_v2)
}

inputs = {
  create = true
  name   = basename(get_terragrunt_dir())
  principals = [
    {
      type = "AWS"
      identifiers = [
        dependency.iam_user.outputs.arn,
      ]
    }
  ]
  statements = [
    {
      actions = [
        "s3:HeadBucket",
        "s3:Get*",
        "s3:List*",
        "s3:AbortMultipartUpload",
        "s3:PutObject*",
        "s3:*Tag*",
        "s3:DeleteObject"
      ]
      effect = "Allow"
      resources = concat(
        local.bucket_arns_mwaa_v1,
        local.bucket_arns_mwaa_v2,
        formatlist("%s/*", local.bucket_arns_mwaa_v1),
        formatlist("%s/*", local.bucket_arns_mwaa_v2)
      )
    },
  ]
}
