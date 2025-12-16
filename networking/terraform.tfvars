# ------------------------------------------------------------------------------
# Project
# ------------------------------------------------------------------------------
project_id = "howler-prj" # Replace with your GCP project ID

# ------------------------------------------------------------------------------
# VPC Network (google_compute_network)
# ------------------------------------------------------------------------------
network_name            = "gke-vpc"
network_description     = "VPC network for DPDP infra"
routing_mode            = "REGIONAL"
auto_create_subnetworks = false

# ------------------------------------------------------------------------------
# Subnetwork (google_compute_subnetwork)
# ------------------------------------------------------------------------------
subnetwork_name          = "gke-subnet"
primary_ip_cidr_range    = "10.0.0.0/18"
region                   = "us-central1"
private_ip_google_access = true

# Secondary IP ranges for GKE
pod_range_name        = "k8s-pod-range"
pod_range_ip_cidr     = "10.48.0.0/14"
service_range_name    = "k8s-service-range"
service_range_ip_cidr = "10.52.0.0/20"

# ------------------------------------------------------------------------------
# Firewall Rule (google_compute_firewall)
# ------------------------------------------------------------------------------
firewall_rule_name     = "allow-ssh"
firewall_protocol      = "tcp"
firewall_ports         = ["22"]
firewall_source_ranges = ["0.0.0.0/0"] # In production, restrict this to your IP

# ------------------------------------------------------------------------------
# Cloud Router (google_compute_router)
# ------------------------------------------------------------------------------
router_name = "gke-router"

# ------------------------------------------------------------------------------
# Cloud NAT (google_compute_router_nat)
# ------------------------------------------------------------------------------
nat_name                           = "gke-nat"
nat_ip_allocate_option             = "AUTO_ONLY"
source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"