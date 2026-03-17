---
name: 💰 Bounty - Media Stack
about: 实现媒体服务栈 (Jellyfin, Sonarr, Radarr, Prowlarr, qBittorrent, Jellyseerr)
title: '[BOUNTY $200] Media Stack — 媒体服务栈'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$200 USDT** (或等值法币)

## 任务描述

实现完整的媒体服务栈，包含以下服务：

| 服务 | 镜像 | 用途 |
|------|------|------|
| Jellyfin | `jellyfin/jellyfin:10.9.11` | 媒体服务器 |
| Sonarr | `lscr.io/linuxserver/sonarr:4.0.11` | 剧集管理 |
| Radarr | `lscr.io/linuxserver/radarr:5.8.1` | 电影管理 |
| Prowlarr | `lscr.io/linuxserver/prowlarr:1.22.0` | 索引器管理 |
| qBittorrent | `lscr.io/linuxserver/qbittorrent:4.6.7` | 下载器 |
| Jellyseerr | `fallenbagel/jellyseerr:2.1.1` | 请求管理 |

## 文件结构

```
stacks/media/
├── docker-compose.yml
├── .env.example
└── README.md
```

## 要求

### 1. 目录结构

遵循 [TRaSH Guides](https://trash-guides.info/Hardlinks/How-to-setup-for/Docker/) 硬链接最佳实践：

```
/data/
├── torrents/
│   ├── movies/
│   └── tv/
└── media/
    ├── movies/
    └── tv/
```

### 2. 环境变量

通过 `.env` 管理：

- `MEDIA_ROOT` — 媒体目录
- `DOWNLOADS_ROOT` — 下载目录
- `PUID` / `PGID` / `TZ`
- 各服务密码

### 3. Traefik 配置

- 每个服务暴露子域名：`jellyfin.${DOMAIN}`, `sonarr.${DOMAIN}`, ...
- HTTPS 自动证书
- 可选：Authentik Forward Auth 保护

### 4. 健康检查

每个容器必须有 `healthcheck` 配置。

### 5. 启动顺序

`depends_on` + `condition: service_healthy` 确保正确启动顺序。

### 6. README 内容

- 服务功能说明
- 启动命令
- 目录结构说明
- Sonarr/Radarr 连接 qBittorrent 的配置步骤
- Jellyfin 媒体库添加步骤
- 常见问题 (FAQ)

## 验收标准

- [ ] `docker compose up -d` 成功启动所有 6 个服务
- [ ] 所有服务健康检查通过 (`docker compose ps` 显示 healthy)
- [ ] Traefik 反代生效，各子域名可访问
- [ ] Sonarr 可以搜索剧集并触发 qBittorrent 下载
- [ ] Jellyfin 识别 `/data/media` 中的媒体库
- [ ] README 文档完整
- [ ] 无硬编码密码/密钥

## 认领方式

在下方评论 "我来认领"，确认后开始开发。

## 支付

验收通过后 3 个工作日内支付 USDT (TRC20) 或等值法币。


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
