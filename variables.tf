/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#############
## Genaral ## 
#############

variable "create_template" {
  description = "Makes this resource to template if set to 'true' (default 'false')"
  type        = bool
  default     = false
}

variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "instance_name" {
  description = "The name of the instance being created"
  type        = string
}

variable "labels" {
  description = "The label to attach to the instance"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The region where instance being created"
  type        = string
  default     = "asia-northeast3"
}

variable "zone" {
  description = "The zone where instance being created"
  type        = string
}

variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance to update its properties. If you try to update a property that requires stopping the instance without setting this field, the update will fail."
  type        = bool
  default     = true
}

###########################
## Machine Configuration ##
###########################

variable "machine_type" {
  description = "The machine type to create"
  type        = string
}

variable "guest_accelerator" {
  description = "List of the type and count of accelerator cards attached to the instance"
  type = object({
    type  = string
    count = number
  })
  default = {
    count = 0
    type = "nvidia-tesla-k80"
  }
}

variable "enable_display" {
  description = "Enable Virtual Displays on this instance"
  type        = bool
  default     = false
}

#############################
## Confidential VM Service ##
#############################

variable "confidential_instance_config" {
  description = "Enable Confidential Mode on this VM"
  type        = bool
  default     = false
}

###########
## Disks ##
###########

variable "boot_disk" {
  description = "Boot disk properties"
  type = object({
    source_type = optional(string) # IMAGE , SNAPSHOT , EXISTING
    source      = optional(string) # For SNAPSHOT , EXISTING

    # For IMAGE
    image = optional(string, "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20221121") # Ubuntu 20.04 LTS x86/64

    # For IMAGE , SNAPSHOT  
    size   = optional(number, 10)
    type   = optional(string, "pd-balanced")
    labels = optional(map(string))

    disk_encryption_key_raw = optional(string) # Only one of kms_key_self_link and disk_encryption_key_raw may be set.
    kms_key_self_link       = optional(string)

    auto_delete = optional(bool, true)
    device_name = optional(string)
  })
}

variable "attached_disks_default" {
  description = "Defaults for attached disks options."
  type = object({
    auto_delete  = optional(bool, true)
    mode         = string
    type         = string
    replica_zone = string
  })
  default = {
    auto_delete  = true
    mode         = "READ_WRITE"
    replica_zone = null
    type         = "pd-balanced"
  }

  validation {
    condition     = var.attached_disks_default.mode == "READ_WRITE" || !var.attached_disks_default.auto_delete
    error_message = "auto_delete can only be specified on READ_WRITE disks."
  }
}

variable "attached_disks" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'IMAGE' (zonal disks in vms and template), 'SNAPSHOT' (vm), 'EXISTING', and null."
  type = list(object({
    device_name             = string
    size                    = number
    labels                  = optional(map(string))
    source                  = optional(string)
    source_type             = optional(string)
    disk_encryption_key_raw = optional(string)
    kms_key_self_link       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, true)
        mode         = string
        type         = string
        replica_zone = string
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )

  }))
  default = []

  validation {
    condition = length([
      for d in var.attached_disks : d if(
        d.source_type == null || contains(["IMAGE", "SNAPSHOT", "EXISTING"], coalesce(d.source_type, "1"))
      )
    ]) == length(var.attached_disks)

    error_message = "Source type must be one of 'IMAGE', 'SNAPSHOT', 'EXISTING', null."
  }

  validation {
    condition = length([
      for d in var.attached_disks : d if
      d.options == null || d.options.mode == "READ_WRITE" || !d.options.auto_delete
    ]) == length(var.attached_disks)

    error_message = "auto_delete can only be specified on READ_WRITE disks."
  }
}

variable "scratch_disk" {
  description = "Scratch disks configuration"
  type = object({
    count = number
    interface = string # NVME , SCSI
  })
  default = {
    count = 0 
    interface = "NVME"
  }
}

#############################
## Identity and API access ##
#############################

variable "service_account" {
  description = "Service account email. Unused if service account is auto-created."
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Scopes applied to service account."
  type        = list(string)
  default     = ["cloud-platform"] # Full access scope for default
}

variable "service_account_create" {
  description = "Auto-create service account"
  type        = bool
  default     = false
}

################
## Networking ##
################ 

variable "tags" {
  description = "Instance network tags for firewall rule targets."
  type        = list(string)
  default     = []
}

variable "hostname" {
  description = "A custom hostname for the instance. Must be a fully qualified DNS name and RFC-1035-valid"
  type        = string
  default     = ""
}

variable "can_ip_forward" {
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs"
  type        = bool
  default     = false
}

variable "network_interface" {
  description = "Network interfaces configuration. Set addresses to null if not needed."
  type = list(object({
    nat                = optional(bool, false)
    network            = optional(string)
    subnetwork         = optional(string)
    subnetwork_project = optional(string)
    address = optional(object({
      internal_ip = string # 예약한 IP주소의 주소값 (ex: "192.168.20.5")
      external_ip = string # 에약한 IP주소의 주소값 (ex: "35.178.28.5")
    }), null)
    alias_ip_range = optional(map(string), {}) # ex: {"subnetwork_range_name" = 10.172.0.0/24" " }
    nic_type       = optional(string)
    stack_type     = optional(string)
  }))
}

##############
## Security ##
##############

variable "shielded_instance_config" {
  description = "Shielded VM configuration of the instances."
  type = object({
    enable_secure_boot          = optional(bool)
    enable_vtpm                 = optional(bool)
    enable_integrity_monitoring = optional(bool)
  })
  default = null
}

################
## Management ##
################

variable "description" {
  description = "A brief description of this resource"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on this instance"
  type        = bool
  default     = false
}

variable "reservation_affinity" {
  description = "Specifies the reservations that this instance can consume from"
  type = object({
    type = string                            # ANY_RESERVATION , SPECIFIC_RESERVATION , NO_RESERVATION
    specific_reservation = optional(object({ # ex {"compute.googleapis.com/reservation-name" = "name of reservation"}
      key    = string
      values = list(string)
    }))
  })
  default = null
}

variable "startup_script" {
  description = "An alternative to using the startup-script metadata key, except this one forces the instance to be recreated (thus re-running the script) if it is changed"
  default     = ""
}

variable "metadata" {
  description = "Metadata key/value pairs to make available from within the instance"
  # Ssh keys attached in the Cloud Console will be removed. Add them to your config in order to keep them attached to your instance.
  type    = map(string)
  default = {}
}

variable "scheduling_options" {
  description = "Instance scheduling options"
  type = object({
    provisioning_model          = optional(string, "STANDARD") #STANDARD, SPOT
    instance_termination_action = optional(string)             # STOP, DELETE
  })
  default = {
    provisioning_model          = "STANDARD"
    instance_termination_action = ""
  }
}
