variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "dataset_id" {
  description = "A unique ID for this dataset, without the project name."
  type        = string
}

variable "friendly_name" {
  description = "A descriptive name for the dataset."
  type        = string
  default     = null
}

variable "description" {
  description = "A user-friendly description of the dataset."
  type        = string
  default     = null
}

variable "location" {
  description = "The geographic location where the dataset should reside."
  type        = string
}

variable "delete_contents_on_destroy" {
  description = "If set to true, delete all the tables in the dataset when the dataset is destroyed, rather than failing."
  type        = bool
  default     = false
}
