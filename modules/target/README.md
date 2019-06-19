# A Terraform (sub)module to deploy listener for NLB and corresponding TargetGroup for a given target.

This submodule should be used to create targets for VPC Endpoint Service solution.
It was implemented to workaround `count` feature in Terraform that triggers unnecessary recreation of resources
when modifing list variable that is used to create multiple resources.

## Notes:
* this submodule requires `jq` and `dig` to be available (for DNS resolution of targets)
  and valid IP of DNS server configured (if empty local system default will be used)

## Usage

```hcl
module "target_unique_id" {
   source = "github.com/kentrikos/terraform-aws-shared-proxy-vpc-endpoint-service.git//modules/target?ref=GIT_RELEASE"

   target_hostname   = "FQDN"
   target_port       = "PORT_NUMBER"
   nlb_listener_port = "PORT_NUMBER"

   nlb_tg_vpc = "${var.nlb_vpc}"
   nlb_arn    = "${module.vpc-endpoint-services-nlb.nlb_arn}"

   common_tag = "${var.common_tag}"
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| common\_tag | Single tag to be assigned to each resource (that supports tagging) created by this module | map | `<map>` | no |
| dns\_server\_ip | IP of DNS server that will be used for resolution of targets (leave empty to attempt to use locally configured DNS server) | string | `""` | no |
| nlb\_arn | The arn of existing NLB to be used | string | n/a | yes |
| nlb\_listener\_port | TCP port number to be used on NLB listener for this target | string | n/a | yes |
| nlb\_tg\_vpc | The identifier of the VPC for NLB target group | string | n/a | yes |
| target\_hostname | Hostname of the target | string | n/a | yes |
| target\_port | TCP port number of the target | string | n/a | yes |

