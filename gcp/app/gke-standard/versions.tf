terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }

  # State dùng chung bucket với các module khác nhưng khác prefix.
  # Không ghi cứng tên bucket để đổi lab không phải sửa file. Khi init, truyền:
  #   terraform init -backend-config="bucket=<PROJECT_ID>-tfstate"
  backend "gcs" {
    prefix = "gke-standard/state"
  }
}
