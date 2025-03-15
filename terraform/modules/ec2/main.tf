resource "aws_instance" "app_server" {
  ami           = "ami-00c257e12d6828491"  # Update this with the correct AMI ID
  instance_type = var.instance_type
  tags = {
    Name = "Terragrunt-EC2"
  }
}i
