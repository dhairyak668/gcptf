variable "project_id" {
  type        = string
  description = "The project id"
}

variable "region" {
  type = string
  default = "us-central1"
  validation {
    condition     = contains(["us-central1", "us-east1"], var.region)
    error_message = "Region must be us-central1 or us-east1."
  }
}
variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "db_password" {
  type      = string
  sensitive = true
  description = "Password for the Cloud SQL user and Flask app"
}