# CHANGE THIS FILE TO CONTROL WHICH AWS ACCOUNTS ARE ALLOWED TO THE VPC ENDPOINT SERVICE:

variable "vpces_acceptance_required" {
  description = "Whether or not VPC endpoint connection requests to the service must be accepted by the service owner"
  default     = "true"
}

variable "vpces_allowed_principals" {
  type        = list(string)
  description = "The ARNs of one or more principals allowed to discover the endpoint service"
  default     = []
}