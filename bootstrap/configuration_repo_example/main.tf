module "vpc-endpoint-services-nlb" {
  source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git"

  nlb_name    = "${var.nlb_name}"
  nlb_vpc     = "${var.nlb_vpc}"
  nlb_subnets = "${var.nlb_subnets}"

  vpces_acceptance_required = "${var.vpces_acceptance_required}"
  vpces_allowed_principals  = "${var.vpces_allowed_principals}"

  dns_server_ip = "${var.dns_server_ip}"

  common_tag = "${var.common_tag}"
}
