resource "aws_security_group" "sec-elb-inbound-proxy" {
  name        = "${var.name}-sec-elb-inbound-proxy"
  description = "public elb for ${var.name} reverse proxy service"
  vpc_id      = "${var.vpc}"

  tags {
    Name       = "${var.name}-sec-elb-inbound-proxy"
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

resource "aws_security_group_rule" "sec-elb-inbound-proxy-80-in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sec-elb-inbound-proxy.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sec-elb-inbound-proxy-443-in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sec-elb-inbound-proxy.id}"
  cidr_blocks       = ["${var.allowed-ips}"]
}

resource "aws_security_group_rule" "sec-elb-inbound-proxy-80-out" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-elb-inbound-proxy.id}"
  source_security_group_id = "${aws_security_group.sec-inbound-proxy.id}"
}

resource "aws_security_group_rule" "sec-elb-inbound-proxy-443-out" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec-elb-inbound-proxy.id}"
  source_security_group_id = "${aws_security_group.sec-inbound-proxy.id}"
}
