# ============================================================================
# VPC 模块：网络 + 安全组
# ============================================================================

terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
    }
  }
}

resource "huaweicloud_vpc" "this" {
  name = "${var.tag_application}-${var.target_environment}-bastion-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "private" {
  name       = "${var.tag_application}-${var.target_environment}-bastion-subnet"
  cidr       = var.vpc_private_subnets[0]
  gateway_ip = cidrhost(var.vpc_private_subnets[0], 1)
  vpc_id     = huaweicloud_vpc.this.id

  # 单可用区部署
  availability_zone = var.availability_zone
}

# ------------------------------------------------------------------------------
# 跳板机安全组
# ------------------------------------------------------------------------------
resource "huaweicloud_networking_secgroup" "bastion" {
  name        = "${var.tag_application}-${var.target_environment}-bastion-sg"
  description = "Security group for bastion host"
}

# 出站全放行（默认 0.0.0.0/0）
resource "huaweicloud_networking_secgroup_rule" "egress_all" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.bastion.id
}

# 入站 SSH(22)，仅允许运维者 IP
resource "huaweicloud_networking_secgroup_rule" "ingress_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.admin_access_cidr
  security_group_id = huaweicloud_networking_secgroup.bastion.id
}
