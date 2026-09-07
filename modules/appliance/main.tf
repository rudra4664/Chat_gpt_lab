# Reuse the ORIGINAL supplied EC2 implementation, pinned for reproducibility.
# The Flask-specific lab adaptation forces public addressing and is unsuitable
# as a generic appliance base. The existing NYL wrapper forces strategic AMIs.
module "ec2" {
  source      = "git::https://github.com/rudra4664/terraform-aws-apps-source.git//modules/terraform-aws-ec2-instance?ref=24d81f6e5b7dc9ffce9f4a65ebe94da69fe39429"
  env         = var.environment
  lob         = var.lob
  tags        = local.appliance_tags
  volume_tags = local.appliance_tags
  instance = {
    name                        = var.name
    ami                         = var.ami_id
    instance_type               = var.instance_type
    use_strategic_ami           = false
    iam_instance_profile        = var.instance_profile
    key_name                    = var.key_name
    monitoring                  = var.monitoring
    disable_api_termination     = var.disable_api_termination
    user_data                   = var.user_data
    user_data_replace_on_change = var.user_data_replace_on_change
    root_block_device           = var.root_block_device
  }
  primary_network_interface     = var.primary_network_interface
  additional_network_interfaces = var.additional_network_interfaces
  additional_volumes            = var.additional_volumes
}
