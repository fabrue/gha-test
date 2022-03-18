# FIXME: do not add this parameter per account, instead store it in management account and read it from there

include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = "/github/deploy-keys/data-intelligence-2020-dags"
}
