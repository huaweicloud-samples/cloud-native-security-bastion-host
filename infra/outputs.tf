# ============================================================================
# 根模块输出
# ============================================================================

output "bastion_vpc_id" {
  description = "VPC ID"
  value       = module.bastion-vpc.vpc_id
}

output "bastion_private_subnet_id" {
  description = "私有子网 ID"
  value       = module.bastion-vpc.private_subnet_id
}

output "bastion_security_group_id" {
  description = "跳板机安全组 ID"
  value       = module.bastion-vpc.bastion_security_group_id
}

output "bastion_instance_id" {
  description = "跳板机 ECS ID"
  value       = module.bastion-host.instance_id
}

output "bastion_eip_address" {
  description = "跳板机绑定的弹性公网 IP（运维 SSH 入口）"
  value       = module.bastion-host.eip_address
}
