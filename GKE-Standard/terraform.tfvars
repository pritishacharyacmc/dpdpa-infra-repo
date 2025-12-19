# terraform.tfvars

# --- General Settings ---
project_id = "your-gcp-project-id"   # <-- Replace
region     = "asia-south1"           # <-- Replace
network    = "default"               # <-- Replace if you have a custom VPC
subnetwork = "default"               # <-- Replace if you have a custom VPC

# --- GKE Settings ---
gke_cluster_name = "consentium-gke-cluster"
gke_node_count   = 2
gke_machine_type = "e2-medium"

# --- Load Balancer & Armor Settings ---
load_balancer_name = "consentium-gke-lb"
domain_name        = "your.domain.com"      # <-- IMPORTANT: Replace with your domain
armor_policy_name  = "consentium-gke-armor-policy"
gke_neg_name       = "consentium-gke-app-neg"       # <-- This must match the name in the app_deployment.yaml