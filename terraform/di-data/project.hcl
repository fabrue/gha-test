locals {
  module_version_default                   = "v6.18.0"
  prod_data_lake_store_bucket_arn          = "arn:aws:s3:::data-lake-store.data.prod.tt.apollo.tom-tailor.com"
  lab_data_lake_store_bucket_arn           = "arn:aws:s3:::data-lake-store.data.lab.tt.apollo.tom-tailor.com"
  canary_subfolder_name                    = "canaries"
  ayou_endpoint_api_canary_name            = "ayou-order-confirmed"
  ayou_endpoint_api_canary_script_filename = "ayou-order-confirmed-canary.js"
}
