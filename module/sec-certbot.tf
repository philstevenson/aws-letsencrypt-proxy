resource "aws_security_group" "sec-inbound-proxy-certbot" {
  name        = "${var.name}-sec-inbound-proxy-certbot"
  description = "sec-inbound-proxy-certbot"
  vpc_id      = "${var.vpc}"

  tags {
    Name       = "${var.name}-sec-inbound-proxy-certbot"
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

resource "aws_security_group_rule" "sec-inbound-proxy-certbot-web" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-inbound-proxy-certbot.id}"
  source_security_group_id = "${aws_security_group.sec-elb-inbound-proxy-certbot.id}"
}

resource "aws_security_group_rule" "sec-inbound-proxy-certbot-aws-s3-443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = ["${var.prefix-list-id}"]
  security_group_id = "${aws_security_group.sec-inbound-proxy-certbot.id}"
}

resource "aws_security_group_rule" "sec-inbound-proxy-certbot-letsencrypt-443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sec-inbound-proxy-certbot.id}"
}
