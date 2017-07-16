
# TEMPLATE FILES - injecting the variables into the config scripts



data "template_file" "nginx-vhost" {
  count = "${length(var.frontend-domains)}"
  template = "${file("${path.module}/config/nginx-vhost-${var.backend-protocol}")}"

  vars {
    frontend-domain = "${var.frontend-domains[count.index]}"
    backend-host    = "${var.backend-hosts[count.index]}"
  }
}

data "template_file" "nginx-acme-challenge" {
  template = "${file("${path.module}/config/nginx-acme-challenge")}"

  vars {
    certbot-server = "${aws_elb.elb-inbound-proxy-certbot.dns_name}"  # <<<<< maybe change to r53 alias
  }
}

data "template_file" "nginx-conf" {
  template = "${file("${path.module}/config/nginx.conf")}"

  vars {
    config-bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
  }
}

data "template_file" "certbot-check" {
  template = "${file("${path.module}/scripts/certbot-check.sh")}"

  vars {
    cert-bucket = "${aws_s3_bucket.s3-inbound-proxy-cert.id}"
    frontend-domains = "${join("' '", var.frontend-domains)}"
    region = "${var.region}"
    email = "${var.notification-email}"
  }
}

data "template_file" "cert-check" {
  template = "${file("${path.module}/scripts/cert-check.sh")}"

  vars {
    cert-bucket = "${aws_s3_bucket.s3-inbound-proxy-cert.id}"
    region = "${var.region}"
  }
}

# S3 BUCKET for storing config files

resource "aws_s3_bucket" "s3-inbound-proxy-config" {
  bucket = "${var.name}-s3-inbound-proxy-config"
  acl    = "private"
  policy = "${data.aws_iam_policy_document.s3-inbound-proxy-config-policy-document.json}"

  tags {
    Name       = "${var.name}-s3-inbound-proxy-config"
    CostCentre = "${var.tags["costcentre"]}"
    Env        = "${var.tags["env"]}"
    Fundivon   = "S3 bucket for Squid Proxy configs"
    Owner      = "${var.tags["owner"]}"
    Repository = "${var.tags["repository"]}"
    Script     = "${var.tags["script"]}"
    Service    = "${var.tags["service"]}"
  }
}

data "aws_iam_policy_document" "s3-inbound-proxy-config-policy-document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.name}-s3-inbound-proxy-config/*",
      "arn:aws:s3:::${var.name}-s3-inbound-proxy-config"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${aws_iam_role.ec2-inbound-proxy-role-tf.arn}"
      ]
    }
  }
}

resource "aws_s3_bucket_object" "s3-inbound-proxy-config-nginx-vhost" {
  count  = "${length(var.frontend-domains)}"
  bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
  key    = "config/vhosts/${var.frontend-domains[count.index]}"
  content = "${data.template_file.nginx-vhost.*.rendered[count.index]}"
}

resource "aws_s3_bucket_object" "s3-inbound-proxy-config-nginx-acme" {
  bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
  key    = "config/nginx-acme-challenge"
  content = "${data.template_file.nginx-acme-challenge.rendered}"
}

resource "aws_s3_bucket_object" "s3-inbound-proxy-config-nginx-conf" {
  bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
  key    = "config/nginx.conf"
  content = "${data.template_file.nginx-conf.rendered}"
}

resource "aws_s3_bucket_object" "s3-inbound-proxy-config-certbot-check" {
  bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
  key    = "scripts/certbot-check.sh"
  content = "${data.template_file.certbot-check.rendered}"

}
resource "aws_s3_bucket_object" "s3-inbound-proxy-config-cert-check" {
  bucket = "${aws_s3_bucket.s3-inbound-proxy-config.id}"
  key    = "scripts/cert-check.sh"
  content = "${data.template_file.cert-check.rendered}"

}
