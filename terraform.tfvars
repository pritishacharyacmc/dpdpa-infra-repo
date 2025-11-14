#Insert the project ID for the Host Project and Service Project Created in the Previous Step
svc_project_id = "inlzgke1-testplayground" #Service Project where the GKE cluster will be Created

host_project_id = "inlzgke1-testplayground" #Host Project where the VPC Exists

gke_cluster = {
  name   = "gke-private-cluster"                      # Name of the Cluster
  region = "asia-east1"                          # Region for the Cluster. Use the same Region as subnet region
  zones  = ["asia-east1-b", "asia-east1-c"] # Zone for the Cluster
  vpc = {
    vpc_name    = "temp"   # VPC Name Used in the VPC config
    vpc_subnet  = "privategkeaccess"   # VPC Subnet Region
    vpc_sec_pod = "pod-range"     # subnet_secondary_ranges for POD IP allocation
    vpc_sec_svc = "svc-range" #subnet_secondary_ranges for Service IP allocation
  }
  master_ipv4_cidr_block = "172.16.1.0/28"
  master_authorized_networks = [{
    cidr_block   = "0.0.0.0/0" # Change this to be the IP from which Kubernetes Can be accessed outside of GCP Network
    display_name = "Allow All"
  }]
  node_pool = [{
    name               = "pool-01" # Name for the Node Pool
    machine_type       = "e2-standard-4"     # Machine Type for Kubernetes Cluster
    node_locations     = "asia-east1-b" # Region for Node Locations. Must Match VPC region to provision
    autoscaling        = true                # Enabling Auto Scaling for the Cluster 
    auto_upgrade       = true                # Enabling Auto Upgrade Functionality
    initial_node_count = 2                   # Minimum Nodes required for ASM to work
    min_count          = 2                   # Minimum Node Count
    max_count          = 5                  # Maximum Node Count for Cluster
    max_pods_per_node  = 20                 # Maximum pods per node. Default is 110
  },
   ]
}

router = {
  name     = "nat-router-tf" #Cloud Router Name to be used
  nat_name = "nat-config-tf" #Name for Cloud NAT
  network  = "temp"  #VPC Network Name
  region   = "asia-east1"   #Region for Cloud NAT
  subnet   = "privategkeaccess"     #subnet for having NAT
}
configure_ip_masq = false