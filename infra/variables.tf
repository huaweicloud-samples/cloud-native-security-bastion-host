# ============================================================================
# 根模块变量
# ============================================================================

variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "target_environment" {
  description = "目标环境（dev/test/prod），用于资源命名"
  type        = string
  default     = "dev"
}

variable "tag_application" {
  description = "应用标签，用于资源命名前缀"
  type        = string
  default     = "sandbox"
}

variable "vpc_cidr" {
  description = "VPC CIDR 块"
  type        = string
  default     = "10.10.0.240/28"
}

variable "vpc_private_subnets" {
  description = "私有子网 CIDR 列表（本实践使用首个）"
  type        = list(string)
  default     = ["10.10.0.240/28"]
}

variable "instance_type" {
  description = "跳板机 ECS 规格（flavor 名称）"
  type        = string
  default     = "s6.small.1"
}

variable "admin_access_cidr" {
  description = "允许 SSH(22) 入站的源 CIDR。生产务必改为运维者公网 IP，如 1.2.3.4/32"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "运维者 SSH 公钥（OpenSSH 格式），用于创建密钥对"
  type        = string
  sensitive   = true
  default     = "ssh-rsa AAAAREPLACEWITHYOURPUBLICKEY user@host"
}

variable "encrypt_system_disk" {
  description = "是否对系统盘加密（创建 KMS 密钥）"
  type        = bool
  default     = true
}

variable "image_os" {
  description = "公共镜像操作系统（用于筛选最新镜像）"
  type        = string
  default     = "Ubuntu"
}

variable "image_os_version" {
  description = "公共镜像操作系统版本"
  type        = string
  default     = "22.04"
}
