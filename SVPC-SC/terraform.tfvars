region           = "us-central1"
host_project_id  = "your-network-host-project-id"
host_subnet_cidr = "10.0.0.0/24" # Assuming 10.0.x.0/24 is 10.0.0.0/24

service_projects_config = {
  "your-security-service-project-id" = {
    subnet_name = "security-subnet"
    subnet_cidr = "10.0.6.0/24"
  },
  "your-reporting-service-project-id" = {
    subnet_name = "reporting-subnet"
    subnet_cidr = "10.0.5.0/24"
  },
  "your-privacy-tool-project-id" = {
    subnet_name = "privacy-subnet"
    subnet_cidr = "10.0.4.0/24"
  },
  "your-non-confidential-data-project-id" = {
    subnet_name = "non-confidential-subnet"
    subnet_cidr = "10.0.3.0/24"
  },
  "your-confidential-data-project-id" = {
    subnet_name = "confidential-subnet"
    subnet_cidr = "10.0.2.0/24"
  },
  "your-data-gov-service-project-id" = {
    subnet_name = "data-gov-subnet"
    subnet_cidr = "10.0.1.0/24"
  }
}
