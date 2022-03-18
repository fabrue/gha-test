include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "nlb" {
  config_path = "../../nlb/repository-tableau"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    lb_dns_name = "nlb-000000.elb.eu-central-1.amazonaws.com "
    lb_zone_id  = "FOOBARJ5LGBH90"
  }
}

inputs = {
  zone_id = include.locals.aws_vars.locals.hosted_zone_environment_mapping["presentation-prod"]
  alias_records = {
    "nlb" = {
      name = "repository.tableau"
      ttl  = "60"
      type = "A"
      alias = {
        name                   = dependency.nlb.outputs.lb_dns_name
        zone_id                = dependency.nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    }
  }
  allow_overwrite = true
}
