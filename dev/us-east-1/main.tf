resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

provider "aws" {
  region = "us-east-1"
}