# CloudFormation template to "Create CodeBuild project with required IAM/SG/SSM/CW Logs configuration and S3/DynamoDB for Terraform"

## Preparations
* prepare configuration git repository for Terraform (example content in `configuration_repo_example`, use e.g. Bitbucket). 
  Ensure correct version of `terraform-aws-shared-proxy-vpc-endpoint-service` module by reviewing/updating `?ref=` parameter in `main.tf`.
* configure SSH keypair for the above repo for read-only access, pass private key as parameter when creating CloudFormation stack
* collect HTTP proxy information (hostname:port)
* ensure access from your VPC to the following AWS services: logs, ssm, s3 (for AWS accounts with limited connectivity (i.e. proxy) you must create VPC Endpoints for logs, ssm as CodeBuild cannot directly use the proxy). 

## Environment variables of CodeBuild project that can be used to controll Terraform
* TERRAFORM_ACTION (`create`, `destroy`, `plan` or `show` - default is `create`, `plan` will just generate plan and skip apply)
* TERRAFORM_DELAY_SECONDS (delay before `terraform apply`, allows to read the plan - default: 10 seconds)

## Notes/Limitations
* parameters can be adjusted after CFN deployment via AWS Systems Manager Parameter Store
* SSH private key is stored in SSM unencrypted as AWS CloudFormation doesn't support the SecureString parameter type (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ssm-parameter.html)
* this deployment configuration assumes HTTP proxy is used to provide Internet connectivity in the selected AWS account. To us it in non-limited accounts you may remove HTTP proxy variables from CodeBuild configuration
