include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  create        = true
  create_role   = true
  function_name = "monitor-gha-runner"
  description   = "Monitor how many runners are active"
  runtime       = "nodejs14.x"
  handler       = "index.handler"
  source_path = [
    {
      path = "${get_parent_terragrunt_dir()}/../lambda/cmd/monitor_gha_runner/"
    }
  ]

  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect = "Allow"
      actions = [
        "ec2:describeInstances"
      ]
      resources = ["*"]
    }
    cloudwatch = {
      effect = "Allow"
      actions = [
        "cloudwatch:PutMetricData",
        "cloudwatch:ListMetrics"
      ]
      resources = ["*"]
    }
  }

  trigger_event_rule_patterns = {
    "cron-trigger" = {
      schedule_expression = "rate(1 minute)"
    }
  }

  environment_variables = {
    FILTER_TAG             = "github-workflow-runner" # we want to find EC2 instances tagged with "function=github-workflow-runner"
    CLOUDWATCH_NAMESPACE   = "GhaRunner"
    CLOUDWATCH_METRIC_NAME = "Runner"
  }
}
