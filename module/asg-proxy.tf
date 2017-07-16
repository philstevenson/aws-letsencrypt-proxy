data "template_file" "nginx-bootstap" {
  template = "${file("${path.module}/bootstrap/nginx.sh")}"

  vars {
    system-name = "${var.name}"
    config-bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
    cert-bucket = "${aws_s3_bucket.s3-inbound-proxy-cert.id}"
    certbot-server = "${aws_elb.elb-inbound-proxy-certbot.dns_name}"
    region = "${var.region}"
  }
}

resource "aws_launch_configuration" "lconf-inbound-proxy" {
  name_prefix                 = "${var.name}-lconf-inbound-proxy-"
  image_id                    = "${var.nginx-ami}"
  instance_type               = "${var.asg-proxy["instance_type"]}"
  iam_instance_profile        = "${aws_iam_instance_profile.ec2-inbound-proxy-iprofile-tf.name}"
  security_groups             = ["${aws_security_group.sec-inbound-proxy.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.nginx-bootstap.rendered}"
  key_name = "${var.ssh-key}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-inbound-proxy" {
  name_prefix               = "${var.name}-asg-inbound-proxy-"
  max_size                  = "${var.asg-proxy["max_size"]}"
  min_size                  = "${var.asg-proxy["min_size"]}"
  desired_capacity          = "${var.asg-proxy["desired_capacity"]}"
  default_cooldown          = 10
  wait_for_elb_capacity     = "${var.asg-proxy["wait_for_elb_capacity"]}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = false
  load_balancers            = ["${aws_elb.elb-inbound-proxy.name}"]
  vpc_zone_identifier       = ["${var.subnets}"]
  termination_policies      = ["OldestLaunchConfiguration"]

  launch_configuration = "${aws_launch_configuration.lconf-inbound-proxy.name}"

  lifecycle {
    create_before_destroy = true
  }
  #
  tag {
    key                 = "Name"
    value               = "${var.name}-ec2-inbound-proxy"
    propagate_at_launch = true
  }
  #
  # tag {
  #   key                 = "Script"
  #   value               = "${var.tags["script"]}"
  #   propagate_at_launch = true
  # }
  #
  # tag {
  #   key                 = "Env"
  #   value               = "${var.tags["env"]}"
  #   propagate_at_launch = true
  # }
  #
  # tag {
  #   key                 = "Owner"
  #   value               = "${var.tags["owner"]}"
  #   propagate_at_launch = true
  # }
  #
  # tag {
  #   key                 = "Repository"
  #   value               = "${var.tags["repository"]}"
  #   propagate_at_launch = true
  # }
  #
  # tag {
  #   key                 = "CostCentre"
  #   value               = "${var.tags["costcentre"]}"
  #   propagate_at_launch = true
  # }
  #
  # tag {
  #   key                 = "Domain HostName"
  #   value               = "pacfile.poise.homeoffice.local"
  #   propagate_at_launch = true
  # }
}
