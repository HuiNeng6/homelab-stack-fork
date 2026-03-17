---
name: 💰 Bounty - Backup & Recovery
about: 实现完整的备份与灾难恢复方案
title: '[BOUNTY $150] Backup & Recovery — 备份与恢复'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$150 USDT**

## 任务描述

实现 3-2-1 备份策略：3 份数据，2 种介质，1 份异地。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Duplicati | `lscr.io/linuxserver/duplicati:2.0.8` | 加密云备份 |
| Restic REST Server | `restic/rest-server:0.13.0` | 本地备份仓库 |

## 核心要求

### 1. 备份脚本 `scripts/backup.sh`

```
用法:
  backup.sh --target <stack|all> [选项]

选项:
  --target all          备份所有 stack 数据卷
  --target media        仅备份媒体栈
  --dry-run             显示将备份的内容，不实际执行
  --restore <backup_id> 从指定备份恢复
  --list                列出所有备份
  --verify              验证备份完整性
```

### 2. 备份目标支持

- 本地目录
- MinIO (S3 兼容)
- Backblaze B2
- SFTP
- Cloudflare R2

通过 `.env` 中 `BACKUP_TARGET=s3|b2|sftp|local` 切换。

### 3. 定时备份

通过 crontab 或 systemd timer 每日 2:00 AM 自动执行。

### 4. 恢复演练文档

`docs/disaster-recovery.md`：
- 完整恢复流程（全新主机从零恢复）
- 各服务恢复顺序（Base → DB → SSO → 其他）
- 预计恢复时间（RTO）
- 验证恢复完整性的检查清单

### 5. 备份通知

备份完成/失败后通过 ntfy 推送通知。

## 验收标准

- [ ] `backup.sh

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
