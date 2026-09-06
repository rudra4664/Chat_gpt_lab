variable "environment" { type = string }
variable "app_id" { type = string }
variable "app_version" { type = string }
variable "ami_id" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = set(string) }
variable "instance_profile" { type = string }
variable "kms_alias_arn" { type = string }
variable "servers" {
  type = map(object({ instance_type = string, root_disk_gib = number }))
}

module "servers" {
  for_each   = var.servers
  source     = "../ec2-resource"
  app_id     = var.app_id
  env        = var.environment
  lob        = "learning"
  kms_key_id = var.kms_alias_arn
  tags       = { Environment = var.environment, ManagedBy = "Terraform", Project = "flask-learning-lab" }
  network    = { subnet_id = var.subnet_id, security_group_ids = var.security_group_ids }
  instance = {
    name                        = "flask-${var.environment}-${each.key}"
    ami                         = var.ami_id
    instance_type               = each.value.instance_type
    iam_instance_profile        = var.instance_profile
    monitoring                  = false
    root_volume                 = { size = each.value.root_disk_gib, type = "gp3" }
    user_data_replace_on_change = true
    user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
      app_base64          = filebase64("${path.module}/../../app/app.py")
      requirements_base64 = filebase64("${path.module}/../../app/requirements.txt")
      environment         = var.environment
      app_version         = var.app_version
    })
  }
}

output "instances" {
  value = { for name, server in module.servers : name => {
    id         = server.resources.instance.id
    public_ip  = server.resources.instance.public_ip
    private_ip = server.resources.primary_network_interface.private_ip
    eni_id     = server.resources.primary_network_interface.id
  } }
}

