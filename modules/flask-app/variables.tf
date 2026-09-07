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
