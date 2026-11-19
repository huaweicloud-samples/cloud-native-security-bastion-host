#!/usr/bin/env bash
# ============================================================================
# 跳板机 SSH 连接助手
# ----------------------------------------------------------------------------
# 用法：./connect-bastion.sh <bastion_eip_address> [ssh_user] [ssh_key_path]
#   - <bastion_eip_address>  必填，terraform output bastion_eip_address 的值
#   - [ssh_user]             可选，默认 ubuntu（与公共镜像 Ubuntu 22.04 默认用户一致）
#   - [ssh_key_path]         可选，默认 ~/.ssh/id_rsa
# ----------------------------------------------------------------------------
# 行为：调用 ssh -i <key> <user>@<ip> 登录跳板机
#       仅当部署时 admin_access_cidr 已收敛到运维者 IP 时才能连通。
# ============================================================================

set -euo pipefail

EIP="${1:-}"
SSH_USER="${2:-ubuntu}"
SSH_KEY="${3:-${HOME}/.ssh/id_rsa}"

if [[ -z "${EIP}" ]]; then
  echo "用法：$0 <bastion_eip_address> [ssh_user] [ssh_key_path]" >&2
  echo "示例：$0 124.70.x.x ubuntu ~/.ssh/id_rsa" >&2
  exit 1
fi

if [[ ! -f "${SSH_KEY}" ]]; then
  echo "SSH 私钥不存在：${SSH_KEY}" >&2
  echo "请生成密钥对并将公钥写入 infra/dev.tfvars 的 ssh_public_key 后重试。" >&2
  exit 1
fi

# StrictHostKeyChecking=no 仅用于一次性连接；如需强校验，改为 yes 并预置 known_hosts
ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -i "${SSH_KEY}" \
    "${SSH_USER}@${EIP}"