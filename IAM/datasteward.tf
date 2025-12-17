 1. Define the Custom Role - Data Steward
resource "google_project_iam_custom_role" "data_steward" {
  role_id     = "DataSteward"
  title       = "Data Steward"
  description = "Custom role for data governance with access to BigQuery, GCS, Logging, and Dataplex"
  permissions = [
    # BigQuery User & Data Viewer permissions
    "bigquery.jobs.create",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "bigquery.datasets.get",
    
    # Log Writer permissions
    "logging.logEntries.create",
    
    # Storage Object Viewer permissions
    "storage.objects.get",
    "storage.objects.list",
    
    # Dataplex Data Owner permissions
    "dataplex.dataTaxonomies.get",
    "dataplex.entities.create",
    "dataplex.entities.update",
    "dataplex.entities.delete"
  ]
}

# 2. Provision the Role (Assign it to a user)
resource "google_project_iam_member" "assign_data_steward" {
  project = "your-project-id" # Replace with your actual project ID
  role    = google_project_iam_custom_role.data_steward.id
  member  = "user:someone@example.com" # Replace with the user's email
}