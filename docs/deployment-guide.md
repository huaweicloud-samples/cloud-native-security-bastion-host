# 部署指南

所有命令使用相对路径。

## 1. 前置准备

| 项 | 要求 |
|---|---|
| 账号 | 华为云账号，具备 VPC / ECS / 安全组 / EIP / KMS 创建权限 |
| 命令行工具 | Terraform >= 1.5（推荐 1.9+）；已配置 `huaweicloud` Provider |
| 区域 | 默认 `cn-north-4`（华北-北京四），可在 `infra/variables.tf` 调整 |
| 凭据 | 华为云 AK/SK；参见 §2，请勿写入任何 .tfvars / .tf 文件 |

## 2. 配置凭据（环境变量）

```bash
export HW_ACCESS_KEY="<你的AccessKey>"
export HW_SECRET_KEY="<你的SecretKey>"
```

> 凭据参见 §2；请勿写入任何文件。

## 3. 准备变量

编辑 `infra/dev.tfvars`，至少修改两项：

- `admin_access_cidr`：改为你的公网 IP，如 `"203.0.113.10/32"`（生产强烈建议 `/32`）。
- `ssh_public_key`：改为你的 SSH 公钥（`ssh-rsa AAAA...` 或 `ssh-ed25519 AAAA...`）。

其余（VPC CIDR、实例规格、镜像、环境标签）保持示例值即可。

## 4. 初始化与校验

```bash
cd infra
terraform init
terraform validate      # 离线校验配置（已内置 Provider，无需联网）
terraform fmt -recursive -check
```

> 校验通过（`Success! The configuration is valid`）后再继续。

## 5. 预演与部署

```bash
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

`apply` 完成后会输出：

- `bastion_instance_id`：跳板机 ECS ID
- `bastion_eip_address`：绑定的弹性公网 IP
- `bastion_security_group_id`：安全组 ID
- `bastion_private_subnet_id`：私有子网 ID
- `bastion_vpc_id`：VPC ID

## 6. 登录跳板机

使用仓库提供的连接助手：

```bash
cd src
./connect-bastion.sh <bastion_eip_address> ubuntu ~/.ssh/id_rsa
```

或直接：

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<bastion_eip_address>
```

> 仅当 `admin_access_cidr` 已包含你当前公网 IP 时，SSH 才能连通。

## 7. 清理资源

```bash
cd infra
terraform destroy -var-file=dev.tfvars
```

销毁后建议到控制台确认 VPC / ECS / EIP / KMS 均无残留，释放资源。

## 8. 远程状态（可选，生产推荐）

默认使用本地状态文件（`infra/terraform.tfstate`）。生产环境建议改用对象存储桶
（OBS）远端状态，配置示例见 `infra/main.tf` 顶部注释，
`access_key`/`secret_key` 凭据参见 §2。
