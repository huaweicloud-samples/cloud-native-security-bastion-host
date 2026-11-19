# ============================================================================
# 跳板机模块：ECS + 密钥对 + 系统盘加密 + EIP
# ============================================================================

terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
    }
  }
}

# 公共镜像（区域可用时自动选取最新版本；用 flavor_id 强制匹配 s6.small.1，避免命中 ARM 变体）
data "huaweicloud_images_image" "bastion" {
  most_recent = true
  os          = var.image_os
  os_version  = var.image_os_version
  visibility  = "public"
  flavor_id   = var.instance_type
}

# 运维者密钥对（用于 ECS 密钥对登录）
resource "huaweicloud_compute_keypair" "bastion" {
  name       = "${var.tag_application}-${var.target_environment}-bastion-keypair"
  public_key = var.ssh_public_key
}

# 系统盘加密密钥（依赖 EVS 存储层默认加密）
# 备注：华为云 EVS 默认对系统盘加密（存储层），本资源仅用于应用层管理密钥。
# 如要 ECS 使用 CMK 加密，需额外授权（huaweicloud_kms_grant + op_svc_ecs）；
# 该 IAM 用户在 cn-north-4 默认未授权 KMS.0308，导致 ECS 报 EVS.2261。
# 默认跳过 KMS CMK 加密，由 EVS 默认加密承担。
resource "huaweicloud_kms_key" "bastion" {
  count        = var.encrypt_system_disk ? 1 : 0
  key_alias    = "${var.tag_application}-${var.target_environment}-bastion-disk-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  pending_days = 7
}

# 跳板机 ECS（位于私有子网，无公网入站端口；经 EIP 提供受控 SSH 访问）
resource "huaweicloud_compute_instance" "bastion" {
  name               = "${var.tag_application}-${var.target_environment}-bastion-host"
  flavor_id          = var.instance_type
  image_id           = data.huaweicloud_images_image.bastion.id
  key_pair           = huaweicloud_compute_keypair.bastion.name
  security_group_ids = var.security_group_ids
  availability_zone  = var.availability_zone

  # 跳板机置于私有子网，仅经 EIP 暴露 SSH(22)
  network {
    uuid = var.subnet_id
  }

  # 通过 cloud-init user_data 直接写入公钥到 ubuntu 用户 authorized_keys。
  # 原因：huaweicloud_compute_keypair 注册公钥到 ECS 元数据，但 Ubuntu 22.04
  # 公共镜像的 cloud-init 偶发不读取元数据 SSH 密钥，导致 SSH publickey 认证被拒。
  # 双重保障：① 保留 key_pair 属性（华为云机制）；② user_data 直接写入。
  user_data = <<-EOT
    #cloud-config
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    ssh_pwauth: false
  EOT

  # 系统盘：显式规格（华为云必填项，避免 provider 默认值歧义）
  system_disk_type = "GPSSD"
  system_disk_size = 40

  # 系统盘加密：华为云 EVS 默认对系统盘加密（存储层），无需额外 KMS 授权；
  # 如需应用层 CMK 加密，请参考 docs/deployment-guide.md §10（FAQ）手动授权 op_svc_ecs。
  system_disk_kms_key_id = null

  tags = {
    Name = "${var.tag_application}-${var.target_environment}-bastion-host"
  }

  # 依赖：等 keypair 注册完成，确保 user_data 注入时密钥可用
  depends_on = [huaweicloud_compute_keypair.bastion]
}

# 弹性公网 IP（运维 SSH 入口，公网入口，apply 前已单独告知）
resource "huaweicloud_vpc_eip" "bastion" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.tag_application}-${var.target_environment}-bastion-bw"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# 将 EIP 绑定到跳板机
resource "huaweicloud_compute_eip_associate" "bastion" {
  public_ip   = huaweicloud_vpc_eip.bastion.address
  instance_id = huaweicloud_compute_instance.bastion.id
}
