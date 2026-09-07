locals {
  approved_instance_families = ["t3", "m7i", "c5", "c5a", "r5", "m5a", "m5", "m4", "t2", "r6i", "r7iz", "r6a"]
  denied_instance_sizes      = ["micro", "nano", "small"]
  effective_tags             = merge(var.tags, local.mandatory_tags)
  mandatory_tags = {
    appid = var.app_id
  }
}
