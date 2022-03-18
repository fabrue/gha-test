include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  # replace() is required to allow Terraform to work with imported bucket
  bucket_name = format("data-lake-unload.%s.%s", replace(include.root.locals.target_aws_account_name, "-", "."), include.root.locals.aws_vars.locals.root_domain)
}

inputs = {
  name = "unload-bucket-write-access"
  principals = [
    {
      type = "Service"
      identifiers = [
        "redshift.amazonaws.com"
      ]
    }
  ]
  statements = [
    {
      actions = [
        "s3:List*",
        "s3:Get*",
        "s3:Delete*",
        "s3:Put*"
      ],
      effect = "Allow",
      resources = [
        "arn:aws:s3:::${local.bucket_name}/*",
        "arn:aws:s3:::${local.bucket_name}/"
      ]
    }
  ]
}
