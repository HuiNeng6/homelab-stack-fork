---
name: 💰 Bounty - Storage Stack
about: 实现存储服务栈 (Nextcloud, MinIO, FileBrowser, Syncthing)
title: '[BOUNTY $150] Storage Stack — 存储服务'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$150 USDT**

## 任务描述

实现完整的自托管存储栈，覆盖个人云盘、对象存储、文件浏览、多设备同步。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Nextcloud | `nextcloud:29.0.7-fpm-alpine` | 个人云盘 |
| Nextcloud Nginx | `nginx:1.27-alpine` | Nextcloud FPM 前端 |
| MinIO | `minio/minio:RELEASE.2024-09-22T00-33-43Z` | 对象存储 (S3 兼容) |
| FileBrowser | `filebrowser/filebrowser:v2.31.1` | 轻量文件管理 |
| Syncthing | `lscr.io/linuxserver/syncthing:1.27.11` | P2P 文件同步 |

## 核心要求

### 1. Nextcloud

- 使用 FPM 模式 + Nginx
- 数据库使用共享 PostgreSQL (Databases Stack)
- Redis 用于缓存和锁 (共享 Redis)
- 支持 Authentik OIDC 登录
- 配置 `config.php`：`trusted_proxies`, `overwriteprotocol`, `default_phone_region`

### 2. MinIO

- Console 通过 `minio.${DOMAIN}` 访问
- API 通过 `s3.${DOMAIN}` 访问
- 配置初始化脚本：创建默认 bucket
- 可配置为 Nextcloud 的外部存储后端

### 3. 环境变量

```bash
NEXTCLOUD_ADMIN_USER=
NEXTCLOUD_ADMIN_PASSWORD=
NEXTCLOUD_DOMAIN=cloud.example.com
MINIO_ROOT_USER=
MINIO_ROOT_PASSWORD=
STORAGE_ROOT=/data/storage
```

## 验收标准

- [ ] Nextcloud 首次访问自动完成安装
- [ ] Nextcloud 可用 Authentik 账号登录
- [ ] MinIO Console 可访问，API 可用 `mc` 客户端连接
- [ ] FileBrowser 可浏览 `${STORAGE_ROOT}` 目录
- [ ] Syncthing 可与外部设备同步
- [ ] 所有服务通过 Traefik 反代，HTTPS 生效

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
