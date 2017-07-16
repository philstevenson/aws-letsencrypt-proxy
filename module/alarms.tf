//#elb unhealth hosts
resource "aws_cloudwatch_metric_alarm" "alarm-unhealthy-hosts" {
  alarm_name          = "${aws_elb.elb-inbound-proxy.name}-alarm-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "EC2 Alarm triggers when unhealthy-hosts greater than 1"
  alarm_actions       = ["${var.sns-topic}"]

  dimensions {
    LoadBalancerName = "${aws_elb.elb-inbound-proxy.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm-unhealthy-hosts-certbot" {
  alarm_name          = "${aws_elb.elb-inbound-proxy-certbot.name}-alarm-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "EC2 Alarm triggers when unhealthy-hosts greater than 1"
  alarm_actions       = ["${var.sns-topic}"]

  dimensions {
    LoadBalancerName = "${aws_elb.elb-inbound-proxy-certbot.name}"
  }
}

resource "aws_autoscaling_notification" "notifications" {
  group_names = [
    "${aws_autoscaling_group.asg-inbound-proxy.name}",
    "${aws_autoscaling_group.asg-inbound-proxy-certbot.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${var.sns-topic}"

}
