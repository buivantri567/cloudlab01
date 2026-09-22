terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }

  # State lưu trong bucket tạo bởi gcp/bootstrap/create-state-bucket.sh
  backend "gcs" {
    bucket = "user-cjpobzxpcgar-tfstate"
    prefix = "terraform/state"
  }
}
