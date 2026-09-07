module "ec2" {
  source = "app.terraform.io/NYL-Prod/apps-resources/aws//modules/terraform-aws-ec2-instance"

  app_id             = var.app_id
  env                = var.env
  lob                = var.lob
  kms_key_id         = var.kms_key_id
  instance           = var.instance
  network            = var.network
  additional_volumes = var.additional_volumes
  tags               = var.tags
}
