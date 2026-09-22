# Vùng DNS private: chỉ VM trong main-vpc phân giải được các tên này.
resource "google_dns_managed_zone" "private" {
  name        = "main-private-zone"
  dns_name    = "${var.private_domain}."
  description = "Tên nội bộ cho main-vpc"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.main.id
    }
  }
}

resource "google_dns_record_set" "app_private" {
  managed_zone = google_dns_managed_zone.private.name
  name         = "app.${google_dns_managed_zone.private.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_instance.app.network_interface[0].network_ip]
}

resource "google_dns_record_set" "db_private" {
  managed_zone = google_dns_managed_zone.private.name
  name         = "db.${google_dns_managed_zone.private.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_instance.db.network_interface[0].network_ip]
}

# Vùng DNS public: chỉ tạo khi đặt biến public_domain.
# Sau khi tạo, phải trỏ NS của tên miền (tại nơi đăng ký) về name_servers trong output.
resource "google_dns_managed_zone" "public" {
  count = var.public_domain == "" ? 0 : 1

  name        = "main-public-zone"
  dns_name    = "${var.public_domain}."
  description = "Vùng public cho ${var.public_domain}"
  visibility  = "public"
}

# Lưu ý: IP public của app-vm là IP tạm thời, đổi khi VM dừng rồi chạy lại.
# Muốn IP cố định, cần thêm google_compute_address.
resource "google_dns_record_set" "app_public" {
  count = var.public_domain == "" ? 0 : 1

  managed_zone = google_dns_managed_zone.public[0].name
  name         = "app.${google_dns_managed_zone.public[0].dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_instance.app.network_interface[0].access_config[0].nat_ip]
}
