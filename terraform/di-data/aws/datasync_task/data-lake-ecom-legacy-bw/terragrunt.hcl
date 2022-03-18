include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "s3_source" {
  config_path = "../../datasync_location_s3/prod/${local.location_name}"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:s3:::bucket_name"
  }
}

dependency "s3_destination" {
  config_path = "../../datasync_location_s3/lab/${local.location_name}"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:s3:::bucket_name"
  }
}

locals {
  location_name = basename(get_terragrunt_dir())
}

inputs = {
  create                   = include.locals.environment == "lab"
  destination_location_arn = dependency.s3_destination.outputs.arn
  source_location_arn      = dependency.s3_source.outputs.arn
  name                     = "data-lake-store-ecom_legacy_bw-prod-to-lab"
}
