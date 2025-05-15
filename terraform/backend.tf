terraform {
  backend "gcs" {
    bucket  = "final-terra-bucket"
    prefix  = "terraform/state"
  }
}