output "resources" {
  description = "Map of all resources created by this module."
  value = {
    additional_volume_attachments = module.ec2.resources.additional_volume_attachments
    additional_volumes            = module.ec2.resources.additional_volumes
    instance                      = module.ec2.resources.instance
    primary_network_interface     = module.ec2.resources.primary_network_interface
  }
}
