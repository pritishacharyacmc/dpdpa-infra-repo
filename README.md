# dpdpa-infra-repo
Infrastructure Repository for the DPDPA 
Project Creations structure 
    By default the script deploys the following projects 
        "gcp-org-p-governance",
        "gcp-org-p-confidential-data",
        "gcp-org-p-non-confidential-data",
        "gcp-org-p-privacy-tools",
        "gcp-org-p-reporting"
To make changes to the project names please update the terraform.tfvars file 
Please add the primary folder ID and Billing ID to terraform.tfvars file

Deploying the GKE Cluster
Because the Terraform configuration for the backend service depends on the NEG created by Kubernetes, you need to apply this in two stages.

Stage 1: Deploy GKE and Application

    Comment out the data "google_compute_region_network_endpoint_group" "gke_neg" block in load_balancer.tf for the first run.
    Run terraform init.
    Run terraform apply to create the GKE cluster.
    Configure kubectl to connect to your new cluster.
    Apply the Kubernetes manifest: kubectl apply -f app_deployment.yaml. This will create the deployment, service, and the crucial NEG.

Stage 2: Deploy the Load Balancer

    Uncomment the data "google_compute_region_network_endpoint_group" "gke_neg" block in load_balancer.tf.
    Run terraform apply again. Terraform will now find the NEG created in the previous step and build the full load balancer stack.
    After deployment, remember to point your domain's DNS A record to the static IP address created by the google_compute_global_address resource. It may take some time for the SSL certificate to be provisioned and the load balancer to become fully active.