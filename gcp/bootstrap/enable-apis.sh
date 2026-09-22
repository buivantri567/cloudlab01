#!/usr/bin/env bash
# Bootstrap GCP: bật các API cần cho Terraform và Packer.
#
# Dùng:
#   PROJECT_ID=user-cjpobzxpcgar ./enable-apis.sh
#   DRY_RUN=1 PROJECT_ID=user-cjpobzxpcgar ./enable-apis.sh   # chỉ in lệnh, không bật
#
# Nếu không truyền PROJECT_ID, script lấy project mặc định của gcloud.
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}"
if [[ -z "$PROJECT_ID" ]]; then
  echo "Thiếu PROJECT_ID. Chạy: PROJECT_ID=<id> $0" >&2
  exit 1
fi

# API nền tảng
APIS=(
  serviceusage.googleapis.com          # bật/tắt API (Terraform google_project_service)
  cloudresourcemanager.googleapis.com  # đọc project, IAM policy (Terraform provider)
  iam.googleapis.com                   # service account, role
  iamcredentials.googleapis.com        # impersonate service account, token ngắn hạn
  compute.googleapis.com               # VM, mạng, firewall; Packer build image
  storage.googleapis.com               # bucket, dùng làm Terraform remote state
  logging.googleapis.com               # Cloud Logging
  monitoring.googleapis.com            # Cloud Monitoring
  dns.googleapis.com                   # Cloud DNS
  container.googleapis.com             # Google Kubernetes Engine
)

# API tuỳ chọn, bỏ comment khi cần
# APIS+=(
#   run.googleapis.com                 # Cloud Run
#   artifactregistry.googleapis.com    # lưu container image
#   firestore.googleapis.com           # Firestore
#   servicenetworking.googleapis.com   # private IP cho Cloud SQL
#   sqladmin.googleapis.com            # Cloud SQL
#   secretmanager.googleapis.com       # Secret Manager
#   cloudbuild.googleapis.com          # Cloud Build
# )

echo "Project: $PROJECT_ID"
echo "Bật ${#APIS[@]} API:"
printf '  - %s\n' "${APIS[@]}"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo
  echo "[dry-run] gcloud services enable ${APIS[*]} --project=$PROJECT_ID"
  exit 0
fi

gcloud services enable "${APIS[@]}" --project="$PROJECT_ID"

echo
echo "Các API đang bật:"
gcloud services list --enabled --project="$PROJECT_ID" --format="value(config.name)" | sort
