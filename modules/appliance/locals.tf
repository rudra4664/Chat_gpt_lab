locals {
  appliance_tags = merge(var.tags, {
    Name         = var.name
    appid        = var.app_id
    Environment  = var.environment
    ManagedBy    = "Terraform"
    WorkloadType = "appliance"
  })
}
