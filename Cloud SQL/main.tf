# Create a random suffix to ensure the instance name is unique globally
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# The Cloud SQL Instance
resource "google_sql_database_instance" "default" {
  name             = "${var.instance_name}-${random_id.db_name_suffix.hex}"
  region           = var.region
  database_version = var.database_version
  
  # Prevent accidental deletion of the database
  deletion_protection = false 

  settings {
    tier = var.tier

    # Basic backup configuration
    backup_configuration {
      enabled = true
    }
    
    # Authorized networks (Optional: Allow access from public internet)
    # WARNING: Restrict this in production!
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "Public Internet"
        value = "0.0.0.0/0"
      }
    }
  }
}

# Create a default database
resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.default.name
}

# Create a user
resource "google_sql_user" "users" {
  name     = "admin"
  instance = google_sql_database_instance.default.name
  password = var.db_password
}