include {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  dns_suffix = "data.${include.locals.environment}.${include.locals.root_domain}"
}

inputs = {
  zone_id     = lookup(include.locals.aws_vars.locals.hosted_zone_environment_mapping, "data-${include.locals.environment}", null)
  domain_name = "*.${local.dns_suffix}"
}
