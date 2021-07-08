# CHANGE THIS FILE TO UPDATE VERSION (tag, release, branch) OF TF MODULE:

# Callout of the top-level module that creates NLB and VPC Endpoint Service:
module "vpc-endpoint-services-nlb" {
  # e.g. ?ref=0.1.0
  //  source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git?ref=master"
  source = "../.."

  nlb_name    = var.nlb_name
  nlb_vpc     = var.nlb_vpc
  nlb_subnets = var.nlb_subnets

  vpces_acceptance_required = var.vpces_acceptance_required
  vpces_allowed_principals  = var.vpces_allowed_principals

  dns_server_ip = var.dns_server_ip

  common_tag = var.common_tag
}

# File with S3 bucket with list of targets' DNS names (useful for sharing):
resource "aws_s3_bucket_object" "targets" {
  key          = "targets.csv"
  bucket       = module.vpc-endpoint-services-nlb.target_s3_bucket
  content      = join(",", local.target_dnsnames_to_share)
  content_type = "text/plain"

  tags = var.common_tag
}