# ============================================================================
# 安全跳板机（Secured Bastion Host）— 华为云实践主入口
# ----------------------------------------------------------------------------
# 架构：单 VPC + 单私有子网，跳板机（ECS）置于私有子网，绑定 EIP 供运维者
# 经 SSH（22）访问；安全组将 SSH 入站锁定到运维者 IP。系统盘加密（KMS）。
# ============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.97"
    }
  }

  # 本地状态（默认）。生产环境建议改用 OBS 远端状态，配置示例：
  #   bucket = "your-tfstate-bucket"
  #   key    = "secured-bastion/terraform.tfstate"
  #   region = "cn-north-4"
  # AK/SK 参见 README §2
  backend "local" {}
}

provider "huaweicloud" {
  region = var.region
  # AK/SK 参见 README §2
}

data "huaweicloud_availability_zones" "available" {}

locals {
  availability_zone = data.huaweicloud_availability_zones.available.names[0]
}

# ------------------------------------------------------------------------------
# VPC 模块（网络 + 安全组）
# ------------------------------------------------------------------------------
module "bastion-vpc" {
  source = "./bastion-vpc"

  vpc_cidr            = var.vpc_cidr
  vpc_private_subnets = var.vpc_private_subnets
  availability_zone   = local.availability_zone
  target_environment  = var.target_environment
  tag_application     = var.tag_application
  admin_access_cidr   = var.admin_access_cidr
}

# ------------------------------------------------------------------------------
# 跳板机模块（ECS + 密钥对 + EIP）
# ------------------------------------------------------------------------------
module "bastion-host" {
  source = "./bastion-host"

  subnet_id           = module.bastion-vpc.private_subnet_id
  security_group_ids  = [module.bastion-vpc.bastion_security_group_id]
  instance_type       = var.instance_type
  availability_zone   = local.availability_zone
  target_environment  = var.target_environment
  tag_application     = var.tag_application
  ssh_public_key      = var.ssh_public_key
  encrypt_system_disk = var.encrypt_system_disk
  image_os            = var.image_os
  image_os_version    = var.image_os_version
}
