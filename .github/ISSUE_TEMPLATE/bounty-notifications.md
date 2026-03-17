---
name: 💰 Bounty - Notifications Stack
about: 实现通知服务栈 (ntfy, Gotify) + 统一通知路由
title: '[BOUNTY $80] Notifications Stack — 通知服务'
labels: bounty, easy
assignees: ''
---

## 赏金金额

**$80 USDT**

## 任务描述

实现统一通知中心，让所有其他服务（Watchtower、Alertmanager、Gitea 等）都能向用户推送通知。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| ntfy | `binwiederhier/ntfy:v2.11.0` | 推送通知服务器 |
| Gotify | `gotify/server:2.5.0` | 备用推送服务 |

## 核心要求

### 1. ntfy 配置

```yaml
# config/ntfy/server.yml
base-url: https://ntfy.${DOMAIN}
auth-default-access: deny-all
behind-proxy: true
cache-file: /var/cache/ntfy/cache.db
auth-file: /var/lib/ntfy/user.db
```

### 2. 集成文档

`stacks/notifications/README.md` 必须包含以下服务的通知配置说明：

| 服务 | 配置方式 |
|------|----------|
| Alertmanager | webhook receiver 指向 ntfy |
| Watchtower | `WATCHTOWER_NOTIFICATION_URL=ntfy://...` |
| Gitea | webhook 发送到 ntfy |
| Home Assistant | ntfy notify integration |
| Uptime Kuma | ntfy notification channel |

### 3. 通知脚本

`scripts/notify.sh <topic> <title> <message> [priority]`

其他脚本调用此统一接口，不直接调用 ntfy/Gotify API。

### 4. Alertmanager 路由配置

```yaml
# config/alertmanager/alertmanager.yml
receivers:
  - name: ntfy
    webhook_configs:
      - url: 'https://ntfy.${DOMAIN}/homelab-alerts'
        send_resolved: true
```

## 验收标准

- [ ] ntfy Web UI 可访问
- [ ] 手机安装 ntfy App 可收到测试推送
- [ ] `scripts/notify.sh homelab-test "Test" "Hello World"` 成功推送
- [ ] Alertmanager 告警触发时 ntfy 收到通知
- [ ] Watchtower 更新容器后 ntfy 收到通知
- [ ] README 中所有服务集成说明完整可操作

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
