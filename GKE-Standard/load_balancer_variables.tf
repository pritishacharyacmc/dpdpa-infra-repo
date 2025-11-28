# load_balancer_variables.tf

variable "load_balancer_name" {
  description = "Base name for the load balancer and its components."
  type        = string
  default     = "gke-global-lb"
}

variable "domain_name" {
  description = "The domain name for the SSL certificate (e.g., myapp.example.com)."
  type        = string
}

variable "armor_policy_name" {
  description = "Name for the Cloud Armor security policy."
  type        = string
  default     = "gke-armor-policy"
}

variable "gke_neg_name" {
  description = "The name of the Network Endpoint Group created by the GKE service annotation."
  type        = string
}
