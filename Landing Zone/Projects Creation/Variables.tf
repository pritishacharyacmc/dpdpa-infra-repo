# variables.tf

variable "project_names" {
  description = "A list of GCP project names to be created."
  type        = list(string)
}

variable "folder_id" {
  description = "The ID of the folder where the projects will be created."
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate with the projects."
  type        = string
}
