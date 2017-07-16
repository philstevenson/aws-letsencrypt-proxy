resource "aws_security_group" "sec-elb-inbound-proxy-certbot" {
  name        = "${var.name}-sec-elb-inbound-proxy-certbot"
  description = "public elb for ${var.name} reverse proxy service"
  vpc_id      = "${var.vpc}"

  tags {
    Name       = "${var.name}-sec-elb-inbound-proxy-certbot"
    CostCentre = "${var.tags["costcentre"]}"
    Env        = "${var.tags["env"]}"
    Function   = "Security Group for public elb for ${var.name} reverse proxy service"
    Owner      = "${var.tags["owner"]}"
    Repository = "${var.tags["repository"]}"
    Script     = "${var.tags["script"]}"
    Service    = "${var.tags["service"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sec-elb-inbound-proxy-certbot-80-in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sec-elb-inbound-proxy-certbot.id}"
  source_security_group_id = "${aws_security_group.sec-inbound-proxy.id}"
}

resource "aws_security_group_rule" "sec-elb-inbound-proxy-certbot-80-out" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-elb-inbound-proxy-certbot.id}"
  source_security_group_id = "${aws_security_group.sec-inbound-proxy-certbot.id}"
}
