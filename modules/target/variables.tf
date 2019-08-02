variable "target_hostname" {
  description = "Hostname of the target (or optionally IP)"
}

variable "target_port" {
  description = "TCP port number of the target"
}

variable "nlb_listener_port" {
  description = "TCP port number to be used on NLB listener for this target"
}

variable "nlb_arn" {
  description = "The arn of existing NLB to be used"
}

variable "nlb_tg_vpc" {
  description = "The identifier of the VPC for NLB target group"
}

variable "dns_server_ip" {
  description = "IP of DNS server that will be used for resolution of targets (leave empty to attempt to use locally configured DNS server)"
  default     = ""
}

variable "common_tag" {
  type        = map(string)
  description = "Single tag to be assigned to each resource (that supports tagging) created by this module"

  default = {
    "key"   = "environment"
    "value" = "dev"
  }
}

variable "enable_nacl" {
  type    = bool
  default = false
}

variable "nacl_id" {
  type    = string
  default = ""
}

variable "nacl_rule_number" {
  type    = string
  default = ""
}

variable "nacl_rule_cidr" {
  type    = string
  default = ""
}