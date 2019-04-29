# Universal TF backend configuration for the AWS account and region.
# AWS region, bucket, S3 key must be set from commandline when running Terraform.

terraform {
  backend "s3" {
    # Do not change:
    dynamodb_table = "tf-state-lock-bootstrap"
    encrypt        = "true"
  }
}
