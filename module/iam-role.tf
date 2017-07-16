resource "aws_iam_instance_profile" "ec2-inbound-proxy-iprofile-tf" {
  name  = "${var.name}-ec2-inbound-proxy-role-tf"
  path  = "/"
  role = "${aws_iam_role.ec2-inbound-proxy-role-tf.name}"
}

resource "aws_iam_role" "ec2-inbound-proxy-role-tf" {
  name = "${var.name}-ec2-inbound-proxy-role-tf"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ec2-inbound-proxy-role-tf-policy-document.json}"
}

data "aws_iam_policy_document" "ec2-inbound-proxy-role-tf-policy-document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "policy-ec2-inbound-proxy-tf" {
  name        = "${var.name}-policy-ec2-inbound-proxy-tf"
  path        = "/"
  description = "ec2 policy to allow get from s3"
  policy      = "${data.aws_iam_policy_document.policy-ec2-inbound-proxy-tf-policy-document.json}"
}

data "aws_iam_policy_document" "policy-ec2-inbound-proxy-tf-policy-document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.s3-inbound-proxy-config.arn}",
      "${aws_s3_bucket.s3-inbound-proxy-cert.arn}",
    ]
  }
}

#attach the polciy to role
resource "aws_iam_policy_attachment" "attach-policy-ec2-inbound-proxy-tf" {
  name = "${var.name}-attach-policy-ec2-inbound-proxy-tf"

  /*description = "Attaches the s3-put-only-policy-tf to the EC2-S3-write-tf role"*/
  roles      = ["${aws_iam_role.ec2-inbound-proxy-role-tf.name}"]
  policy_arn = "${aws_iam_policy.policy-ec2-inbound-proxy-tf.arn}"
}
