provider "google" {
  region = var.region
}

# ==========================================
# Host Project Resources
# ==========================================

# 1. Create the VPC Network in the Host Project
resource "google_compute_network" "shared_vpc" {
  name                    = "base-shared-vpc"
  project                 = var.host_project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# 2. Enable Shared VPC Host feature on the project
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

# 3. Create the Host Project's own subnet
resource "google_compute_subnetwork" "host_subnet" {
  name                     = "host-project-subnet"
  project                  = var.host_project_id
  network                  = google_compute_network.shared_vpc.id
  region                   = var.region
  ip_cidr_range            = var.host_subnet_cidr
  private_ip_google_access = true
}

# 4. Cloud Router (as shown in diagram)
resource "google_compute_router" "router" {
  name    = "shared-vpc-router"
  project = var.host_project_id
  region  = var.region
  network = google_compute_network.shared_vpc.id

  bgp {
    asn = 64514
  }
}

# 5. Cloud Cloud DNS Zone (as shown in diagram)
resource "google_dns_managed_zone" "private_zone" {
  name        = "shared-vpc-private-zone"
  project     = var.host_project_id
  dns_name    = "internal.example.com." # Replace with your desired domain
  description = "Private DNS zone for Shared VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.shared_vpc.id
    }
  }
}


# ==========================================
# Service Project Subnets & Attachments
# ==========================================

# Fetch project details to get project numbers for IAM
data "google_project" "service_projects" {
  for_each = var.service_projects_config
  project_id = each.key
}

# 6. Create Subnets for Service Projects *inside* the Host Project
resource "google_compute_subnetwork" "service_subnets" {
  for_each                 = var.service_projects_config
  name                     = each.value.subnet_name
  project                  = var.host_project_id
  network                  = google_compute_network.shared_vpc.id
  region                   = var.region
  ip_cidr_range            = each.value.subnet_cidr
  private_ip_google_access = true
}

# 7. Attach Service Projects to the Host Project
resource "google_compute_shared_vpc_service_project" "attachment" {
  for_each        = var.service_projects_config
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = each.key

  # Ensure host is enabled first
  depends_on = [google_compute_shared_vpc_host_project.host]
}

# 8. Grant 'Network User' role to Service Projects on their specific subnets
# This allows resources in the service project to use the subnet.
resource "google_compute_subnetwork_iam_member" "subnet_network_user" {
  for_each = var.service_projects_config

  project    = var.host_project_id
  region     = var.region
  subnetwork = google_compute_subnetwork.service_subnets[each.key].name
  role       = "roles/compute.networkUser"

  # Granting to the Google APIs Service Agent of the service project.
  # This is a common and recommended pattern.
  member = "serviceAccount:${data.google_project.service_projects[each.key].number}@cloudservices.gserviceaccount.com"
}

# Optional: Also grant to the default Compute Engine service account if needed for VMs
resource "google_compute_subnetwork_iam_member" "compute_sa_network_user" {
  for_each = var.service_projects_config

  project    = var.host_project_id
  region     = var.region
  subnetwork = google_compute_subnetwork.service_subnets[each.key].name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${data.google_project.service_projects[each.key].number}-compute@developer.gserviceaccount.com"
}
Get Host Project Number (Required for VPC-SC)
data "google_project" "host_project" {
  project_id = var.host_project_id
}

# 1. Access Policy
# NOTE: An Organization can only have ONE Access Policy.
# If one already exists, use 'data "google_access_context_manager_access_policy"' instead of creating a new one.
resource "google_access_context_manager_access_policy" "policy" {
  parent = "organizations/${var.organization_id}"
  title  = "my-org-policy"
}

# 2. Service Perimeter
resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/servicePerimeters/shared_vpc_perimeter"
  title  = "Shared VPC Secure Perimeter"
  
  status {
    # 2a. Restricted Services
    # Based on your diagram (GCS, BigQuery, KMS, GKE, AlloyDB, PubSub, Data Catalog, DLP)
    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com",
      "cloudkms.googleapis.com",
      "container.googleapis.com",
      "alloydb.googleapis.com",
      "pubsub.googleapis.com",
      "datacatalog.googleapis.com",
      "dlp.googleapis.com",
      "compute.googleapis.com" # Highly recommended to include Compute Engine
    ]

    # 2b. Resources protected by this perimeter
    # We include the Host Project AND all Service Projects
    resources = concat(
      ["projects/${data.google_project.host_project.number}"],
      [for p in data.google_project.service_projects : "projects/${p.number}"]
    )

    # 2c. Access Levels (Optional)
    # If you need to access these resources from your laptop (public internet), 
    # you must create an Access Level (e.g., allow specific IP) and list it here.
    # access_levels = [google_access_context_manager_access_level.my_access_level.name]
  }

  # Use 'depends_on' to ensure projects exist before adding them to the perimeter
  depends_on = [
    google_compute_shared_vpc_service_project.attachment
  ]
}