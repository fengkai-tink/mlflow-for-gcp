terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-tink-ratchet-eu-x"
    prefix = "mlflow-state"
  }
  required_version = ">=1.4.5"
}

provider "google" {
  region  = var.region
  project = var.project_name
}