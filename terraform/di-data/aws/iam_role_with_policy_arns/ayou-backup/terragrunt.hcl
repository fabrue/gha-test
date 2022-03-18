include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = basename(get_terragrunt_dir())
  principals = [
    {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  ]
  statements = [
    {
      sid = "1"
      actions = [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      effect    = "Allow",
      resources = ["arn:aws:s3:::data-lake-aboutyou-cloud.data.${include.root.locals.environment}.tt.apollo.tom-tailor.com"]
    },
    {
      sid = "2"
      actions = [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      effect    = "Allow",
      resources = ["arn:aws:s3:::data-lake-aboutyou-cloud.data.${include.root.locals.environment}.tt.apollo.tom-tailor.com/*"]
    },
    {
      sid = "3"
      actions = [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      effect    = "Allow",
      resources = ["arn:aws:s3:::backup-data-${include.root.locals.environment}-data-lake-aboutyou-cloud/*"]
    },
    {
      sid = "4"
      actions = [
        "s3:ObjectOwnerOverrideToBucketOwner"
      ],
      effect    = "Allow",
      resources = ["arn:aws:s3:::backup-data-${include.root.locals.environment}-data-lake-aboutyou-cloud/*"]
    }
  ]
}
