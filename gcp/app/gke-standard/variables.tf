variable "project_id" {
  description = "ID của GCP project"
  type        = string
  default     = "user-rjuceihufwmc"
}

variable "region" {
  description = "Region của subnet"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "Zone của cluster. Cluster zonal rẻ hơn regional vì node chỉ nằm ở 1 zone"
  type        = string
  default     = "asia-southeast1-b"
}

variable "cluster_name" {
  description = "Tên cluster GKE"
  type        = string
  default     = "gke-standard"
}

variable "subnet_cidr" {
  description = "Dải IP của node"
  type        = string
  default     = "10.40.0.0/20"
}

variable "pods_cidr" {
  description = "Dải IP secondary cho Pod"
  type        = string
  default     = "10.41.0.0/16"
}

variable "services_cidr" {
  description = "Dải IP secondary cho Service"
  type        = string
  default     = "10.42.0.0/20"
}

variable "machine_type" {
  description = "Loại máy của node"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_gb" {
  description = "Dung lượng boot disk của mỗi node (GB)"
  type        = number
  default     = 50
}

variable "min_nodes" {
  description = "Số node tối thiểu của node pool"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Số node tối đa của node pool"
  type        = number
  default     = 3
}

variable "spot_nodes" {
  description = "Dùng Spot VM cho node (rẻ hơn nhiều nhưng có thể bị thu hồi bất kỳ lúc nào)"
  type        = bool
  default     = false
}

variable "master_authorized_cidrs" {
  description = "Dải IP được phép gọi Kubernetes API. Để trống = không giới hạn (mọi IP có credentials đều gọi được)"
  type        = list(string)
  default     = []
}

variable "control_plane_version" {
  description = "Phiên bản control plane (min_master_version). Chỉ ghim được khi cluster không dùng release channel"
  type        = string
  default     = "1.35.6-gke.1250000"
}

variable "node_version" {
  description = "Phiên bản node của node pool. Chỉ ghim được khi cluster không dùng release channel"
  type        = string
  default     = "1.34.9-gke.1655001"
}

variable "node_auto_upgrade" {
  description = "Tự nâng cấp node. Phải là false để giữ đúng node_version đã ghim"
  type        = bool
  default     = false
}
