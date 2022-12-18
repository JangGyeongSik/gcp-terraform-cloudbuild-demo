#############
## General ## 
#############
create_template = false
project_id      = "gyeongsik-dev"
region          = "asia-northeast3"
instance_name   = "gce-demo-001"
labels = {
  "env" = "dev"
}
zone                      = "asia-northeast3-c" #기입시 Region + Zone으로 입력
allow_stopping_for_update = false
###########################
## Machine Configuration ##
###########################

machine_type   = "e2-micro"
enable_display = false
#############################
## Confidential VM Service ##
#############################

confidential_instance_config = false

###########
## Disks ##
###########
boot_disk = {
  auto_delete             = false
  device_name             = "gyeongsik-dev"
  disk_encryption_key_raw = null
  image                   = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20221121"
  kms_key_self_link       = null
  sha256                  = ""
  labels = {
    "env" = "dev"
  }
  size        = 20
  source      = ""
  source_type = "IMAGE"
  type        = "pd-ssd"
}

#############################
## Identity and API access ##
#############################
service_account_create = false
service_account        = "gyeongsik-tf-svc@gyeongsik-dev.iam.gserviceaccount.com"
service_account_scopes = ["cloud-platform"]

################
## Networking ##
################ 
tags           = ["iapssh", "internal-ingress"]
can_ip_forward = false
hostname       = null
network_interface = [{
  address = {
    external_ip = null
    internal_ip = null
  }
  nat                = false
  network            = "gyeongsik-dev"
  nic_type           = null
  stack_type         = "IPV4_ONLY"
  subnetwork         = "gyeongsik-dev"
  subnetwork_project = "gyeongsik-dev"
}]

##############
## Security ##
##############
# shielded_instance_config = null
shielded_instance_config = {
  enable_integrity_monitoring = true
  enable_secure_boot          = true
  enable_vtpm                 = true
}

################
## Management ##
################

description                = "enable descirption"
enable_deletion_protection = false
# reservation_affinity       = 
metadata = {
  enable-oslogin     = "true",
  enable-oslogin-2fa = "true"
}
# map('BusinessUnit','XYZ')
scheduling_options = {
  instance_termination_action = "STOP"
  provisioning_model          = "STANDARD"
}
