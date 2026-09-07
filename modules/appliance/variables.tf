variable "additional_volumes" {
  description = "Additional EBS volumes to attach, keyed by an arbitrary name. type is restricted to gp2, gp3 or standard; size has no platform-imposed min/max beyond AWS's own per-type limits. snapshot_id restores the volume from an existing EBS snapshot instead of creating it blank; size may be omitted when snapshot_id is set."
  type = map(object({
    device_name = string
    size        = optional(number)
    snapshot_id = optional(string)
    type        = optional(string, "gp3")
  }))
  default = {}
  validation {
    condition = alltrue([
      for v in values(var.additional_volumes) : contains(["gp2", "gp3", "standard"], v.type)
    ])
    error_message = "Additional volume type must be one of: gp2, gp3, standard."
  }
  validation {
    condition = alltrue([
      for v in values(var.additional_volumes) : v.snapshot_id != null || v.size != null
    ])
    error_message = "Additional volume size must be specified when snapshot_id is not provided."
  }
  validation {
    condition = alltrue([
      for v in values(var.additional_volumes) : (
        v.size == null ||
        (
          v.size >= 1 &&
          (
            (v.type == "standard" && v.size <= 1024) ||
            (contains(["gp2", "gp3"], v.type) && v.size <= 16384)
          )
        )
      )
    ])
    error_message = "Additional volume size must be within the AWS-supported range for its type (gp2/gp3: 1-16384 GiB, standard: 1-1024 GiB)."
  }
}

variable "app_id" {
  description = "Application ID governance tag. Must begin with APP-."
  type        = string
  validation {
    condition     = can(regex("^APP-", var.app_id))
    error_message = "app_id must begin with APP-."
  }
}

variable "env" {
  description = "Environment (dev, qa, stage, prod or test)."
  type        = string
  validation {
    condition     = contains(["dev", "qa", "stage", "prod", "test"], lower(var.env))
    error_message = "env must be one of: dev, qa, stage, prod or test."
  }
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
  validation {
    condition     = length(trimspace(var.instance.name)) > 0
    error_message = "instance.name must not be empty."
  }
  validation {
    condition = (
      length(split(".", var.instance.instance_type)) == 2 &&
      contains(local.approved_instance_families, split(".", var.instance.instance_type)[0]) &&
      !contains(local.denied_instance_sizes, split(".", var.instance.instance_type)[1])
    )
    error_message = "instance.instance_type must use an approved family (${join(", ", local.approved_instance_families)}) and must not be a nano, micro or small size."
  }
  validation {
    condition     = length(trimspace(var.instance.iam_instance_profile)) > 0
    error_message = "instance.iam_instance_profile must not be empty."
  }
  validation {
    condition     = length(trimspace(var.instance.strategic_os_type)) > 0
    error_message = "instance.strategic_os_type must not be empty."
  }
  validation {
    condition     = length(trimspace(var.instance.strategic_ami_build)) > 0
    error_message = "instance.strategic_ami_build must not be empty."
  }
  validation {
    condition     = var.instance.user_data == null || var.instance.user_data_base64 == null
    error_message = "Specify either instance.user_data or instance.user_data_base64, not both."
  }
  validation {
    condition     = contains(["gp2", "gp3", "standard"], var.instance.root_volume.type)
    error_message = "instance.root_volume.type must be one of: gp2, gp3, standard."
  }
  validation {
    condition = (
      var.instance.root_volume.size >= 1 &&
      (
        (var.instance.root_volume.type == "standard" && var.instance.root_volume.size <= 1024) ||
        (contains(["gp2", "gp3"], var.instance.root_volume.type) && var.instance.root_volume.size <= 16384)
      )
    )
    error_message = "instance.root_volume.size must be within the AWS-supported range for the selected type (gp2/gp3: 1-16384 GiB, standard: 1-1024 GiB)."
  }
}

variable "kms_key_id" {
  description = "KMS key alias ARN used to encrypt the root volume and any additional EBS volumes, provisioned via the dedicated KMS module and passed in by the calling application repository. Must be an alias ARN (not a raw key ARN)."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:\\d{12}:alias/", var.kms_key_id))
    error_message = "kms_key_id must be a valid KMS alias ARN (arn:aws:kms:<region>:<account-id>:alias/<name>) — raw key ARNs (key/<uuid>) are not accepted since their ID carries no name to validate."
  }
}

variable "lob" {
  description = "Account Name"
  type        = string
  validation {
    condition     = length(trimspace(var.lob)) > 0
    error_message = "lob must not be empty."
  }
}

variable "network" {
  description = "Primary network interface configuration. private_ip is optional and forces the ENI to use that address instead of an auto-assigned one — e.g. to preserve the prior instance's private IP during a blue/green cutover."
  type = object({
    private_ip         = optional(string)
    security_group_ids = set(string)
    subnet_id          = string
  })
  validation {
    condition     = can(regex("^subnet-[a-z0-9]+$", var.network.subnet_id))
    error_message = "network.subnet_id must be a valid AWS subnet ID (e.g. subnet-0123456789abcdef0)."
  }
  validation {
    condition     = length(var.network.security_group_ids) > 0
    error_message = "At least one security group must be specified in network.security_group_ids."
  }
  validation {
    condition     = var.network.private_ip == null || can(cidrhost("${var.network.private_ip}/32", 0))
    error_message = "network.private_ip must be a valid IPv4 address."
  }
}

variable "tags" {
  description = "Application-specific tags, merged on top of mandatory governance tags."
  type        = map(string)
  default     = {}
}
