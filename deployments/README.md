# Shared deployment module: file guide

All .tf files in this directory form one Terraform module. Splitting them does not change resource addresses, dependencies, input values or behavior.

| File | Responsibility | Connection |
|---|---|---|
| providers.tf | Terraform/AWS provider requirements, region, account restriction and default tags | variables.tf -> AWS provider configuration inherited by child modules |
| variables.tf | Input types and validation | environments/dev, stage or prod defaults -> this module's inputs |
| data.tf | Look up availability zones, Amazon Linux AMI and EBS KMS alias | Lookups -> network.tf and main.tf |
| network.tf | VPC, subnet, internet gateway, routes and security groups | Network IDs -> main.tf application inputs |
| iam.tf | EC2 role, SSM policy attachment and instance profile | Instance profile name -> main.tf -> Flask module -> EC2 |
| main.tf | Compose the application module | Inputs + network + IAM + lookups -> ../modules/flask-app |
| outputs.tf | Return server details and URLs | Application outputs -> environment root outputs -> TFC |

No locals.tf is needed because the deployment module has no locals block. The generated environment roots remain under environments/; this refactor only reorganizes the shared deployments directory. File order does not determine execution order; references and depends_on establish dependencies.
