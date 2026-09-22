provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC riêng cho GKE, subnet có 2 dải secondary cho Pod và Service (VPC-native)
resource "google_compute_network" "gke" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name                     = "gke-subnet"
  network                  = google_compute_network.gke.id
  region                   = var.region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# Cluster Autopilot: Google quản lý node, tự scale, tính tiền theo tài nguyên của Pod.
# Workload Identity, Shielded node và VPC-native đều bật sẵn.
resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region

  enable_autopilot = true

  network    = google_compute_network.gke.id
  subnetwork = google_compute_subnetwork.gke.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = "REGULAR"
  }

  # Môi trường lab: cho phép terraform destroy xoá cluster.
  # Môi trường thật nên đặt true.
  deletion_protection = false

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_cidrs) > 0 ? [1] : []

    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_cidrs

        content {
          cidr_block   = cidr_blocks.value
          display_name = "allowed-${cidr_blocks.key}"
        }
      }
    }
  }
}
