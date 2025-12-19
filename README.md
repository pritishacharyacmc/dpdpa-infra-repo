# dpdpa-infra-repo
Infrastructure Repository for the DPDPA 

Default Region - Asia- South1 

Project Creations structure 
    By default the script deploys the following projects 
        "gcp-org-p-governance",
        "gcp-org-conf-data",
        "gcp-org-p-non-conf-data",
        "gcp-org-p-privacy-tools",
        "gcp-org-p-reporting"
To make changes to the project names please update the terraform.tfvars file 
Please add the primary folder ID and Billing ID to terraform.tfvars file

This deloyment uses VPC-SC, here are some Important Considerations

Existing Access Policy: If your organization already has an Access Policy, the google_access_context_manager_access_policy resource creation will fail. In that case, you must import it or reference it using a data source.

Dry Run Mode: When deploying VPC-SC for the first time, it is highly recommended to use the spec block (Dry Run) instead of the status block (Enforced). This allows you to view violations in Cloud Logging without actually blocking traffic.

To do this, rename status { ... } to spec { ... } and add use_explicit_dry_run_spec = true inside the resource.

Access from your Laptop: Once this is applied, you might lose access to these resources (e.g., running gcloud storage ls) if you are not inside the VPC network. You will need to configure Ingress Policies or Access Levels (IP-based allowlists) to manage the resources from the internet.


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

   Default Node Configuration -2 Nodes
    
     
    
    **# How to Execute the provision.sh Script**





**This guide explains how to use the `provision.sh` script to interactively deploy infrastructure components defined in this repository.
**
---

## Prerequisites

- **Operating System:** Linux or macOS (Bash shell required)
- **Terraform:** [Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) and make sure it is accessible in your shell.
- **Cloud Credentials:** Authenticate with your cloud provider (e.g., Google Cloud SDK, AWS CLI) as required for your environment.
- **Git:** Install Git if you haven't already.

---

## Steps to Run the Script

### 1. Clone the Repository

If you haven't already, clone this repository and navigate to its root directory:

```sh
git clone https://github.com/pritishacharyacmc/dpdpa-infra-repo.git
cd dpdpa-infra-repo
```

### 2. Make the Script Executable

```sh
chmod +x provision.sh
```

### 3. Configure Variable Files

- Each component directory (e.g. `Project-Creation`, `SVPC-SC`, `IAM`, etc.) should have an updated `terraform.tfvars` or set the required variables via environment variables.
- Make sure `terraform.tfvars` contains values like folder IDs or billing IDs where necessary.

### 4. Run the Script

Execute from the root directory:

```sh
./provision.sh
```

### 5. Follow Interactive Prompts

- For each component, the script prompts you to confirm variable updates and whether you want to deploy the component.
- It gives you a chance to review the `terraform plan` before applying it.
- You must type `yes` at various steps to proceed; otherwise, the step or component is skipped.

### 6. Script Progress

- The script will proceed through each component as ordered in the script (`ORDERED_COMPONENTS` array).
- Successful steps and errors are color-coded for clarity.

### 7. Completion

- On successful completion, the script prints `=== Deployment Script Completed ===`.

---

## Notes

- **Component Order:** You can change the order or components to deploy by editing the `ORDERED_COMPONENTS` array in `provision.sh`.
- **Skipping Components:** If you want to skip any component, simply enter anything except `yes` when prompted.
- **Error Handling:** The script will stop if there is a critical error.
- **Cloud Access:** Ensure you have the proper permissions and cloud credentials prior to running the deployment.

---

## Troubleshooting

- **Command Not Found:** Ensure both Terraform and Bash are installed and in your PATH.
- **Permissions:** You may need to run with elevated permissions (`sudo`) depending on your environment.
- **Cloud Issues:** Make sure your credentials are up to date and have the right IAM roles.

---

For further details, refer to the repository's main [README.md](README.md).

    After deployment, remember to point your domain's DNS A record to the static IP address created by the google_compute_global_address resource. It may take some time for the SSL certificate to be provisioned and the load balancer to become fully active.



