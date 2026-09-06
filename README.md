# Inventory-driven Flask lab — GitHub + TFC VCS

Target: AWS 180840262641 / us-east-1, three t2.micro instances total (one per environment). TFC organization: my_terrafrom_org / Default Project.

## Flow
Inventory CSV + settings.json -> scripts/generate_deployments.py -> environments/{dev,stage,prod}/main.tf.json variable defaults -> GitHub commit -> TFC VCS plan -> review CI and plan -> confirm apply in browser -> AWS resources.

No TFC API token, API synchronization, or .tfvars files are used. The .tf.json files are Terraform configuration with variable declarations and defaults, not variable-value files. AWS OIDC authentication still requires two TFC environment variables; credentials must never be committed as defaults.

## Update the inventory
Run `python scripts/generate_deployments.py` after editing inventory/settings.json, inventory/servers.csv or application code. Commit both the source inventory and generated files. CI uses --check to reject stale output. CI does not commit changes automatically and does not automatically gate TFC apply; inspect its result before confirming apply.

## TFC configuration
Connect rudra4664/Chat_gpt_lab using VCS integration. Create flask-lab-dev, flask-lab-stage and flask-lab-prod in Default Project. Set Terraform working directory to environments/dev, environments/stage or environments/prod. Use remote execution, Terraform 1.15.7 and manual apply. Include shared module/application changes in run triggers (or trigger on all repository changes). Do not exclude parent directories from uploaded configuration.
Set environment variables TFC_AWS_PROVIDER_AUTH=true and TFC_AWS_RUN_ROLE_ARN to the applied bootstrap role ARN. Application inputs use committed defaults.

## Access
client_cidr=null means no inbound Flask rule is created. It has nothing to do with free-tier eligibility. Test privately with SSM port forwarding or set an approved public IPv4 /32 in inventory/settings.json and regenerate. No SSH port is opened. Public instance addresses are automatic and can change after stop/start.

## Components
- deployments/: shared environment infrastructure and input validation.
- modules/flask-app/: repeats resource wrapper and embeds Flask startup data.
- modules/ec2-resource/: lab adaptation of supplied organizational wrapper.
- modules/ec2-source/: adapted supplied EC2 implementation.
- bootstrap/: separately managed TFC OIDC trust and IAM role; local administrator execution only.
- .github/workflows/deploy.yml: Python tests, generated-file consistency and Terraform validation.

## Validation and limitations
The Dev root validates with AWS provider 6.45.0; a deprecation warning originates from the source module full-resource output. Inventory tests passed previously; CI rechecks all roots and Flask endpoints. No inference of live deployment should be made from static validation.
The original module repositories outside this lab are unchanged. Wrapper changes: local module reference, explicit Amazon Linux 2023 AMI, micro sizes, monitoring disabled, standard burst credits. Source uses EC2-managed primary networking with automatic public IPv4 instead of explicit primary ENI and EIPs; advanced primary ENI settings are not fully supported in this adaptation. AMI changes remain ignored by the original lifecycle rule.
Flask/Gunicorn starts via systemd bootstrap. User-data changes request replacement; this is not zero-downtime deployment. One AZ per environment; no database, load balancer or DNS cutover. All created resources require explicit cleanup after testing. Stopping EC2 retains storage. Do not run blanket destroy on shared or retained resources.

Bootstrap policy is region-scoped and IAM-name-scoped, but its EC2 permissions are not a complete resource-isolation boundary. Review before use in an account containing other workloads. Keep bootstrap state local and protected; do not publish it.

Source baselines: apps-source 24d81f6e5b7dc9ffce9f4a65ebe94da69fe39429; app-resources e0e86cddf0abcfca7b9d3ea2ed1b2e366916097e.
