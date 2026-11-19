# ============================================================================
# 跳板机模块变量
# ============================================================================

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
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

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "encrypt_system_disk" {
  type = bool
}

variable "image_os" {
  type = string
}

variable "image_os_version" {
  type = string
}
