data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH key tự sinh — private key được lưu ra file cục bộ (không commit, xem .gitignore)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "main-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/main-key.pem"
  file_permission = "0600"
}

# VM app: nằm trong subnet app, có IP public để nhận SSH/HTTP/HTTPS (sg app-sg)
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.app.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.app.name

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"

    tags = {
      Name   = "app-vm-root"
      Backup = "daily"
    }
  }

  tags = {
    Name = "app-vm"
  }
}

# VM db: nằm trong subnet db, không có IP public.
# Chỉ nhận SSH/DB port từ subnet app (sg db-sg) — dùng app-vm làm jump host.
resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.db.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.db.name

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"

    tags = {
      Name   = "db-vm-root"
      Backup = "daily"
    }
  }

  # db-vm sẽ chứa dữ liệu. Không để AMI mới hơn làm Terraform xoá và tạo lại VM.
  # Muốn đổi image chủ động: terraform apply -replace=aws_instance.db
  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "db-vm"
  }
}
