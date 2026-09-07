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
