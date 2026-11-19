# ============================================================================
# VPC 模块输出
# ============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = huaweicloud_vpc.this.id
}

output "private_subnet_id" {
  description = "私有子网 ID"
  value       = huaweicloud_vpc_subnet.private.id
}

output "bastion_security_group_id" {
  description = "跳板机安全组 ID"
  value       = huaweicloud_networking_secgroup.bastion.id
}
