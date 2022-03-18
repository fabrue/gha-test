include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "target_bucket" {
  config_path = "../../../aws/s3/operations"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    id = "bucketname"
  }
}

dependency "basic_auth_username" {
  config_path = "../../../aws/ssm_parameter_data/ayou_webhook_username"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    value = "foo"
  }
}

dependency "basic_auth_password_ssm_path" {
  config_path = "../../../aws/ssm_parameter_data/ayou_webhook_password"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    name = "/path/in/ssm"
  }
}

inputs = {
  bucket         = dependency.target_bucket.outputs.id
  key_prefix     = "${include.root.locals.project_vars.locals.canary_subfolder_name}/${include.root.locals.project_vars.locals.ayou_endpoint_api_canary_name}/script.zip"
  file_paths     = ["${get_terragrunt_dir()}/built-canary-script/"]
  create_archive = true
}

generate "canary_script" {
  path           = "${get_terragrunt_dir()}/built-canary-script/nodejs/node_modules/${include.root.locals.project_vars.locals.ayou_endpoint_api_canary_script_filename}"
  if_exists      = "overwrite"
  comment_prefix = "// " # Javscript comment syntax

  contents = templatefile("${get_terragrunt_dir()}/ayou-order-confirmed-canary.js.tpl", {
    endpoint_url                 = "ayou-webhook.data.${include.root.locals.environment}.tt.apollo.tom-tailor.com" # FIXME: use dependency/data resource to fetch url
    basic_auth_username          = dependency.basic_auth_username.outputs.value
    basic_auth_password_ssm_path = dependency.basic_auth_password_ssm_path.outputs.name
  })
}
