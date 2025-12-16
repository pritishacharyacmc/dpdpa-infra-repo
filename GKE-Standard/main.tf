# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

data "google_project" "service_project" {
  project_id = var.svc_project_id
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.svc_project_id
  network_project_id         = var.host_project_id
  name                       = var.gke_cluster.name
  regional                   = true
  region                     = var.gke_cluster.region
  #zones                      = var.gke_cluster.zones
  network                    = var.gke_cluster.vpc.vpc_name
  subnetwork                 = var.gke_cluster.vpc.vpc_subnet
  ip_range_pods              = var.gke_cluster.vpc.vpc_sec_pod
  ip_range_services          = var.gke_cluster.vpc.vpc_sec_svc
  configure_ip_masq          = var.configure_ip_masq
  network_policy             = true
  horizontal_pod_autoscaling = true
  enable_private_endpoint    = false
  enable_private_nodes       = true
  master_ipv4_cidr_block     = var.gke_cluster.master_ipv4_cidr_block
  remove_default_node_pool   = true
  create_service_account     = false
  master_authorized_networks = var.gke_cluster.master_authorized_networks
  node_pools                 = var.gke_cluster.node_pool
  depends_on                 = [google_compute_subnetwork_iam_member.member]
}

resource "google_compute_subnetwork_iam_member" "member" {
  project    = var.host_project_id
  region     = var.gke_cluster.region
  subnetwork = var.gke_cluster.vpc.vpc_subnet
  role       = "roles/compute.networkUser"
  member     = format("serviceAccount:%s@cloudservices.gserviceaccount.com", data.google_project.service_project.number)
}
