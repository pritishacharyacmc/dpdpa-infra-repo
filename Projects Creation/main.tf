# main.tf

# Configure the Google Cloud provider
provider "google" {
  # You can specify your project and region here, or through environment variables.
}

# Create multiple projects from a list of names
resource "google_project" "projects" {
  for_each = toset(var.project_names)

  name            = each.value
  project_id      = each.value
  folder_id       = var.folder_id
  billing_account = var.billing_account
}
