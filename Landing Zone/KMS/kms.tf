variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The region for the KMS keys and resources"
  type        = string
  default     = "asia-south1"
}

# 1. Enable the Cloud KMS API
resource "google_project_service" "kms" {
  project = var.project_id
  service = "cloudkms.googleapis.com"
  
  disable_on_destroy = false
}

# 2. Create the KeyRing
resource "google_kms_key_ring" "keyring" {
  name     = "dpdpa-secure-keyring"
  location = var.region
  project  = var.project_id

  depends_on = [google_project_service.kms]
}

# 3. Create the CryptoKey
resource "google_kms_crypto_key" "my_crypto_key" {
  name            = "dpdpa-secure-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s" # 90 days

  # PREVENT DATA LOSS:
  # It is best practice to prevent Terraform from destroying keys 
  # that might be protecting live data.
  lifecycle {
    prevent_destroy = true
  }
}

# ==============================================================================
# GRANTING PERMISSIONS (The most common point of failure)
# You must find the email of the Google Service Agent for the specific service
# (e.g., Storage, BigQuery, SQL) and give it the 'EncrypterDecrypter' role.
# ==============================================================================

# 4. Get the Google Storage Service Agent email for your project
data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

# 5. Grant the Storage Service Agent access to the key
resource "google_kms_crypto_key_iam_binding" "gcs_encryption" {
  crypto_key_id = google_kms_crypto_key.my_crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
  ]
}

# ==============================================================================
# APPLYING CMEK TO A RESOURCE
# ==============================================================================

# 6. Create a Storage Bucket using the CMEK key
resource "google_storage_bucket" "secure_bucket" {
  name          = "dpdpa-cmek-protected-bucket-${var.project_id}"
  location      = var.region
  project       = var.project_id
  force_destroy = true 

  encryption {
    default_kms_key_name = google_kms_crypto_key.my_crypto_key.id
  }

  depends_on = [google_kms_crypto_key_iam_binding.gcs_encryption]
}