include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = "batch-execution-role-generic"
  principals = [
    {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  ]
  # Policy copied from AmazonECSTaskExecutionRolePolicy
  statements = [
    {
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:*"
      ],
      effect    = "Allow",
      resources = ["*"]
    }
  ]
}
