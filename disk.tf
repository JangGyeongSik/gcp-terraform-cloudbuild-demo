resource "google_compute_disk" "boot_disk" { ## Boot disk only can attach zonal persistent disk
  count    = var.create_template ? 0 : (var.boot_disk.source_type == "SNAPSHOT" || var.boot_disk.source_type == "IMAGE") ? 1 : 0
  project  = var.project_id
  zone     = var.zone
  name     = "disk-boot-${var.project_id}-${var.instance_name}" # "disk-boot" prefix for boot disk, "disk-" for attached disk
  size     = var.boot_disk.size
  type     = var.boot_disk.type
  image    = var.boot_disk.image
  snapshot = try(var.boot_disk.source, null)
  labels   = try(var.boot_disk.labels, null)
  dynamic "disk_encryption_key" {
    for_each = var.boot_disk.disk_encryption_key_raw != null || var.boot_disk.kms_key_self_link != null ? [""] : []
    content {
      raw_key           = try(var.boot_disk.disk_encryption_key_raw, null)
      kms_key_self_link = try(var.boot_disk.kms_key_self_link, null)
    }
  }
}

resource "google_compute_disk" "disks" {
  for_each = var.create_template ? {} : {
    for k, v in local.attached_disk_zonal :
    k => v if v.source_type != "EXISTING"
  }
  project  = var.project_id
  zone     = var.zone
  labels   = each.value.labels
  name     = "disk-${var.project_id}-${var.instance_name}-${each.key}"
  size     = each.value.size
  type     = each.value.options.type
  image    = each.value.source_type == "IMAGE" ? each.value.source : null
  snapshot = each.value.source_type == "SNAPSHOT" ? each.value.source : null
  dynamic "disk_encryption_key" {
    for_each = each.value.disk_encryption_key_raw != null || each.value.kms_key_self_link != null ? [""] : []
    content {
      raw_key           = try(each.value.disk_encryption_key_raw, null)
      kms_key_self_link = try(each.value.kms_key_self_link, null)
    }
  }
  
}

resource "google_compute_region_disk" "disks" {
  for_each = var.create_template ? {} : {
    for k, v in local.attached_disk_regional :
    k => v if v.source_type != "EXISTING"
  }
  project       = var.project_id
  labels        = each.value.labels
  name          = "disk-${var.project_id}-${var.instance_name}-${each.key}"
  region        = var.region
  replica_zones = [var.zone, each.value.options.replica_zone]
  size          = each.value.size
  type          = each.value.options.type
  # image = each.value.source_type == "IMAGE" ? each.value.source : null   # Image is not supported for regional disk
  snapshot = each.value.source_type == "SNAPSHOT" ? each.value.source : null
  dynamic "disk_encryption_key" {
    for_each = each.value.disk_encryption_key_raw != null || each.value.kms_key_self_link != null ? [""] : []
    content {
      raw_key           = try(each.value.disk_encryption_key_raw, null)
      kms_key_name      = try(each.value.kms_key_self_link, null)
    }
  }
}