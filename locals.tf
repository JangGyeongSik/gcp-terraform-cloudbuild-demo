locals {
  attached_disks = {
    for disk in var.attached_disks :
    disk.device_name => merge(disk, {
      options = disk.options == null ? var.attached_disks_default : disk.options
    })
  }
  attached_disk_zonal = {
    for k, v in local.attached_disks :
    k => v if try(v.options.replica_zone, null) == null
  }
  attached_disk_regional = {
    for k, v in local.attached_disks :
    k => v if try(v.options.replica_zone, null) != null
  }
  service_account_email = (
    var.service_account_create ? (
      length(google_service_account.service_account) > 0 ?
      google_service_account.service_account[0].email :
      null
    ) : var.service_account
  )
  on_host_maintenance = (
    var.scheduling_options.provisioning_model == "SPOT" || var.confidential_instance_config ?
    "TERMINATE" : "MIGRATE"
  )
  instance_termination_action = var.scheduling_options.provisioning_model == "SPOT" ? coalesce(var.scheduling_options.instance_termination_action, "STOP") : null
  automatic_restart           = var.scheduling_options.provisioning_model == "SPOT" ? false : null
  preemptible                 = var.scheduling_options.provisioning_model == "SPOT" ? true : null
}