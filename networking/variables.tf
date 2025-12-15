variable "project_id" {
  description = "The ID of the project where resources will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "network_description" {
  description = "A description for the VPC network."
  type        = string
}

variable "routing_mode" {
  description = "The routing mode for the VPC network."
  type        = string
}

variable "auto_create_subnetworks" {
  description = "When set to true, a subnet for each region will be created automatically."
  type        = bool
}

variable "subnetwork_name" {
  description = "The name of the subnetwork."
  type        = string
}

variable "primary_ip_cidr_range" {
  description = "The primary IP range for the subnetwork."
  type        = string
}

variable "region" {
  description = "The region for the subnetwork."
  type        = string
}

variable "private_ip_google_access" {
  description = "Enable private Google access for the subnetwork."
  type        = bool
}

variable "pod_range_name" {
  description = "The name of the secondary IP range for GKE pods."
  type        = string
}

variable "pod_range_ip_cidr" {
  description = "The IP range for GKE pods."
  type        = string
}

variable "service_range_name" {
  description = "The name of the secondary IP range for GKE services."
  type        = string
}

variable "service_range_ip_cidr" {
  description = "The IP range for GKE services."
  type        = string
}

variable "firewall_rule_name" {
  description = "The name of the firewall rule."
  type        = string
}

variable "firewall_protocol" {
  description = "The protocol for the firewall rule."
  type        = string
}

variable "firewall_ports" {
  description = "The list of ports for the firewall rule."
  type        = list(string)
}

variable "firewall_source_ranges" {
  description = "The source IP ranges for the firewall rule."
  type        = list(string)
}

variable "router_name" {
  description = "The name of the router."
  type        = string
}

variable "nat_name" {
  description = "The name of the NAT gateway."
  type        = string
}

variable "nat_ip_allocate_option" {
  description = "The option for allocating NAT IPs."
  type        = string
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Specifies which subnetwork IP ranges can use NAT."
  type        = string
}