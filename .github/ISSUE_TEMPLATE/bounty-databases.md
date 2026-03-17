---
name: 💰 Bounty - Databases Stack
about: 实现共享数据库栈 (PostgreSQL, Redis, MariaDB) + 管理界面
title: '[BOUNTY $100] Databases Stack — 共享数据库'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$100 USDT**

## 任务描述

实现共享数据库层，供 Nextcloud、Outline、Gitea、Authentik 等服务共用，避免每个服务各自运行独立数据库浪费资源。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| PostgreSQL | `postgres:16.4-alpine` | 主数据库 (多租户) |
| Redis | `redis:7.4.0-alpine` | 缓存/队列 |
| MariaDB | `mariadb:11.5.2` | MySQL 兼容 (Nextcloud 可选) |
| pgAdmin | `dpage/pgadmin4:8.11` | PostgreSQL 管理界面 |
| Redis Commander | `rediscommander/redis-commander:latest-sha` | Redis 管理界面 |

## 核心要求

### 1. 多租户 PostgreSQL

`scripts/init-databases.sh` 初始化脚本：

```bash
# 为每个服务创建独立 database + user
create_db "nextcloud" "${NEXTCLOUD_DB_PASSWORD}"
create_db "gitea"     "${GITEA_DB_PASSWORD}"
create_db "outline"   "${OUTLINE_DB_PASSWORD}"
create_db "authentik" "${AUTHENTIK_DB_PASSWORD}"
create_db "grafana"   "${GRAFANA_DB_PASSWORD}"
```

脚本必须是**幂等的**（重复执行不报错，不重置已有数据）。

### 2. Redis 多数据库分配

在各服务的 compose 中通过 `?db=N` 参数隔离：

```
DB 0 — Authentik
DB 1 — Outline
DB 2 — Gitea
DB 3 — Nextcloud
DB 4 — Grafana sessions
```

### 3. 备份集成

`scripts/backup-databases.sh`：
- `pg_dumpall` 备份所有 PostgreSQL 数据库
- `redis-cli BGSAVE` 触发 Redis 持久化
- 压缩为 `.tar.gz`，保留最近 7 天
- 可选：上传到 MinIO

### 4. 健康检查

所有数据库容器必须有严格的健康检查，其他 Stack 通过 `depends_on: condition: service_healthy` 等待。

### 5. 网络隔离

数据库服务**不加入** `proxy` 网络，仅暴露给 `internal` 网络，不通过 Traefik 对外暴露（管理界面除外）。

### 6. 环境变量

```bash
POSTGRES_ROOT_PASSWORD=
REDIS_PASSWORD=
MARIADB_ROOT_PASSWORD=
PGADMIN_EMAIL=
PGADMIN_PASSWORD=
# 各服务 DB 密码
NEXTCLOUD_DB_PASSWORD=
GITEA_DB_PASSWORD=
OUTLINE_DB_PASSWORD=
AUTHENTIK_DB_PASSWORD=
```

## 验收标准

- [ ] `init-databases.sh` 运行后所有数据库和用户创建成功
- [ ] `init-databases.sh` 重复运行不报错
- [ ] pgAdmin 可访问并连接 PostgreSQL
- [ ] 其他 Stack (Gitea/Nextcloud) 可通过内部 hostname 连接数据库
- [ ] 数据库容器**不**暴露到宿主机端口（仅内部网络）
- [ ] `backup-databases.sh` 生成有效的 `.tar.gz` 备份
- [ ] README 包含各服务连接字符串示例

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
