resource "google_service_account" "service_account" {
  count       = var.service_account_create ? 1 : 0
  account_id  = "sa-vm-${var.instance_name}"
  project     = var.project_id
  description = "Auto generated Service account by terraform-google-compute-vm module"
}