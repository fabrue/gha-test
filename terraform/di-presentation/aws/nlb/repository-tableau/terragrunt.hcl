include {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v6.5.0"
}

dependency "vpc" {
  config_path = "../../vpc-outputs/tt-env-presentation"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    name = "vpc-name"
    private_subnets = [
      "subnet-000",
      "subnet-111"
    ]
  }
}

inputs = {
  name                             = "nlb-repository-tableau"
  load_balancer_type               = "networkDUMMY CHANGE
"
  vpc_id                           = dependency.vpc.outputs.vpc_id
  subnets                          = dependency.vpc.outputs.private_subnets
  internal                         = true
  enable_cross_zone_load_balancing = true

  http_tcp_listeners = [
    {
      port               = 8060
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name               = "tableau-repository"
      backend_protocol   = "TCP"
      backend_port       = 8060
      target_type        = "instance"
      preserve_client_ip = true
      # The ASG in `data` repository handles the target assocation
      # targets = { }
    }
  ]
}
