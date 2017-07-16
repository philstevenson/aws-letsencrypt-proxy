
# THIS ELB is here to provide dynamic dns to the single certbot host

resource "aws_elb" "elb-inbound-proxy-certbot" {
  name            = "${var.name}-elb-in"
  subnets         = ["${var.subnets}"]
  security_groups = ["${aws_security_group.sec-elb-inbound-proxy-certbot.id}"]

  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 5
  internal                    = true

  listener {
    instance_port      = 80
    instance_protocol  = "TCP"
    lb_port            = 80
    lb_protocol        = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    target              = "tcp:80"
    timeout             = 2
  }

  tags {
    Name       = "${var.name}-elb-inbound-proxy-certbot"
    CostCentre = "${var.tags["costcentre"]}"
    Env        = "${var.tags["env"]}"
    Function   = "Load Balancer for PAC Script Webservers"
    Owner      = "${var.tags["owner"]}"
    Repository = "${var.tags["repository"]}"
    Script     = "${var.tags["script"]}"
    Service    = "${var.tags["service"]}"
  }
}
