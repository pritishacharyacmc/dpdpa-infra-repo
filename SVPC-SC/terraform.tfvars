region           = "asia-south1"
host_project_id  = "gcp-org-p-network-host"
host_subnet_cidr = "10.0.0.0/24" # Assuming 10.0.x.0/24 is 10.0.0.0/24

service_projects_config = {
"gcp-org-p-security" = {
    subnet_name = "security-subnet"
    subnet_cidr = "10.0.5.0/24"
  },
  "gcp-org-p-reporting" = {
    subnet_name = "reporting-subnet"
    subnet_cidr = "10.0.5.0/24"
  },
  "gcp-org-p-privacy-tools" = {
    subnet_name = "privacy-subnet"
    subnet_cidr = "10.0.4.0/24"
  },
  "gcp-org-p-non-confi-data" = {
    subnet_name = "non-confidential-subnet"
    subnet_cidr = "10.0.3.0/24"
  },
  "gcp-org-p-confi-data" = {
    subnet_name = "confidential-subnet"
    subnet_cidr = "10.0.2.0/24"
  },
  "gcp-org-p-governance" = {
    subnet_name = "data-gov-subnet"
    subnet_cidr = "10.0.1.0/24"
  }
}
