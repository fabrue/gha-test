include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "s3_source" {
  config_path = "../../datasync_location_s3/prod/data-lake-store-car"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:s3:::bucket_name"
  }
}

dependency "s3_destination" {
  config_path = "../../datasync_location_s3/lab/data-lake-store-car"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:s3:::bucket_name"
  }
}

inputs = {
  create                   = include.locals.environment == "lab"
  destination_location_arn = dependency.s3_destination.outputs.arn
  source_location_arn      = dependency.s3_source.outputs.arn
  name                     = "data-lake-store-car-prod-to-lab"
}
