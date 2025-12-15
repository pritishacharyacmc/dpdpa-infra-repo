resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = var.network_name
  description             = var.network_description
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
}

resource "google_compute_subnetwork" "private" {
  project               = var.project_id
  name                  = var.subnetwork_name
  primary_ip_cidr_range = var.primary_ip_cidr_range
  region                = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = var.private_ip_google_access

  secondary_ip_range {
    range_name    = var.pod_range_name
    ip_cidr_range = var.pod_range_ip_cidr
  }

  secondary_ip_range {
    range_name    = var.service_range_name
    ip_cidr_range = var.service_range_ip_cidr
  }
}

resource "google_compute_firewall" "allow_ssh" {
  project = var.project_id
  name    = var.firewall_rule_name
  network = google_compute_network.main.name

  allow {
    protocol = var.firewall_protocol
    ports    = var.firewall_ports
  }

  source_ranges = var.firewall_source_ranges # In production, restrict this to your IP
}