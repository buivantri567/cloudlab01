resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "app" {
  name                     = "app-subnet"
  network                  = google_compute_network.main.id
  region                   = var.region
  ip_cidr_range            = var.app_subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db" {
  name                     = "db-subnet"
  network                  = google_compute_network.main.id
  region                   = var.region
  ip_cidr_range            = var.db_subnet_cidr
  private_ip_google_access = true
}

# Firewall: GCP mặc định chặn mọi ingress và cho phép mọi egress.
# Các rule dưới đây mở đúng phần cần thiết, gắn theo network tag "app" và "db".

# SSH chỉ từ dải IAP (dùng: gcloud compute ssh --tunnel-through-iap)
resource "google_compute_firewall" "allow_ssh" {
  name      = "main-allow-ssh"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  source_ranges = var.ssh_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# HTTP/HTTPS từ internet vào VM có tag "app"
resource "google_compute_firewall" "allow_web" {
  name      = "main-allow-web"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Chỉ subnet app được kết nối vào cổng DB của VM có tag "db"
resource "google_compute_firewall" "allow_app_to_db" {
  name      = "main-allow-app-to-db"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  source_ranges = [var.app_subnet_cidr]
  target_tags   = ["db"]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.db_port)]
  }
}

# Ping giữa các subnet để dễ kiểm tra kết nối
resource "google_compute_firewall" "allow_internal_icmp" {
  name      = "main-allow-internal-icmp"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  source_ranges = [var.app_subnet_cidr, var.db_subnet_cidr]

  allow {
    protocol = "icmp"
  }
}

# SSH từ subnet app vào VM có tag "db" (để nhảy từ app-vm sang db-vm, không cần IP public hay IAP)
resource "google_compute_firewall" "allow_app_ssh_to_db" {
  name      = "main-allow-app-ssh-to-db"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  source_ranges = [var.app_subnet_cidr]
  target_tags   = ["db"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
