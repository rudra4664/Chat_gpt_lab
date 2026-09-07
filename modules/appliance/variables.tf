variable "additional_volumes" {
  description = "Additional EBS volumes to attach, keyed by an arbitrary name. type is restricted to gp2, gp3 or standard; size has no platform-imposed min/max beyond AWS's own per-type limits. snapshot_id restores the volume from an existing EBS snapshot instead of creating it blank; size may be omitted when snapshot_id is set."
  type = map(object({
    device_name = string
    size        = optional(number)
    snapshot_id = optional(string)
    type        = optional(string, "gp3")
  }))
  default = {}
}

variable "app_id" {
  description = "Application ID governance tag. Must begin with APP-."
  type        = string
}

variable "env" {
  description = "Environment (dev, qa, stage, prod or test)."
  type        = string
}

variable "instance" {
  description = "EC2 instance configuration."
  type = object({
    iam_instance_profile        = string
    instance_type               = string
    key_name                    = optional(string)
    monitoring                  = optional(bool, true)
    name                        = string
    strategic_ami_build         = string
    strategic_os_type           = string
    user_data                   = optional(string)
    user_data_base64            = optional(string)
    user_data_replace_on_change = optional(bool, false)
    root_volume = object({
      size = number
      type = optional(string, "gp3")
    })
  })
}

variable "kms_key_id" {
  description = "KMS key alias ARN used to encrypt the root volume and any additional EBS volumes, provisioned via the dedicated KMS module and passed in by the calling application repository. Must be an alias ARN (not a raw key ARN)."
  type        = string
}

variable "lob" {
  description = "Account Name"
  type        = string
}

variable "network" {
  description = "Primary network interface configuration. private_ip is optional and forces the ENI to use that address instead of an auto-assigned one — e.g. to preserve the prior instance's private IP during a blue/green cutover."
  type = object({
    private_ip         = optional(string)
    security_group_ids = set(string)
    subnet_id          = string
  })
}

variable "tags" {
  description = "Application-specific tags, merged on top of mandatory governance tags."
  type        = map(string)
  default     = {}
}
