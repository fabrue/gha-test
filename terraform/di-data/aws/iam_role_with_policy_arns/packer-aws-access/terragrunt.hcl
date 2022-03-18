include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = "packer-aws-access"
  principals = [
    {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  ]
  statements = [
    {
      actions = [
        "ssm:GetParameters",
        "ssm:DescribeParameters"
      ],
      effect    = "Allow",
      resources = ["arn:aws:ssm:eu-central-1:023296727374:parameter/emr-cwa-agent"]
    }
  ]
}
