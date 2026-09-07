variable "name" {
  description = "Required appliance instance name. Supply at deployment time."
  type        = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "Supply a nonempty appliance name."
  }
}
variable "app_id" {
  description = "Application identifier for the mandatory appid tag."
  type        = string
  validation {
    condition     = can(regex("^APP-.+", var.app_id))
    error_message = "app_id must start with APP- and include an identifier."
  }
}
variable "environment" {
  description = "Deployment environment."
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod", "qa", "test"], var.environment)
    error_message = "Use dev, stage, prod, qa or test."
  }
}
variable "lob" {
  description = "Business/account label required by the source module. Not an AWS account selector."
  type        = string
}
variable "ami_id" {
  description = "Vendor-approved AMI in the target region; no image is guessed."
  type        = string
  validation {
    condition     = can(regex("^ami-([0-9a-f]{8}|[0-9a-f]{17})$", var.ami_id))
    error_message = "Supply a valid-format AMI ID; existence and licensing must be verified separately."
  }
}
variable "instance_type" {
  description = "Vendor-supported EC2 size/architecture. No lab-only micro restriction."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Supply an EC2 instance type in family.size format."
  }
}
variable "primary_network_interface" {
  description = "Existing management/data subnet and security groups. Does not create firewall rules."
  type = object({
    subnet_id          = string
    security_group_ids = set(string)
    private_ip         = optional(string)
    source_dest_check  = optional(bool, true)
  })
}
variable "additional_network_interfaces" {
  description = "Optional named interfaces. Supply positive unique device indexes and compatible subnets in the same AZ."
  type = map(object({
    subnet_id          = string
    security_group_ids = set(string)
    device_index       = number
    private_ip         = optional(string)
    source_dest_check  = optional(bool, true)
    description        = optional(string)
  }))
  default = {}
  validation {
    condition     = length(distinct([for eni in values(var.additional_network_interfaces) : eni.device_index])) == length(var.additional_network_interfaces) && alltrue([for eni in values(var.additional_network_interfaces) : eni.device_index >= 1 && floor(eni.device_index) == eni.device_index])
    error_message = "Extra interface device indexes must be unique positive integers."
  }
}
variable "root_block_device" {
  description = "Optional root override; null preserves AMI/default EBS settings. Confirm vendor disk requirements."
  type = object({
    volume_size           = number
    volume_type           = optional(string, "gp3")
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
    iops                  = optional(number)
    throughput            = optional(number)
  })
  default = null
}
variable "additional_volumes" {
  description = "Optional EBS disks. Attachment does not format or mount them in the appliance."
  type = map(object({
    device_name = string
    size        = optional(number)
    snapshot_id = optional(string)
    type        = optional(string, "gp3")
    kms_key_id  = optional(string)
    iops        = optional(number)
    throughput  = optional(number)
  }))
  default = {}
}
variable "instance_profile" {
  description = "Optional existing IAM instance-profile name; must be vendor-appropriate."
  type        = string
  default     = null
}
variable "key_name" {
  description = "Optional existing EC2 key-pair name; no key or SSH ingress is created."
  type        = string
  default     = null
}
variable "user_data" {
  description = "Optional vendor-specific bootstrap content. Do not place license secrets or passwords here; user data is persisted in state."
  type        = string
  default     = null
}
variable "user_data_replace_on_change" {
  description = "Whether bootstrap changes request EC2 replacement. False does not guarantee bootstrap re-execution."
  type        = bool
  default     = false
}
variable "monitoring" {
  description = "Enable detailed EC2 monitoring."
  type        = bool
  default     = false
}
variable "disable_api_termination" {
  description = "Optional termination protection; account for this in approved cleanup procedures."
  type        = bool
  default     = false
}
variable "tags" {
  description = "Additional tags; identity tags from this template take precedence."
  type        = map(string)
  default     = {}
}
