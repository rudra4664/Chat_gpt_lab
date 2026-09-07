output "instances" {
  value = { for name, server in module.servers : name => {
    id         = server.resources.instance.id
    public_ip  = server.resources.instance.public_ip
    private_ip = server.resources.primary_network_interface.private_ip
    eni_id     = server.resources.primary_network_interface.id
  } }
}
