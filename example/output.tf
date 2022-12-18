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

output "external_ip" {
  description = "Instance main interface external IP addresses."
  value       = module.compute_vm.external_ip
}

output "instance" {
  description = "Instance resource."
  value       = module.compute_vm.instance
  sensitive   = true
}

output "internal_ip" {
  description = "Instance main interface internal IP address."
  value       = module.compute_vm.internal_ip
}

output "internal_ips" {
  description = "Instance interfaces internal IP addresses."
  value       = module.compute_vm.internal_ips
}

output "self_link" {
  description = "Instance self links."
  value       = module.compute_vm.self_link
}

output "service_account" {
  description = "Service account resource."
  value       = module.compute_vm.service_account
}

output "service_account_email" {
  description = "Service account email."
  value       = module.compute_vm.service_account_email
}

output "service_account_iam_email" {
  description = "Service account email."
  value       = module.compute_vm.service_account_iam_email
}

# output "template" {
#   description = "Template resource."
#   value       = module.compute_vm.template
# }

# output "template_name" {
#   description = "Template name."
#   value       = module.compute_vm.template_name
# }