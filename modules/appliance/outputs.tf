output "instance_id" {
  description = "Created appliance instance ID."
  value       = module.ec2.resources.instance.id
}
output "private_ip" {
  description = "Primary interface private IPv4 address."
  value       = module.ec2.resources.primary_network_interface.private_ip
}
output "primary_network_interface_id" {
  value = module.ec2.resources.primary_network_interface.id
}
output "additional_network_interface_ids" {
  value = { for name, eni in module.ec2.resources.additional_network_interfaces : name => eni.id }
}
output "additional_volume_ids" {
  value = { for name, disk in module.ec2.resources.additional_volumes : name => disk.id }
}
