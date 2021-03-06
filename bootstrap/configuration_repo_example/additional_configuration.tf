# GENERAL CONFIGURATION, SHOULD BE ONLY CHANGED FOR INITIAL DEPLOYMENT:

variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "nlb_name" {
  description = "The name of the LB."
  default     = "sample-shared-proxy-nlb"
}

variable "nlb_vpc" {
  description = "The identifier of the VPC for NLB"
  default     = "vpc-00000000000000000"
}

variable "nlb_subnets" {
  type        = "list"
  description = "A list of subnet IDs to attach to the LB."
  default     = ["subnet-00000000000000000", "subnet-00000000000000000", "subnet-00000000000000000"]
}

variable "dns_server_ip" {
  description = "For submodule usage: IP of DNS server that will be used for resolution of targets (leave empty to attempt to use locally configured DNS server)"
  default     = ""
}

variable "common_tag" {
  type        = "map"
  description = "Single tag to be assigned to each resource (that supports tagging) created by this module"

  default = {
    "key"   = "deployedby"
    "value" = "sample_username/tf"
  }
}
