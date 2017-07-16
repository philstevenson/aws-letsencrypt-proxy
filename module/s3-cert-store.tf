resource "aws_s3_bucket" "s3-inbound-proxy-cert" {
  bucket = "${var.name}-s3-inbound-proxy-cert"
  acl    = "private"
  force_destroy = true

  policy = "${data.aws_iam_policy_document.s3-inbound-proxy-cert-policy-document.json}"

  tags {
    Name       = "${var.name}-s3-inbound-proxy-cert"
    CostCentre = "${var.tags["costcentre"]}"
    Env        = "${var.tags["env"]}"
    Function   = "S3 bucket for Squid Proxy configs"
    Owner      = "${var.tags["owner"]}"
    Repository = "${var.tags["repository"]}"
    Script     = "${var.tags["script"]}"
    Service    = "${var.tags["service"]}"
  }
}

data "aws_iam_policy_document" "s3-inbound-proxy-cert-policy-document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.name}-s3-inbound-proxy-cert/*",
      "arn:aws:s3:::${var.name}-s3-inbound-proxy-cert"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${aws_iam_role.ec2-inbound-proxy-role-tf.arn}"
      ]
    }
  }
}
