---
name: 💰 Bounty - Productivity Stack
about: 实现生产力工具栈 (Gitea, Vaultwarden, Outline, Stirling PDF)
title: '[BOUNTY $160] Productivity Stack — 生产力工具'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$160 USDT**

## 任务描述

实现自托管生产力套件，覆盖代码托管、密码管理、团队知识库、PDF 工具。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Gitea | `gitea/gitea:1.22.2` | Git 代码托管 |
| Vaultwarden | `vaultwarden/server:1.32.0` | 密码管理器 (Bitwarden 兼容) |
| Outline | `outlinewiki/outline:0.80.2` | 团队知识库 |
| Stirling PDF | `frooodle/s-pdf:0.30.2` | PDF 处理工具 |
| Excalidraw | `excalidraw/excalidraw:latest-sha` | 在线白板 |

## 核心要求

### 1. Gitea

- 使用共享 PostgreSQL
- 配置 Authentik OIDC 登录
- 禁用注册（仅管理员创建账号）
- 配置 Gitea Actions runner

### 2. Vaultwarden

- **必须** HTTPS（浏览器扩展要求）
- 禁用公开注册，仅 admin 可邀请
- 配置 `ADMIN_TOKEN` 保护管理界面
- 配置 SMTP 邮件通知

### 3. Outline

- 使用共享 PostgreSQL + Redis
- 配置 Authentik OIDC
- MinIO 作为文件存储后端

### 4. 环境变量

```bash
GITEA_DB_PASSWORD=
VAULTWARDEN_ADMIN_TOKEN=
OUTLINE_SECRET_KEY=
OUTLINE_UTILS_SECRET=
SMTP_HOST=
SMTP_PORT=
SMTP_USER=
SMTP_PASS=
```

## 验收标准

- [ ] Gitea 可用 Authentik OIDC 登录，仓库推送正常
- [ ] Vaultwarden 浏览器扩展可连接，HTTPS 证书有效
- [ ] Outline 可用 Authentik 登录，文档编辑正常
- [ ] Stirling PDF 所有功能页面可访问
- [ ] 所有服务 Traefik 反代 + HTTPS 正常

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
