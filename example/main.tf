module "proxy" {
  source  = "../module/"

  # unique name prefix for all resources
  name    = "WEB1"

  region  = "${var.region}"
  vpc     = "${aws_vpc.vpc.id}"

  # LetEncrypt certificate expiry notification
  notification-email = "<insert-email>"

  subnets = [
    "${aws_subnet.euw1a-main.id}",
    "${aws_subnet.euw1b-main.id}",
    "${aws_subnet.euw1c-main.id}",
  ]

  # Public facing domain names, a cert for each
  frontend-domains = [
    "www.example.com",
    "shop.example.com"
  ]

  # backend hosts can be ips or hostnames, http or https
  backend-hosts = [
    "web.cluster1.internal.example.com",
    "shop.cluster2.internal.example.com"
  ]

  # Topic for Alarms AWS ARN
  sns-topic = "arn:aws:sns:eu-west-1:xxxxx:global"

  # AGS bounds, TODO: add auto-scaling rules
  asg-proxy = {
    "instance_type" = "t2.micro"
    "max_size" = "2"
    "min_size" = "2"
    "desired_capacity" = "2"
    "wait_for_elb_capacity" = 1
    }

  # For security group to allow internal S3 acces for config
  prefix-list-id = "pl-xxxxxxxs"

  # Map of tags which are tagged to each resource
  tags = "${var.tags}"

  # this is currently the same ami for both the lets encrypt bot and the proxies. They both require nginx.
  nginx-ami = "${data.aws_ami.nginx.id}"
}

resource "aws_route53_record" "www" {
  zone_id = ""
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = "${module.proxy.elb-dns-name}"
    zone_id                = "${module.proxy.elb-zone-id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "shop" {
  zone_id = ""
  name    = "shop.example.com"
  type    = "A"

  alias {
    name                   = "${module.proxy.elb-dns-name}"
    zone_id                = "${module.proxy.elb-zone-id}"
    evaluate_target_health = true
  }
}
