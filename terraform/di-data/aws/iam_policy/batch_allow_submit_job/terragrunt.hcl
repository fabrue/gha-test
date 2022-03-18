include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name        = "batch-execution-role-generic"
  description = "Allow submitting a Job to AWS Batch"
  statements = [
    {
      sid = "AllowSubmitJob"
      actions = [
        "batch:SubmitJob",
        "batch:DescribeJobs",
        "batch:TerminateJob"
      ]
      effect    = "Allow"
      resources = ["*"]
    }
  ]
}
