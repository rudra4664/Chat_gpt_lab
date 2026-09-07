module "ec2" {
  source  = "app.terraform.io/NYL-Prod/apps-source/aws//modules/terraform-aws-ec2-instance"
  version = "1.1.2"
  env     = var.env
  lob     = var.lob
  tags    = local.effective_tags

  additional_volumes = {
    for k, v in var.additional_volumes : k => {
      device_name = v.device_name
      kms_key_id  = var.kms_key_id
      size        = v.size
      snapshot_id = v.snapshot_id
      tags        = local.effective_tags
      type        = v.type
    }
  }

  instance = {
    iam_instance_profile        = var.instance.iam_instance_profile
    instance_type               = var.instance.instance_type
    key_name                    = var.instance.key_name
    monitoring                  = var.instance.monitoring
    name                        = var.instance.name
    strategic_ami_build         = var.instance.strategic_ami_build
    strategic_os_type           = var.instance.strategic_os_type
    use_strategic_ami           = true
    user_data                   = var.instance.user_data
    user_data_base64            = var.instance.user_data_base64
    user_data_replace_on_change = var.instance.user_data_replace_on_change

    root_block_device = {
      encrypted   = true
      kms_key_id  = var.kms_key_id
      volume_size = var.instance.root_volume.size
      volume_type = var.instance.root_volume.type
    }
  }

  primary_network_interface = {
    private_ip         = var.network.private_ip
    security_group_ids = var.network.security_group_ids
    subnet_id          = var.network.subnet_id
  }
}
