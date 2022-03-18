include {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../../aws/bootstrap"]
}

dependency "iam_policy" {
  config_path = "../../../aws/iam_policy/assume_mwaa-manager"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws::::mock"
  }
}

inputs = {
  name        = basename(get_terragrunt_dir())
  policy_arns = [dependency.iam_policy.outputs.arn]
}
