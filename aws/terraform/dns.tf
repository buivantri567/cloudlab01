# Vùng DNS private: chỉ VM trong main-vpc phân giải được các tên này.
resource "aws_route53_zone" "private" {
  name    = var.private_domain
  comment = "Tên nội bộ cho main-vpc"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "app_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "app.${var.private_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app.private_ip]
}

resource "aws_route53_record" "db_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.${var.private_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.db.private_ip]
}

# Vùng DNS public: chỉ tạo khi đặt biến public_domain.
# Sau khi tạo, phải trỏ NS của tên miền (tại nơi đăng ký) về name_servers trong output.
resource "aws_route53_zone" "public" {
  count = var.public_domain == "" ? 0 : 1

  name    = var.public_domain
  comment = "Vùng public cho ${var.public_domain}"
}

# Lưu ý: IP public của app-vm là IP tạm thời, đổi khi VM dừng rồi chạy lại.
# Muốn IP cố định, cần thêm aws_eip.
resource "aws_route53_record" "app_public" {
  count = var.public_domain == "" ? 0 : 1

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "app.${var.public_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app.public_ip]
}
