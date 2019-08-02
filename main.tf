# FIXME: map function is deprecated and will be removed in future versions of TF (https://www.terraform.io/docs/configuration/functions/map.html)

locals {
  common_tag = {
    lookup(var.common_tag, "key", null) = lookup(var.common_tag, "value", null)
  }
}

# NLB:
resource "aws_lb" "nlb" {
  name               = var.nlb_name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.nlb_subnets

  enable_deletion_protection = false

  # NOTE: this cannot be parametrized (no interpolation allowed in lifecycle: https://github.com/hashicorp/terraform/issues/3116
  lifecycle {
    prevent_destroy = "false"
  }

  tags = local.common_tag
}

# VPC Endpoint Service:
resource "aws_vpc_endpoint_service" "this" {
  network_load_balancer_arns = [aws_lb.nlb.arn]
  acceptance_required        = var.vpces_acceptance_required
  allowed_principals         = var.vpces_allowed_principals

  # NOTE: this cannot be parametrized (no interpolation allowed in lifecycle: https://github.com/hashicorp/terraform/issues/3116
  lifecycle {
    prevent_destroy = "false"
  }
}

# S3 bucket for sharing information about targets:
resource "aws_s3_bucket" "s3_vpces" {
  bucket = replace(
    aws_vpc_endpoint_service.this.service_name,
    "/^com.amazonaws.vpce./",
    "",
  )
  acl = "private"

  tags = local.common_tag
}

data "aws_iam_policy_document" "s3_vpces" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3_vpces.arn,
    ]

    principals {
      type        = "AWS"
      identifiers = var.vpces_allowed_principals
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
      identifiers = var.vpces_allowed_principals
    }
  }
}

resource "aws_s3_bucket_policy" "s3_vpces" {
  bucket = aws_s3_bucket.s3_vpces.id
  policy = data.aws_iam_policy_document.s3_vpces.json
}

resource "aws_network_acl" "nacl" {
  count      = var.enable_nacl ? 1 : 0
  vpc_id     = var.nlb_vpc
  subnet_ids = var.nlb_subnets
}