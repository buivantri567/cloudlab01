# Dùng để test kết nối/provider — không tạo tài nguyên thật.
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_subnet_id" {
  value = aws_subnet.app.id
}

output "db_subnet_id" {
  value = aws_subnet.db.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "app_vm_public_ip" {
  value = aws_instance.app.public_ip
}

output "db_vm_private_ip" {
  value = aws_instance.db.private_ip
}

output "ssh_private_key_path" {
  value = local_sensitive_file.ssh_private_key.filename
}

output "private_zone_id" {
  value = aws_route53_zone.private.zone_id
}

output "public_zone_name_servers" {
  value = var.public_domain == "" ? [] : aws_route53_zone.public[0].name_servers
}
