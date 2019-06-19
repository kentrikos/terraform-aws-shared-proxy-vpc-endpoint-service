##########################################################################
# MODIFY THIS FILE TO ADD/UPDATE TARGETS OF NLB/VPC Endpoint Service.
##########################################################################

##########################################################################
# Flat list of DNS names of targets to be used for sharing via S3 bucket.
##########################################################################
# Format:
# locals {
#   target_dnsnames_to_share = [
#     "sample_host_1.sample_domain_1",
#     "sample_host_2.sample_domain_1",
#     "sample_host_1.sample_domain_2",
#   ]
# }
##########################################################################

locals {
  target_dnsnames_to_share = [
    "sample_host.sample_domain",
  ]
}

##########################################################################
# List of actual targets (listeners and TGs to be created).
##########################################################################
# Format:
# Values to set:
#  target_unique_id: string (Terraform resource ID), unique per deployment.
#                    Only supported characters: letters, numbers, dashes, and underscores.
#                    e.g. "target_FQDN_WITH_DOTS_REPLACED_BY_UNDERSCORES"
#       GIT_RELEASE: selected git release (tag) of the module
#   target_hostname: DNS name or IP of the target
#       target_port: TCP port of the target (integer)
# nlb_listener_port: mapped TCP port of the listener (integer)
#           COMMENT: Optional description of the target (e.g. firewall ticket)
# Notes:
#   * there are no commas between parameters and at the end of module section
#   * all lines beginning with # are comments
#
# # COMMENT
# module "target_unique_id" {
#   source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git//modules/target?ref=GIT_RELEASE"
#
#   target_hostname   = "FQDN"
#   target_port       = "PORT_NUMBER"
#   nlb_listener_port = "PORT_NUMBER"
#
#   nlb_tg_vpc = "${var.nlb_vpc}"
#   nlb_arn    = "${module.vpc-endpoint-services-nlb.nlb_arn}"
#
#   common_tag = "${var.common_tag}"
# }

module "target_sample_host_sample_domain" {
  source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git//modules/target?ref=master"

  target_hostname   = "sample_host.sample_domain"
  target_port       = "443"
  nlb_listener_port = "7443"

  nlb_tg_vpc    = "${var.nlb_vpc}"
  nlb_arn       = "${module.vpc-endpoint-services-nlb.nlb_arn}"
  dns_server_ip = "${var.dns_server_ip}"

  common_tag = "${var.common_tag}"
}
