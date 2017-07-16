data "template_file" "certbot-bootstap" {
  template = "${file("${path.module}/bootstrap/certbot.sh")}"

  vars {
    system-name = "${var.name}"
    config-bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
    cert-bucket = "${aws_s3_bucket.s3-inbound-proxy-cert.id}"
    region = "${var.region}"
  }
}

resource "aws_launch_configuration" "lconf-inbound-proxy-certbot" {
  name_prefix                 = "${var.name}-lconf-inbound-proxy-certbot-"
  image_id                    = "${var.nginx-ami}"
  instance_type               = "t2.nano"
  iam_instance_profile        = "${aws_iam_instance_profile.ec2-inbound-proxy-iprofile-tf.name}"
  security_groups             = ["${aws_security_group.sec-inbound-proxy-certbot.id}"]
  associate_public_ip_address = true
  user_data                   = "${data.template_file.certbot-bootstap.rendered}"
  key_name = "${var.ssh-key}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-inbound-proxy-certbot" {
  name_prefix                 = "${var.name}-asg-inbound-proxy-certbot-"
  max_size                  = "1"
  min_size                  = "1"
  desired_capacity          = "1"
  default_cooldown          = 10
  health_check_grace_period = 300
  health_check_type         = "ELB"
  wait_for_elb_capacity     = 1
  load_balancers            = ["${aws_elb.elb-inbound-proxy-certbot.name}"]
  force_delete              = false
  vpc_zone_identifier       = ["${var.subnets}"]
  termination_policies      = ["OldestLaunchConfiguration"]

  launch_configuration = "${aws_launch_configuration.lconf-inbound-proxy-certbot.name}"

  # lifecycle {
  #   create_before_destroy = true
  # }

  depends_on = ["aws_autoscaling_group.asg-inbound-proxy"]

  tag {
    key                 = "Name"
    value               = "${var.name}-ec2-inbound-proxy-certbot"
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
