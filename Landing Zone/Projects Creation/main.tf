# main.tf

# Configure the Google Cloud provider
provider "google" {
  # You can specify your project and region here, or through environment variables.
}

# Create multiple projects from a list of names
resource "google_project" "projects" {
  for_each = toset(var.project_names)

  name            = each.value
  project_id      = each.value
  folder_id       = var.folder_id
  billing_account = var.billing_account
}
# List of APIs to enable
variable "gcp_service_list" {
  description = "The list of apis to enable within the projects"
  type        = list(string)
  default = [
    "compute.googleapis.com",             # Compute Engine API
    "networkmanagement.googleapis.com",   # Network Management API
    "container.googleapis.com",           # GKE API
    "bigquery.googleapis.com",            # BigQuery API
    "monitoring.googleapis.com",          # Cloud Monitoring API
    "dataplex.googleapis.com",            # Cloud Dataplex API
    "cloudkms.googleapis.com"             # Cloud Key Management Service (KMS) API
  ]
}

# Create a map of project/service combinations
locals {
  project_services = merge([
    for proj_key, proj in google_project.projects : {
      for service in var.gcp_service_list :
      "${proj_key}-${service}" => {
        project_id = proj.project_id
        service    = service
      }
    }
  ]...)
}

# Enable the APIs
resource "google_project_service" "enabled_apis" {
  for_each = local.project_services

  project = each.value.project_id
  service = each.value.service

  # Prevents services from being disabled when the terraform resource is destroyed
  # Set to false if you want the APIs to be disabled when you run 'terraform destroy'
  disable_on_destroy = false
}