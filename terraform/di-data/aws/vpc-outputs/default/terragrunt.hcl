include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../bootstrap"]
}

locals {
}

inputs = {
  name = include.root.locals.name_prefix
}
