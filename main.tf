# FIXME: map function will be deprecated in TF 0.12 (https://www.terraform.io/docs/configuration/functions/map.html)

locals {
  common_tag = "${map(
     "${var.common_tag["key"]}", "${var.common_tag["value"]}"
   )}"
}

# NLB and targets:
resource "aws_lb" "nlb" {
  name               = "${var.nlb_name}"
  internal           = true
  load_balancer_type = "network"
  subnets            = "${var.nlb_subnets}"

  enable_deletion_protection = false

  # NOTE: this cannot be parametrized (no interpolation allowed in lifecycle: https://github.com/hashicorp/terraform/issues/3116
  lifecycle {
    prevent_destroy = "false"
  }

  tags = "${local.common_tag}"
}

resource "aws_lb_target_group" "this" {
  count       = "${length(var.targets)}"
  port        = "${lookup(var.targets[count.index], "target_port")}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${var.nlb_vpc}"

  tags = "${merge(
                          local.common_tag, 
                          map(
                            "target_hostname",
                            lookup(var.targets[count.index], "target_hostname")
                          )
                        )
                  }"

  lifecycle {
    create_before_destroy = true
  }
}

data "external" "dns_resolver" {
  count = "${length(var.targets)}"

  program = ["bash", "${path.module}/helpers/tf_dns_resolver_helper.sh"]

  query = {
    dns_name      = "${lookup(var.targets[count.index], "target_hostname")}"
    dns_server_ip = "${var.dns_server_ip}"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count             = "${length(var.targets)}"
  target_group_arn  = "${aws_lb_target_group.this.*.arn[count.index]}"
  target_id         = "${lookup(var.targets[count.index], "target_hostname")}"
  target_id         = "${data.external.dns_resolver.*.result.ip[count.index]}"
  availability_zone = "all"
}

resource "aws_lb_listener" "nlb" {
  count             = "${length(var.targets)}"
  load_balancer_arn = "${aws_lb.nlb.arn}"
  protocol          = "TCP"
  port              = "${lookup(var.targets[count.index], "nlb_port")}"

  default_action {
    target_group_arn = "${aws_lb_target_group.this.*.arn[count.index]}"
    type             = "forward"
  }
}

# VPC Endpoint Service:
resource "aws_vpc_endpoint_service" "this" {
  network_load_balancer_arns = ["${aws_lb.nlb.arn}"]
  acceptance_required        = "${var.vpces_acceptance_required}"
  allowed_principals         = "${var.vpces_allowed_principals}"

  # NOTE: this cannot be parametrized (no interpolation allowed in lifecycle: https://github.com/hashicorp/terraform/issues/3116
  lifecycle {
    prevent_destroy = "false"
  }
}

# S3 bucket for sharing information about targets:
resource "aws_s3_bucket" "s3_vpces" {
  bucket = "${replace(aws_vpc_endpoint_service.this.service_name, "/^com.amazonaws.vpce./", "")}"
  acl    = "private"

  tags = "${local.common_tag}"
}

resource "aws_s3_bucket_object" "targets" {
  key          = "targets.csv"
  bucket       = "${aws_s3_bucket.s3_vpces.id}"
  content      = "${join(",", data.external.dns_resolver.*.query.dns_name)}"
  content_type = "text/plain"

  tags = "${local.common_tag}"
}

data "aws_iam_policy_document" "s3_vpces" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.s3_vpces.arn}",
    ]

    principals {
      type        = "AWS"
      identifiers = "${var.vpces_allowed_principals}"
    }
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
    ]

    resources = [
      "${aws_s3_bucket.s3_vpces.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = "${var.vpces_allowed_principals}"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_vpces" {
  bucket = "${aws_s3_bucket.s3_vpces.id}"
  policy = "${data.aws_iam_policy_document.s3_vpces.json}"
}
