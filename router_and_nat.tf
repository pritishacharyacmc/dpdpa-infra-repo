
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  name    = var.router.name
  project = var.host_project_id
  region  = var.router.region
  network = var.router.network
}

module "cloud-nat" {
  depends_on                         = [module.cloud_router]
  source                             = "terraform-google-modules/cloud-nat/google"
  project_id                         = var.host_project_id
  region                             = var.router.region
  router                             = var.router.name
  name                               = var.router.nat_name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetworks = [{
    name                     = "https://www.googleapis.com/compute/v1/projects/${var.host_project_id}/regions/${var.router.region}/subnetworks/${var.router.subnet}"
    source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
    secondary_ip_range_names = []
  }]
}
