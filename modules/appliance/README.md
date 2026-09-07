<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.45.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | app.terraform.io/NYL-Prod/apps-source/aws//modules/terraform-aws-ec2-instance | 1.1.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_volumes"></a> [additional\_volumes](#input\_additional\_volumes) | Additional EBS volumes to attach, keyed by an arbitrary name. type is restricted to gp2, gp3 or standard; size has no platform-imposed min/max beyond AWS's own per-type limits. snapshot\_id restores the volume from an existing EBS snapshot instead of creating it blank; size may be omitted when snapshot\_id is set. | <pre>map(object({<br/>    device_name = string<br/>    size        = optional(number)<br/>    snapshot_id = optional(string)<br/>    type        = optional(string, "gp3")<br/>  }))</pre> | `{}` | no |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Application ID governance tag. Must begin with APP-. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment (dev, qa, stage, prod or test). | `string` | n/a | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | EC2 instance configuration. | <pre>object({<br/>    iam_instance_profile        = string<br/>    instance_type               = string<br/>    key_name                    = optional(string)<br/>    monitoring                  = optional(bool, true)<br/>    name                        = string<br/>    strategic_ami_build         = string<br/>    strategic_os_type           = string<br/>    user_data                   = optional(string)<br/>    user_data_base64            = optional(string)<br/>    user_data_replace_on_change = optional(bool, false)<br/>    root_volume = object({<br/>      size = number<br/>      type = optional(string, "gp3")<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key alias ARN used to encrypt the root volume and any additional EBS volumes, provisioned via the dedicated KMS module and passed in by the calling application repository. Must be an alias ARN (not a raw key ARN). | `string` | n/a | yes |
| <a name="input_lob"></a> [lob](#input\_lob) | Account Name | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Primary network interface configuration. private\_ip is optional and forces the ENI to use that address instead of an auto-assigned one — e.g. to preserve the prior instance's private IP during a blue/green cutover. | <pre>object({<br/>    private_ip         = optional(string)<br/>    security_group_ids = set(string)<br/>    subnet_id          = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Application-specific tags, merged on top of mandatory governance tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resources"></a> [resources](#output\_resources) | Map of all resources created by this module. |
<!-- END_TF_DOCS -->
