# ============================================================================
# 跳板机模块输出
# ============================================================================

output "instance_id" {
  description = "跳板机 ECS ID"
  value       = huaweicloud_compute_instance.bastion.id
}

output "key_pair_name" {
  description = "密钥对名称"
  value       = huaweicloud_compute_keypair.bastion.name
}

output "eip_address" {
  description = "绑定的弹性公网 IP"
  value       = huaweicloud_vpc_eip.bastion.address
}
