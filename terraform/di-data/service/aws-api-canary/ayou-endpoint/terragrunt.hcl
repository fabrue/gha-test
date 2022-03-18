include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "canary_script" {
  config_path = "../../../aws/s3_bucket_object/ayou_endpoint_canary_script"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    bucket = "bucketname"
    files = [
      {
        "name" = {
          key        = "zipfile.zip"
          version_id = "versionid1234"
        }
      }
    ]
  }
}

dependency "target_bucket" {
  config_path = "../../../aws/s3/operations"

  mock_outputs_allowed_terraform_commands = include.root.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    id = "bucketname"
  }DUMMY CHANGE

}

locals {
  canary_script_s3_path = "${include.root.locals.project_vars.locals.canary_subfolder_name}/${include.root.locals.project_vars.locals.ayou_endpoint_api_canary_name}/script.zip"
}

inputs = {
  name                 = include.root.locals.project_vars.locals.ayou_endpoint_api_canary_name
  artifact_s3_location = "s3://${dependency.target_bucket.outputs.id}/${include.root.locals.project_vars.locals.canary_subfolder_name}/${include.root.locals.project_vars.locals.ayou_endpoint_api_canary_name}/artifacts"
  handler              = "ayou-order-confirmed-canary.handler"
  runtime_version      = "syn-nodejs-puppeteer-3.3"
  schedule_expression  = "rate(5 minutes)"
  s3_bucket            = dependency.canary_script.outputs.bucket
  s3_key               = local.canary_script_s3_path #lookup(lookup(dependency.canary_script.outputs.files[0], local.canary_script_s3_path, ""), "key", "")
  s3_version           = lookup(lookup(dependency.canary_script.outputs.files[0], local.canary_script_s3_path, ""), "version_id", "")
  attach_ssm_policy    = true
  allowed_ssm_path     = "/aboutyou/webhook/order-confirmed/"
}
