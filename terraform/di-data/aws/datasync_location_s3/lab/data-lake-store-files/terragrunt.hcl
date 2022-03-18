include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "datasync_access_role" {
  config_path = "../../../iam_role_with_policy_arns/datasync-s3-cross-account-access"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:iam::00000000000:role/foo"
  }
}

inputs = {
  create                 = include.locals.environment == "lab"
  s3_bucket_arn          = include.locals.project_vars.locals.lab_data_lake_store_bucket_arn
  bucket_access_role_arn = dependency.datasync_access_role.outputs.arn
  subdirectory           = "/service=files/stage=p_mirror/"
}
