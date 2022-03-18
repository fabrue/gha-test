include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  default = false
  name    = "tt-${include.locals.environment}-presentation"
}
