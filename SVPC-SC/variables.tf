variable "region" {
  description = "The Google Cloud region for the subnets."
  type        = string
  default     = "us-central1"
}

variable "host_project_id" {
  description = "The ID of the Shared VPC Host Project."
  type        = string
}

# Map of service projects and their corresponding subnet configuration
variable "service_projects_config" {
  description = "A map where keys are service project IDs and values are objects containing subnet CIDR and name."
  type = map(object({
    subnet_name = string
    subnet_cidr = string
  }))
}

variable "host_subnet_cidr" {
  description = "The CIDR range for the subnet in the host project."
  type        = string
  default     = "10.0.0.0/24" # Assumed from "10.0.x.0/24"
}
variable "organization_id" {
  description = "The numeric ID of the Google Cloud Organization."
  type        = string
}

# (Keep previous variables: region, host_project_id, service_projects_config, host_subnet_cidr)