# DO NOT CHANGE THIS FILE!
#
# Provider configuration for Terraform.

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.7"
}
