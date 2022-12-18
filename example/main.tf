# Instance 1EA Verify
# Private IP, Net-Tags,Labels, Enable Delete Protection, Custom Metadata Settings(OSLogin, OSLogin2fa)
# Boot Disk(Image) - Ubuntu 20.04 LTS
# Scheduling Options STOP, Provisioning Model(STANDARD)
# Shield Configuration All True
module "compute_vm" {
  source = "../"

  #############
  ## General ## 
  #############
  create_template        = var.create_template
  service_account_create = var.service_account_create
  service_account        = var.service_account
  service_account_scopes = var.service_account_scopes
  project_id             = var.project_id
  instance_name          = var.instance_name
  labels                 = var.labels
  region                 = var.region
  zone                   = var.zone
  ###########################
  ## Machine Configuration ## 
  ###########################
  network_interface = var.network_interface
  tags              = var.tags
  hostname          = var.hostname
  can_ip_forward    = var.can_ip_forward
  machine_type      = var.machine_type
  enable_display    = var.enable_display
  #############################
  ## Confidential VM Service ##
  #############################
  confidential_instance_config = var.confidential_instance_config
  enable_deletion_protection   = var.enable_deletion_protection
  ###########
  ## Disks ##
  ###########
  boot_disk                = var.boot_disk
  shielded_instance_config = var.shielded_instance_config
  ################
  ## Management ##
  ################
  description        = var.description
  scheduling_options = var.scheduling_options
  metadata           = var.metadata
}