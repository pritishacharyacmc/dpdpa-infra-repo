# gke_variables.tf

variable "project_id" {
  description = "The GCP project ID to deploy all resources."
  type        = string
}

variable "region" {
  description = "The GCP region for the GKE cluster."
  type        = string
}

variable "network" {
  description = "The VPC network to deploy the GKE cluster in."
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to deploy the GKE cluster in."
  type        = string
}

variable "gke_cluster_name" {
  description = "Name for the GKE cluster."
  type        = string
  default     = "primary-gke-cluster"
}

variable "gke_node_count" {
  description = "Number of nodes in the GKE node pool."
  type        = number
  default     = 2
}

variable "gke_machine_type" {
  description = "Machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}
