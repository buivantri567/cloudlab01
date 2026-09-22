# Thông tin GCP

Kiểm tra ngày 2026-09-21 trên Codespace `cloudlab01`.

## gcloud CLI

- Phiên bản: Google Cloud SDK 585.0.0 (cài qua apt, đường dẫn `/usr/bin/gcloud`)
- Kèm theo: `bq` 2.1.38, `alpha`, `beta`

## Terraform và Packer

Cài qua kho apt của HashiCorp.

| Công cụ | Phiên bản | Đường dẫn |
|---|---|---|
| Terraform | v1.16.3 | `/usr/bin/terraform` |
| Packer | v1.16.1 | `/usr/bin/packer` |

Terraform và Packer không dùng chung đăng nhập với `gcloud auth login`. Cần tạo Application Default Credentials:

```bash
gcloud auth application-default login --no-launch-browser
```

Kiểm tra phiên bản:

```bash
terraform version
packer version
```

## Tài khoản và project

| Mục | Giá trị |
|---|---|
| Tài khoản đang dùng | `user-eydugrhvivdc@oreilly-cloudlabs.com` |
| Project ID | `user-eydugrhvivdc` |
| Số project | `443708464423` |
| Project mặc định trong config | Chưa đặt |

Đặt project mặc định:

```bash
gcloud config set project user-eydugrhvivdc
```

## Quyền của tài khoản (IAM, cấp project)

| Vai trò | Quyền chính |
|---|---|
| `roles/editor` | Tạo, sửa, xoá hầu hết tài nguyên (Compute, Storage, BigQuery, Pub/Sub...) |
| `roles/run.admin` | Toàn quyền với Cloud Run |
| `roles/datastore.owner` | Toàn quyền với Firestore/Datastore |
| `roles/iam.serviceAccountAdmin` | Tạo, sửa, xoá service account |
| `roles/resourcemanager.projectIamAdmin` | Sửa IAM policy của project (cấp hoặc thu hồi quyền) |
| `roles/servicenetworking.networksAdmin` | Quản lý Service Networking (ví dụ private IP cho Cloud SQL) |

Ghi chú:

- `editor` cùng `projectIamAdmin` cho phép làm gần như mọi việc trong project, kể cả tự cấp thêm quyền cho mình.
- Service account `user-eydugrhvivdc@443708464423.iam.gserviceaccount.com` có `roles/owner`. Tài khoản user thì không có vai trò này.
- Chỉ kiểm tra quyền ở cấp project, chưa kiểm tra folder hay organization.
- Đây có vẻ là môi trường lab của O'Reilly (tạo bởi service account `cl-cloud-user-creator-prod`). Tài nguyên có thể bị xoá khi lab hết hạn.

## Lệnh hữu ích

```bash
gcloud auth list                     # tài khoản đã đăng nhập
gcloud config list                   # cấu hình hiện tại
gcloud projects list                 # project truy cập được
gcloud projects get-iam-policy user-eydugrhvivdc   # IAM policy của project
```

Đăng nhập lại khi cần (trong Codespace):

```bash
gcloud auth login --no-launch-browser
```

## Lưu ý bảo mật

- File `.env.env` trong repo chứa mã xác thực OAuth và chưa được gitignore. Nên xoá mã khỏi file hoặc thêm `.env*` vào `.gitignore` trước khi commit.

```bash
gcloud auth login --no-launch-browser
gcloud auth application-default login --no-launch-browser
```