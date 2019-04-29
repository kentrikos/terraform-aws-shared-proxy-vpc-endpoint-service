output "vpces_service_name" {
  description = "Name of VPC Endpoint Service"
  value       = "${aws_vpc_endpoint_service.this.service_name}"
}

output "vpces_base_endpoint_dns_names" {
  description = "The DNS names for the VPC endpoint service"
  value       = "${aws_vpc_endpoint_service.this.base_endpoint_dns_names}"
}

output "nlb_arn" {
  description = "The ARN of the Network Load Balancer"
  value       = "${aws_lb.nlb.arn}"
}

output "target_s3_bucket" {
  description = "ARN of S3 bucket with list of targets"
  value       = "${aws_s3_bucket.s3_vpces.arn}"
}

output "target_s3_bucket_key_targets" {
  description = "Filename with comma-separated list of targets"
  value       = "${aws_s3_bucket_object.targets.key}"
}

output "target_dns_names" {
  description = "List of DNS names passed as targets"
  value       = "${data.external.dns_resolver.*.query.dns_name}"
}

output "target_ips" {
  description = "List of IPs resolved from targets"
  value       = "${data.external.dns_resolver.*.result.ip}"
}
