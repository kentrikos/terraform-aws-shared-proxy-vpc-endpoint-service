# CHANGE THIS FILE TO ADD MORE TARGETS FOR NLB ASSOCIATED WITH VPC ENDPOINT SERVICE:

variable "targets" {
  type        = "list"
  description = "List of services to be used as NLB targets, can be overriden"

  default = []

  #    {
  #      target_hostname = "sample_host.sample_domain"
  #      target_port     = "sample_port_number"
  #      nlb_port        = "sample_port_number"
  #    },
}
