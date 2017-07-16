resource "aws_security_group" "sec-inbound-proxy" {
  name        = "${var.name}-sec-inbound-proxy"
  description = "sec-inbound-proxy"
  vpc_id      = "${var.vpc}"

  tags {
    Name       = "${var.name}-sec-inbound-proxy"
    CostCentre = "${var.tags["costcentre"]}"
    Env        = "${var.tags["env"]}"
    Function   = "security_groups for PAC Script Webservers"
    Owner      = "${var.tags["owner"]}"
    Repository = "${var.tags["repository"]}"
    Script     = "${var.tags["script"]}"
    Service    = "${var.tags["service"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_security_group_rule" "sec-inbound-proxy-dns-out" {
#   type                     = "egress"
#   from_port                = 53
#   to_port                  = 53
#   protocol                 = "udp"
#   security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
#   cidr_blocks       = ["10.236.16.2/32"]
# }
#
# resource "aws_security_group_rule" "sec-inbound-proxy-dns-in" {
#   type                     = "ingress"
#   from_port                = 53
#   to_port                  = 53
#   protocol                 = "udp"
#   security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
#   cidr_blocks       = ["10.236.16.2/32"]
# }
#
# resource "aws_security_group_rule" "sec-inbound-proxy-dns-out-tcp" {
#   type                     = "egress"
#   from_port                = 53
#   to_port                  = 53
#   protocol                 = "tcp"
#   security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
#   cidr_blocks       = ["10.236.16.2/32"]
# }

resource "aws_security_group_rule" "sec-inbound-proxy" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
  source_security_group_id = "${aws_security_group.sec-elb-inbound-proxy.id}"
}

resource "aws_security_group_rule" "sec-inbound-proxy-web" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
  source_security_group_id = "${aws_security_group.sec-elb-inbound-proxy.id}"
}

resource "aws_security_group_rule" "sec-inbound-proxy-aws-s3-443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = ["${var.prefix-list-id}"]
  security_group_id = "${aws_security_group.sec-inbound-proxy.id}"
}

resource "aws_security_group_rule" "sec-inbound-proxy-to-certbot-80" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
  source_security_group_id = "${aws_security_group.sec-inbound-proxy-certbot.id}"
}

resource "aws_security_group_rule" "sec-inbound-proxy-443-out-to-apps" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sec-inbound-proxy-80-out-to-apps" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-inbound-proxy.id}"
  cidr_blocks             = ["0.0.0.0/0"]
}
