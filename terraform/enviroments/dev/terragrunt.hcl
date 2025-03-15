terraform {
  source = "../../modules//"
}
inputs = {
  instance_type = "t3.micro"
  bucket_name = "my-terragrunt-state-bucket"
  cidr_block = "10.0.0.0/16"
}

