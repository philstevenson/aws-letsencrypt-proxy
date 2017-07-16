variable "name" {
  description = "The name of the reverse proxy service, this must be unique within the aws account if using this module more that once"
}

variable "region" {
  default = "eu-west-1"
}

variable "vpc" {
  description = "The VPC ID to join this VPN onto"
}

variable "subnets" {
  description = "list of subnets for proxy hosts to reside"
  type        = "list"
}

variable "notification-email" {
  description = "letsencrypt notification email"
  default = ""
}

variable "frontend-domains" {
  description = "list the public domain names of services, at related index to backend-hosts list"
  type        = "list"
}

variable "backend-hosts" {
  description = "list the backend-hosts DNS name for each service, at related index to frontend-domains list"
  type        = "list"
}

variable "prefix-list-id" {
  description = "Enter the prefix-list-id of the S3 endpoint to allow instances to download config from S3"
}

variable "allowed-ips" {
  description = "List of allowed external IPs to external proxy elb"
  type = "list"
  default = [
    "0.0.0.0/0",
  ]
}

variable "sns-topic" {}

variable "ssh-key" {
  default = ""
}

variable "asg-proxy" {
  type = "map"
  default = {
    instance_type         = "t2.micro"
    max_size              = 2
    min_size              = 1
    desired_capacity      = 1
    wait_for_elb_capacity = 1
  }
}

variable "backend-protocol" {
  default = "https"
  description = "https or http for backend communication"
}

variable "nginx-ami" {}

variable "tags" {
  type = "map"
}
