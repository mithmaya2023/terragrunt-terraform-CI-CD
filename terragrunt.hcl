terraform {
  source = "./terraform/modules//"
}
include {
  path = find_in_parent_folders()
}

