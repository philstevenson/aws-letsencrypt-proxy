provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

variable "profile" {
  default = ""
}

variable "region" {
  default = "eu-west-1"
}

variable "tags" {
  type = "map"

  default = {
    costcentre = ""
    env        = ""
    owner      = ""
    repository = ""
    service    = ""
    script     = "Terraform"
    vpc        = ""
  }
}

data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-nginx-*"]
  }
  owners = [""] # our account
}
