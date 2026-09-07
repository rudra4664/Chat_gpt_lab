output "instances" { value = module.application.instances }
output "urls" { value = { for name, server in module.application.instances : name => "http://${server.public_ip}:8080" } }
