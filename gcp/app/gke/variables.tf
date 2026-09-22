variable "project_id" {
  description = "ID của GCP project"
  type        = string
  default     = "user-rjuceihufwmc"
}

variable "region" {
  description = "Region của cluster và subnet"
  type        = string
  default     = "asia-southeast1"
}

variable "cluster_name" {
  description = "Tên cluster GKE"
  type        = string
  default     = "gke-main"
}

variable "subnet_cidr" {
  description = "Dải IP của node"
  type        = string
  default     = "10.30.0.0/20"
}

variable "pods_cidr" {
  description = "Dải IP secondary cho Pod"
  type        = string
  default     = "10.31.0.0/16"
}

variable "services_cidr" {
  description = "Dải IP secondary cho Service"
  type        = string
  default     = "10.32.0.0/20"
}

variable "master_authorized_cidrs" {
  description = "Dải IP được phép gọi Kubernetes API. Để trống = không giới hạn (mọi IP có credentials đều gọi được)"
  type        = list(string)
  default     = []
}
