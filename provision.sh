#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# 1. DEFINE DEPLOYMENT ORDER (Recommended)
# List your component folder names here in the order they must be deployed.
# Example: ORDERED_COMPONENTS=("00-Project-Creation" "01-SVPC-SC (Networking)" "02-IAM" "03-KMS")
# If left empty, the script will find all directories containing .tf files alphabetically.
ORDERED_COMPONENTS=(
  "Project-Creation"
  "SVPC-SC"
  "IAM"
  "KMS"
  "GKE-Standard"
  "Bigquery"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================================
# FUNCTIONS
# ==============================================================================

function log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

function log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

function check_tfvars() {
    local component=$1
    echo -e "\n------------------------------------------------------------"
    log_info "Preparing to deploy component: ${YELLOW}$component${NC}"
    
    # Check if terraform.tfvars exists
    if [ -f "terraform.tfvars" ]; then
        echo -e "${YELLOW}[CHECK]${NC} Have you updated the 'terraform.tfvars' file for '$component' with the correct values?"
    else
        echo -e "${YELLOW}[CHECK]${NC} No 'terraform.tfvars' found. Are you using variables in 'variables.tf' or environment variables?"
    fi

    read -p "Type 'yes' to confirm and proceed, or anything else to skip this component: " confirm_vars
    if [[ "$confirm_vars" != "yes" ]]; then
        return 1
    fi
    return 0
}

function deploy_component() {
    local component=$1
    
    # Navigate to component directory
    if [ ! -d "$component" ]; then
        log_warn "Directory '$component' not found. Skipping..."
        return
    fi

    cd "$component" || exit

    # Ask user permission to deploy this specific component
    echo -e "${YELLOW}[ACTION]${NC} Do you want to provision the resources in '$component'?"
    read -p "Type 'yes' to deploy, 'no' to skip: " deploy_confirm

    if [[ "$deploy_confirm" == "yes" ]]; then
        log_info "Initializing Terraform for $component..."
        terraform init

        log_info "Planning Terraform for $component..."
        terraform plan -out=tfplan

        echo -e "${YELLOW}[CONFIRM]${NC} Review the plan above."
        read -p "Do you want to APPLY this plan? (yes/no): " apply_confirm

        if [[ "$apply_confirm" == "yes" ]]; then
            terraform apply "tfplan"
            if [ $? -eq 0 ]; then
                log_success "Component '$component' deployed successfully."
            else
                echo -e "${RED}[ERROR]${NC} Deployment of '$component' failed."
                exit 1
            fi
        else
            log_warn "Skipping apply for '$component'."
        fi
    else
        log_warn "Skipping deployment of '$component' by user request."
    fi

    # Return to root directory
    cd ..
}

function prompt_update_tfvars_for_component() {
    local component=$1
    echo -e "\n------------------------------------------------------------"
    log_info "Action Needed for component: ${YELLOW}$component${NC}"
    echo -e "${YELLOW}[ACTION REQUIRED]${NC} Please update the 'terraform.tfvars' (or corresponding variables) for '$component' if not already done."
    read -p "Type 'yes' once you have updated the tfvars file for '$component' (or anything else to skip this component during deployment): " update_confirm
    if [[ "$update_confirm" != "yes" ]]; then
        log_warn "You indicated 'terraform.tfvars' is not updated for '$component'. The script will skip deploying this component when reached."
        return 1
    fi
    return 0
}

# ==============================================================================
# MAIN SCRIPT
# ==============================================================================

# 1. Determine list of components
COMPONENTS_TO_PROCESS=()

if [ ${#ORDERED_COMPONENTS[@]} -eq 0 ]; then
    log_info "No custom order defined. Auto-discovering Terraform directories..."
    # Find directories containing .tf files, excluding .terraform folders
    for d in $(find . -type f -name "*.tf" -not -path "*/.terraform/*" -exec dirname {} \; | sort -u); do
        # Strip leading ./
        clean_d=${d#./}
        if [[ "$clean_d" != "." ]]; then
            COMPONENTS_TO_PROCESS+=("$clean_d")
        fi
    done
else
    COMPONENTS_TO_PROCESS=("${ORDERED_COMPONENTS[@]}")
fi

# 2. Start Iteration
echo -e "\n${GREEN}=== Starting Interactive Infrastructure Deployment ===${NC}"
echo "Found ${#COMPONENTS_TO_PROCESS[@]} components to process."

if [ ${#COMPONENTS_TO_PROCESS[@]} -gt 0 ]; then
    # Deploy the first component immediately
    FIRST_COMPONENT="${COMPONENTS_TO_PROCESS[0]}"
    log_info "Deploying the first component: ${YELLOW}$FIRST_COMPONENT${NC}"
    if check_tfvars "$FIRST_COMPONENT"; then
        deploy_component "$FIRST_COMPONENT"
    else
        log_warn "Skipping '$FIRST_COMPONENT' because tfvars verification failed."
    fi

    # Prompt for tfvars update for the rest
    REST_COMPONENTS=("${COMPONENTS_TO_PROCESS[@]:1}")

    for component in "${REST_COMPONENTS[@]}"; do
        prompt_update_tfvars_for_component "$component"
    done

    # Deploy the remaining components
    for component in "${REST_COMPONENTS[@]}"; do
        # Only proceed if user confirmed tfvars were updated for this component
        if [ -d "$component" ]; then
            # Optionally, you can check again if tfvars is updated by rerunning check_tfvars here
            if check_tfvars "$component"; then
                deploy_component "$component"
            else
                log_warn "Skipping '$component' because tfvars verification failed."
            fi
        else
            log_warn "Directory '$component' not found. Skipping..."
        fi
    done
fi

echo -e "\n${GREEN}=== Deployment Script Completed ===${NC}"
