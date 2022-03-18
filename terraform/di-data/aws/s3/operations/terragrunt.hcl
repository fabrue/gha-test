include {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../bootstrap"]
}

locals {
  # replace() is required to allow Terraform to work with imported bucket
  bucket_name = format("${basename(get_terragrunt_dir())}.%s.%s", replace(include.locals.target_aws_account_name, "-", "."), include.locals.aws_vars.locals.root_domain)
}

inputs = {
  create_bucket = true

  bucket                                = local.bucket_name
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  force_destroy                         = false
  restrict_public_buckets               = true
  enable_lifecycle_rule_version_cleanup = true
  enable_lifecycle_rule_tiering         = true
  enable_default_sse                    = true
  versioning = {
    enabled = true
  }

}
