---
name: 💰 Bounty - Network Stack
about: 实现网络服务栈 (AdGuard Home, WireGuard, Cloudflare DDNS, Nginx Proxy Manager)
title: '[BOUNTY $120] Network Stack — 网络服务'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$120 USDT**

## 任务描述

实现家庭网络基础设施，覆盖 DNS 过滤、VPN 接入、动态域名。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| AdGuard Home | `adguard/adguardhome:v0.107.52` | DNS 过滤 + 广告屏蔽 |
| WireGuard Easy | `ghcr.io/wg-easy/wg-easy:14` | VPN 服务端 |
| Cloudflare DDNS | `ghcr.io/favonia/cloudflare-ddns:1.14.0` | 动态 DNS |
| Unbound | `mvance/unbound:1.21.1` | 递归 DNS 解析器 |

## 核心要求

### 1. AdGuard Home

- 监听 53/UDP 端口（需处理 systemd-resolved 冲突）
- 上游 DNS 指向 Unbound (本地递归) 或 DoH/DoT
- 提供常用过滤列表配置示例
- 脚本自动禁用 `systemd-resolved` 的 53 端口占用

### 2. WireGuard

- Web UI 管理客户端
- 自动生成客户端配置二维码
- DNS 指向内网 AdGuard Home
- 支持 split tunneling 配置说明

### 3. Cloudflare DDNS

- 支持 IPv4 + IPv6 双栈
- 支持多域名配置
- 配置示例文档

### 4. 特殊处理

```bash
# scripts/fix-dns-port.sh
# 检测并禁用 systemd-resolved 的 53 端口
# 支持 --check, --apply, --restore
```

## 验收标准

- [ ] AdGuard Home DNS 解析正常，可过滤广告
- [ ] WireGuard 客户端可接入并访问内网服务
- [ ] DDNS 成功更新 Cloudflare DNS 记录
- [ ] `fix-dns-port.sh` 正确处理 systemd-resolved 冲突
- [ ] README 包含路由器 DNS 配置说明

## 认领方式

评论 "我来认领"。


---

## 🤖 模型要求（必读）

> 本项目对所有提交内容有严格的工具要求，不符合要求的 PR 一律不予验收。

### 必须使用 claude-opus-4-6 完成实现

- 所有代码必须由 **claude-opus-4-6** 生成或审查
- PR 描述中需要注明：
- 要求提交完整的对话日志表1个代表性片段（截图或 JSON 均可）

### 必须使用 GPT-5.3 Codex 进行核查

- 实现完成后，必须由 **GPT-5.3 Codex** 对所有代码进行复查
- Codex 核查内容包括：
  - 配置正确性（环境变量、端口、健康检查）
  - 安全性（权限、密码强度、网络隔离）
  - 国内网络适配性（镜像源、DNS、下载策略）
- PR 中需附上 Codex 核查报告（文本格式，任意长度）
- **Codex 标记为问题的内容，提交者必须自行处理后再提交，不得以“已知问题”为由留下未解决的错误**

### 测试结果必须包含

-  目录下对应的测试脚本必须通过
- 所有服务健康检查返回 
- 提供本地运行的完整测试输出日志（截图或  输出）
- HTTP 端点可访问验证（curl 返回 200）
- 如有国内镜像切换，提供镜像拉取成功的证据

### 不接受的情况

- ✕ Codex 核查发现 **3 个以上**未解决问题
- ✕ 测试脚本失败或未提供测试输出
- ✕ 使用  镜像 tag
- ✕ 硬编码密码或敏感信息
- ✕ 未提供 claude-opus-4-6 使用证据
