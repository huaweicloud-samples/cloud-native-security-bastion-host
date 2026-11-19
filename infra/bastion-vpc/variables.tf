# ============================================================================
# VPC 模块变量
# ============================================================================

variable "vpc_cidr" {
  type = string
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "availability_zone" {
  type = string
}

variable "target_environment" {
  type = string
}

variable "tag_application" {
  type = string
}

variable "admin_access_cidr" {
  type = string
}
