# Flask application module: file guide

Terraform combines all .tf files in this directory into one module. This split changes organization only, not the inputs, resource addresses, startup script or outputs.

| File | Responsibility | Connection |
|---|---|---|
| variables.tf | Declares application inputs | deployments/main.tf passes values into these inputs |
| main.tf | Calls the resource module for each server | var.servers -> module.servers -> ../ec2-resource |
| outputs.tf | Returns server IDs and addresses | module.servers results -> application outputs -> deployment outputs |
| bootstrap.sh.tftpl | Renders the Flask startup script | main.tf templatefile() -> instance user_data |

There is no locals.tf because this module currently defines no local values. Add that file when derived or reused expressions are introduced; an empty file is unnecessary.

There is no provider configuration here. The AWS provider is configured in deployments/main.tf and inherited by child modules. The resource/source modules declare their AWS provider requirements. This application module only composes child modules and does not directly use AWS resources or data sources.

File names do not determine execution order. Dependencies come from references between inputs, modules and resources.
