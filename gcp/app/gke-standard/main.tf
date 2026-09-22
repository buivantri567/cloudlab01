provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC riêng cho GKE, subnet có 2 dải secondary cho Pod và Service (VPC-native)
resource "google_compute_network" "gke" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name                     = "${var.cluster_name}-subnet"
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

# Cluster GKE Standard (zonal). Node pool mặc định bị xoá và thay bằng node pool riêng bên dưới,
# để đổi cấu hình node sau này không làm tạo lại cả cluster.
resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke.id
  subnetwork = google_compute_subnetwork.gke.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Workload Identity: Pod dùng service account của Google mà không cần tải key về
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Ghim phiên bản control plane. GKE chỉ nhận phiên bản tự chọn khi không dùng release channel
  # (các bản này không nằm trong kênh REGULAR). Ghi chú: control plane vẫn có thể được Google
  # tự nâng cấp khi phiên bản sắp hết hỗ trợ.
  min_master_version = var.control_plane_version

  release_channel {
    channel = "UNSPECIFIED"
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

resource "google_container_node_pool" "main" {
  name     = "main-pool"
  cluster  = google_container_cluster.main.name
  location = var.zone

  # Ghim phiên bản node (có thể thấp hơn control plane tối đa 2 minor)
  version = var.node_version

  # Cluster zonal: số node ở đây là tổng số node
  initial_node_count = var.min_nodes

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = var.node_auto_upgrade
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.node_disk_gb
    disk_type       = "pd-balanced"
    spot            = var.spot_nodes
    service_account = google_service_account.nodes.email

    # Scope cloud-platform là khuyến nghị của Google: quyền thực tế do IAM role của service account quyết định
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # Đảm bảo service account của node đã có quyền trước khi node khởi động
  depends_on = [google_project_iam_member.nodes]

  # Cluster bị tạo lại (cùng tên) thì node pool cũng phải được tạo lại theo
  lifecycle {
    replace_triggered_by = [google_container_cluster.main.id]
  }
}
