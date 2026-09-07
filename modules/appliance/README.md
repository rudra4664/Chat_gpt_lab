# Generic appliance application template

Status: reusable infrastructure scaffold, not a vendor-certified appliance deployment. No appliance AMI, license, network values or sizing have been invented. This module is not called by the Flask environments and will not launch an appliance merely by being committed.

## File-by-file flow

| File | Meaning | Scenario / connection |
|---|---|---|
| providers.tf | Declares Terraform and AWS provider requirements | Deployment root supplies region, account restriction and AWS authentication |
| variables.tf | Required identity/image/network inputs and optional capabilities | Appliance owner provides an AMI; its value becomes var.ami_id |
| locals.tf | Computes mandatory identity tags | Caller tags merge with name/appid/environment; mandatory values win |
| main.tf | Calls the original EC2 source module | var.ami_id -> module.ec2 instance.ami -> original source ec2.tf |
| outputs.tf | Exposes minimal operational identifiers | Instance and ENI IDs return to a future deployment root |

The original supplied source repository is pinned to commit 24d81f6e5b7dc9ffce9f4a65ebe94da69fe39429. This template directly composes that source; it does not use the NYL resource wrapper because that wrapper forces NYL image selection. It also does not use the Flask lab's modified source because that version forces public addressing. If your organization requires a resource-wrapper layer, introduce an appliance-compatible governed wrapper after the actual appliance requirements are known.

## What it builds

One EC2 instance, one separately managed primary ENI, optional additional ENIs/attachments, and optional encrypted additional EBS volumes/attachments. It references an existing subnet, security groups, optional instance profile and optional KMS keys. It creates no VPC, firewall rules, route changes, public IP association, vendor license or appliance-specific configuration. One future module call per appliance, or a caller for_each, provides repetition.

## Required values later

name, app_id (APP-*), environment, lob, ami_id, instance_type, primary_network_interface.subnet_id, and primary_network_interface.security_group_ids. These have no defaults: they are deployment decisions, not template-author guesses. Put non-secret values in your future environment root variable defaults as requested; no .tfvars or TFC API is required.

Optional inputs: extra interfaces, extra disks, root disk overrides, IAM profile, EC2 key, vendor bootstrap, detailed monitoring and termination protection. source_dest_check defaults true; set false on the relevant interfaces only for an appliance that must forward traffic. This alone does not configure forwarding or routes.

## Before creating a real appliance deployment

- Confirm vendor, regional AMI owner/ID, Marketplace subscription/license and instance architecture/size.
- Confirm interface count/device ordering, same-AZ subnet compatibility and EC2 interface limits. Extra ENIs attach after EC2 creation; some appliances require all interfaces at launch and therefore need a source-module change.
- Confirm vendor support for IMDSv2 and hop limit 1: the source enforces them.
- The source ignores AMI changes, so an image upgrade alone does not roll out a replacement. Define a deliberate vendor-supported upgrade process.
- Confirm root encryption when root_block_device is null: this template leaves the AMI/account defaults in effect. Pass an explicit encrypted override where required.
- Define vendor bootstrap, licensing, disk mount behavior, health checks, HA, routing and cutover separately. Generic EC2 success does not verify appliance readiness.
- User data is not a secret store; do not commit credentials/license tokens or assume sensitive marking removes them from Terraform state.

## Validation

Terraform init/validate can check this module without supplying real deployment values. They cannot verify vendor compatibility, license acceptance, AMI existence or runtime health. Missing required values are intentionally not replaced by sample production-looking values.
