# DO NOT CHANGE THIS FILE!
#
# Configuration of Terraform outputs.

output "vpces_service_name" {
  value = module.vpc-endpoint-services-nlb.vpces_service_name
}

output "vpces_base_endpoint_dns_names" {
  value = module.vpc-endpoint-services-nlb.vpces_base_endpoint_dns_names
}

output "nlb_arn" {
  value = module.vpc-endpoint-services-nlb.nlb_arn
}

output "target_s3_bucket" {
  value = module.vpc-endpoint-services-nlb.target_s3_bucket
}