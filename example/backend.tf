# Terraform docs re: configuring back end: https://www.terraform.io/docs/backends/types/gcs.html
terraform {
  backend "gcs" {
    prefix  = "terraform/state"
    bucket = "terraform-cloud-build-demo-jgs"
//    bucket  = "" #these will be passed as backend-config variables in the terraform init. See cloubuild.yaml.
//    project = ""
  }
}