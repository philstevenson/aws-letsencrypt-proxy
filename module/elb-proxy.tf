resource "aws_elb" "elb-inbound-proxy" {
  name            = "${var.name}-elb-ex"
  subnets         = ["${var.subnets}"]
  security_groups = ["${aws_security_group.sec-elb-inbound-proxy.id}"]

  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 5
  internal                    = false

  listener {
    instance_port      = 80
    instance_protocol  = "TCP"
    lb_port            = 80
    lb_protocol        = "TCP"
  }

  listener {
    instance_port      = 443
    instance_protocol  = "TCP"
    lb_port            = 443
    lb_protocol        = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    #target              = "tcp:80"
    target              = "http:80/healthcheck/index.html"
    timeout             = 2
  }

  tags {
    Name       = "${var.name}-elb-inbound-proxy"
    CostCentre = "${var.tags["costcentre"]}"
    Env        = "${var.tags["env"]}"
    Function   = "Load Balancer for PAC Script Webservers"
    Owner      = "${var.tags["owner"]}"
    Repository = "${var.tags["repository"]}"
    Script     = "${var.tags["script"]}"
    Service    = "${var.tags["service"]}"
  }
}

output "elb-dns-name" {
  value = "${aws_elb.elb-inbound-proxy.dns_name}"
}

output "elb-zone-id" {
  value = "${aws_elb.elb-inbound-proxy.zone_id}"
}
