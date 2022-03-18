include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "codeartifact_domain" {
  config_path = "../../codeartifact_domain/tt-data-intelligence"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn    = "arn:aws:codeartifact:eu-central-1:764392568064:domain/foobar"
    domain = "foobar"
  }
}

inputs = {
  domain     = dependency.codeartifact_domain.outputs.domain
  repository = "libs-release"
  upstream = [
    "maven-central-store"
  ]
}
