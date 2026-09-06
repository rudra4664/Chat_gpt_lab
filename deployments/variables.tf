variable "aws_region" { type = string }
variable "aws_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "A verified 12-digit AWS account ID is required."
  }
}
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Use dev, stage or prod."
  }
}
variable "app_id" { type = string }
variable "app_version" { type = string }
variable "vpc_cidr" { type = string }
variable "client_cidr" {
  type    = string
  default = null
  validation {
    condition     = var.client_cidr == null ? true : can(cidrnetmask(var.client_cidr)) && var.client_cidr != "0.0.0.0/0"
    error_message = "Supply a specific client IPv4 CIDR, not world-open access."
  }
}
variable "servers" {
  type = map(object({ instance_type = string, root_disk_gib = number }))
  validation {
    condition     = length(var.servers) == 1 && alltrue([for s in values(var.servers) : contains(["t2.micro"], s.instance_type) && s.root_disk_gib >= 8 && s.root_disk_gib <= 30])
    error_message = "Lab requires exactly one t2.micro instance with 8–30 GiB roots per environment."
  }
}

