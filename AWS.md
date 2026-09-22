# Thông tin AWS

Kiểm tra ngày 2026-09-22 trên Codespace `cloudlab01`.

## AWS CLI

- Phiên bản: aws-cli/2.36.50 (cài từ `awscli-exe-linux-x86_64.zip`, đường dẫn `/usr/local/bin/aws`)
- Credentials lấy từ `.env.env`, cấu hình bằng `aws configure` (region mặc định `us-east-1`)

## Tài khoản

| Mục | Giá trị |
|---|---|
| Account ID | `735234585484` |
| IAM user | `user-ybjkafpmujan` |
| Region mặc định | `us-east-1` |

Đây là môi trường lab của O'Reilly Cloud Labs, nằm trong 1 AWS Organization (management account `381134089987`).

## Terraform

Code ở `aws/terraform/`, state lưu tại `s3://tfstate-735234585484` (khoá bằng DynamoDB table `terraform-locks`). Bootstrap bucket + table bằng `aws/bootstrap/create-state-bucket.sh`.

Hạ tầng đã tạo: VPC + 2 subnet (app public, db private) + 2 security group, 2 EC2 instance (`app-vm`, `db-vm`) với IAM role riêng, Route53 private zone `lab.internal`.

## Giới hạn của tài khoản lab (Service Control Policy)

Tài khoản bị chặn một số action ở cấp AWS Organization (SCP), không liên quan đến quyền IAM của user. Phát hiện được:

- **`dlm:CreateLifecyclePolicy` bị chặn** — không thể dùng AWS Data Lifecycle Manager để tự động snapshot EBS định kỳ. Lỗi trả về:
  ```
  AccessDeniedException: ... explicit deny in a service control policy
  arn:aws:organizations::381134089987:policy/o-ddkcxdbdz1/service_control_policy/p-czkwmpoi
  ```
  Code DLM vẫn giữ trong `aws/terraform/backup.tf` để dùng ở tài khoản không bị giới hạn; IAM role/policy attachment cho DLM tạo được bình thường, chỉ riêng lifecycle policy bị deny.

- **`scheduler:CreateSchedule` bị chặn** — không thể dùng EventBridge Scheduler để lên lịch bật/tắt VM tự động (mirror của `vm_start_schedule`/`vm_stop_schedule` bên GCP). Cùng policy `p-czkwmpoi` deny. Code vẫn giữ trong `aws/terraform/schedule.tf`; IAM role `vm-schedule-role` + policy tạo được bình thường, chỉ riêng `aws_scheduler_schedule` bị deny.

Cả hai đều bị cùng một SCP (`p-czkwmpoi`) chặn — có vẻ tài khoản lab chặn nguyên nhóm dịch vụ "tự động hoá lịch trình/lifecycle" (DLM, EventBridge Scheduler) để kiểm soát chi phí, không phải lỗi cấu hình riêng lẻ.

Khi gặp lỗi `AccessDeniedException` kèm `explicit deny in a service control policy`, đó là giới hạn tổ chức áp cho toàn bộ account — không sửa được bằng cách đổi IAM policy của user, cần dùng dịch vụ thay thế (vd. EventBridge Rules cổ điển thay vì Scheduler, nếu không cùng bị chặn) hoặc tài khoản khác.

## Auto-mode: các hành động cần chạy tay

Trong phiên làm việc qua Claude Code (auto mode), một số `terraform apply` bị bộ phân loại tự động chặn và cần người dùng tự chạy:

- Thay đổi liên quan **IAM** (tạo/sửa role, policy) — `[Protected-Scope IaC Apply]`
- Thay đổi liên quan **DNS/domain/cert** (Route53 zone, record) — `[DNS / Domain / Cert Changes]`

Các thay đổi VPC/EC2/security group thường chạy được trực tiếp.
