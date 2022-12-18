resource "google_compute_instance" "instance" {

  #############
  ## General ## 
  #############

  count                     = var.create_template ? 0 : 1
  project                   = var.project_id
  name                      = "vm-${var.project_id}-${var.instance_name}"
  labels                    = var.labels
  zone                      = var.zone
  allow_stopping_for_update = var.allow_stopping_for_update

  ###########################
  ## Machine Configuration ##
  ###########################

  machine_type = var.machine_type
  guest_accelerator {
    type  = var.guest_accelerator.type
    count = var.guest_accelerator.count
  }
  enable_display = var.enable_display

  #############################
  ## Confidential VM Service ##
  #############################

  dynamic "confidential_instance_config" {
    for_each = var.confidential_instance_config ? [""] : []
    content {
      enable_confidential_compute = true
    }
  }

  ###########
  ## Disks ##
  ###########

  boot_disk {
    auto_delete = var.boot_disk.auto_delete
    device_name = var.boot_disk.device_name
    source      = var.boot_disk.source_type == "EXISTING" ? var.boot_disk.source : google_compute_disk.boot_disk.0.name 
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk_zonal
    iterator = config
    content {
      source = (
        config.value.source_type == "EXISTING"
        ? config.value.source_type : google_compute_disk.disks[config.key].self_link
      )
      mode        = config.value.options.mode
      device_name = config.value.device_name
    }
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk_regional
    iterator = config
    content {
      source = (
        config.value.source_type == "EXISTING"
        ? config.value.source_type : google_compute_region_disk.disks[config.key].self_link
      )
      mode        = config.value.options.mode
      device_name = config.value.device_name 
    }
  }

  dynamic "scratch_disk" {
    for_each = [
      for i in range(var.scratch_disk.count) : var.scratch_disk.interface
    ]    
    iterator = config
    content {
      interface = config.value
    }
  }



  #############################
  ## Identity and API access ##
  #############################

  service_account {
    email  = local.service_account_email
    scopes = var.service_account_scopes
  }

  ################
  ## Networking ##
  ################ 

  tags           = var.tags
  hostname       = var.hostname
  can_ip_forward = var.can_ip_forward
  # network_performance_config 
  dynamic "network_interface" {
    for_each = var.network_interface
    iterator = config
    content {
      network            = config.value.network
      subnetwork         = config.value.subnetwork
      subnetwork_project = config.value.subnetwork_project
      network_ip         = try(config.value.address.internal_ip, null)
      dynamic "access_config" {
        for_each = config.value.nat ? [""] : []
        content {
          nat_ip = try(config.value.address.external_ip, null)
        }
      }
      dynamic "alias_ip_range" {
        for_each = config.value.alias_ip_range
        iterator = config_alias
        content {
          subnetwork_range_name = config_alias.key
          ip_cidr_range         = config_alias.value
        }
      }
      nic_type   = config.value.nic_type
      stack_type = config.value.stack_type
    }
  }

  ##############
  ## Security ##
  ##############

  dynamic "shielded_instance_config" {
    for_each = var.shielded_instance_config != null ? [var.shielded_instance_config] : []
    iterator = config
    content {
      enable_secure_boot          = config.value.enable_secure_boot
      enable_vtpm                 = config.value.enable_vtpm
      enable_integrity_monitoring = config.value.enable_integrity_monitoring
    }
  }

  ################
  ## Management ##
  ################

  description = var.description

  deletion_protection = var.enable_deletion_protection

  metadata_startup_script = var.startup_script

  metadata = var.metadata

  scheduling {
    automatic_restart           = local.automatic_restart
    preemptible                 = local.preemptible
    on_host_maintenance         = local.on_host_maintenance
    provisioning_model          = var.scheduling_options.provisioning_model
    instance_termination_action = local.instance_termination_action
  }
}



