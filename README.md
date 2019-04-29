# A Terraform module to deploy proxy solution based on NLB and VPC Endpoint Service

This module will create NLB with listeners and IP-based targets accordingly to specs and also an accompanying VPC Endpoint Service.
Additionally, it will create an S3 bucket with file containing comma-separated list of DNS names for targets.
This bucket will be shared with AWS accounts whitelisted for the VPC Endpoint Service and can be used to create
corresponding Route53 records on the remote accounts where VPC Endpoints are deployed
(see repository: <https://github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint>).

## Preparations

* The recommended way to use the module is to run Terraform from CodeBuild project.
  Complete configuration required to deploy this modul with CodeBuild can be deployed with CloudFormation template
  found in `bootstrap/codebuild_setup.yaml`
* List of targets (services) built into the module can be found in `targets.tf` file (empty by default, may be extened via custom fork).
  To overrride this list an alternate configuration can be provided with standard Terraform variable (of type: `map`) when calling the module.
  Both DNS names and plain IPs are supported.
* Module requires `jq` and `dig` to be available (for DNS resolution of targets) 
  and valid IP of DNS server configured (if empty local system default will be used)

## Usage

### Use custom targets (recommended):

```hcl
module "vpc-endpoint-services-nlb" {
  source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git"

  nlb_name    = "${var.nlb_name}"
  nlb_vpc     = "${var.nlb_vpc}"
  nlb_subnets = "${var.nlb_subnets}"

  vpces_acceptance_required = "${var.vpces_acceptance_required}"
  vpces_allowed_principals  = "${var.vpces_allowed_principals}"

  targets = "${var.my_targets_list}"

  dns_server_ip = "${var.dns_server_ip}"

  common_tag = "${var.common_tag}"
}
```

### Use built-in targets:

```hcl
module "vpc-endpoint-services-nlb" {
  source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git"

  nlb_name    = "${var.nlb_name}"
  nlb_vpc     = "${var.nlb_vpc}"
  nlb_subnets = "${var.nlb_subnets}"

  vpces_acceptance_required = "${var.vpces_acceptance_required}"
  vpces_allowed_principals  = "${var.vpces_allowed_principals}"

  dns_server_ip = "${var.dns_server_ip}"

  common_tag    = "${var.common_tag}"
}
```

## Notes
* To ensure VPC Endpoint Service and NLB cannot be destroyed after creation, `prevent_destroy` lifecycle parameter
  must be set to true in `main.tf` for both resources (no interpolation allowed in lifecycle: https://github.com/hashicorp/terraform/issues/3116).
  Please have the following considerations in mind though: https://www.terraform.io/docs/configuration/resources.html#prevent_destroy
* All resources supporting tagging will be tagged accordingly to configuration, additionally target groups will be tagged with target_hostname
  to make identification easier.
* Creating targets with identical DNS name where only ports are different is supported for this module but may become problematic for automatically
  provisioning Route53 entries for related VPC Endpoint (see repository: <https://github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint>).
* For Terraform 0.12 changes in code will have to be made to accomodate new map syntax (https://www.terraform.io/docs/configuration/functions/map.html).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| common\_tag | Single tag to be assigned to each resource (that supports tagging) created by this module | map | `<map>` | no |
| dns\_server\_ip | IP of DNS server that will be used for resolution of targets (leave empty to attempt to use locally configured DNS server) | string | `""` | no |
| nlb\_name | The name of the LB. | string | n/a | yes |
| nlb\_subnets | A list of subnet IDs to attach to the LB | list | `<list>` | no |
| nlb\_vpc | The identifier of the VPC for NLB | string | n/a | yes |
| targets | List of services to be used as NLB targets, can be overriden | list | `<list>` | no |
| vpces\_acceptance\_required | Whether or not VPC endpoint connection requests to the service must be accepted by the service owner | string | `"true"` | no |
| vpces\_allowed\_principals | The ARNs of one or more principals allowed to discover the endpoint service | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| target\_dns\_names | List of DNS names passed as targets |
| target\_ips | List of IPs resolved from targets |
| nlb\_arn | The ARN of the Network Load Balancer |
| target\_s3\_bucket | ARN of S3 bucket with list of targets |
| target\_s3\_bucket\_key\_targets | Filename with comma-separated list of targets |
| vpces\_base\_endpoint\_dns\_names | The DNS names for the VPC endpoint service |
| vpces\_service\_name | Name of VPC Endpoint Service |

