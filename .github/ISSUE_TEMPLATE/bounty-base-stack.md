---
name: 💰 Bounty - Base Stack
about: 实现基础设施栈 (Traefik, Portainer, Watchtower)
title: '[BOUNTY $150] Base Stack — 基础设施'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$150 USDT**

## 任务描述

实现整个项目的基础设施层，所有其他 Stack 依赖此 Stack 运行。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Traefik | `traefik:v3.1.6` | 反向代理 + 自动 HTTPS |
| Portainer CE | `portainer/portainer-ce:2.21.3` | Docker 管理 UI |
| Watchtower | `containrrr/watchtower:1.7.1` | 容器自动更新 |
| Socket Proxy | `tecnativa/docker-socket-proxy:0.2.0` | 安全隔离 Docker socket |

## 文件结构

```
stacks/base/
├── docker-compose.yml
├── .env.example
└── README.md

config/traefik/
├── traefik.yml           # 静态配置
└── dynamic/
    ├── tls.yml           # TLS 选项
    └── middlewares.yml   # 通用中间件
```

## 核心要求

### 1. 共享网络

创建名为 `proxy` 的外部网络，所有其他 Stack 通过此网络接入 Traefik。

### 2. Traefik 配置

- 80 → 自动重定向 HTTPS
- 443 → TLS 终止
- Let's Encrypt 自动证书 (DNS Challenge 或 HTTP Challenge，可配置)
- Dashboard 通过 `traefik.${DOMAIN}` 访问，需 Basic Auth 保护
- Docker provider：仅读取有 `traefik.enable=true` 标签的容器

### 3. Docker Socket 安全

使用 `docker-socket-proxy` 隔离 Docker socket，Traefik 只读取必要 API。

### 4. Watchtower

- 每天凌晨 3 点扫描更新
- 仅更新有 `com.centurylinklabs.watchtower.enable=true` 标签的容器
- 更新完成后通过 Gotify/ntfy 发通知（与 Notifications Stack 集成）

### 5. 环境变量

```bash
DOMAIN=example.com
ACME_EMAIL=admin@example.com
TRAEFIK_AUTH=         # htpasswd 生成的用户名:密码
TZ=Asia/Shanghai
```

## 验收标准

- [ ] `docker compose up -d` 启动所有 4 个容器
- [ ] 所有容器健康检查通过
- [ ] `http://任意IP:80` 自动重定向到 HTTPS
- [ ] `traefik.${DOMAIN}` 可访问 Dashboard，需密码
- [ ] `portainer.${DOMAIN}` 可访问 Portainer
- [ ] 其他 Stack 容器可通过 `proxy` 网络被 Traefik 发现
- [ ] README 包含 DNS 配置说明、证书配置说明

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
