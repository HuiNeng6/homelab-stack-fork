---
name: 💰 Bounty - Observability Stack
about: 实现完整可观测性 (Prometheus, Grafana, Loki, Tempo, Alertmanager, Uptime Kuma)
title: '[BOUNTY $280] Observability Stack — 完整可观测性'
labels: bounty, hard
assignees: ''
---

## 赏金金额

**$280 USDT**

## 任务描述

实现覆盖 Metrics / Logs / Traces / Alerting / Uptime 的完整可观测性栈（可观测性三支柱 + SLA 监控）。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Prometheus | `prom/prometheus:v2.54.1` | 指标采集 |
| Grafana | `grafana/grafana:11.2.2` | 可视化面板 |
| Loki | `grafana/loki:3.2.0` | 日志聚合 |
| Promtail | `grafana/promtail:3.2.0` | 日志采集 Agent |
| Tempo | `grafana/tempo:2.6.0` | 分布式链路追踪 |
| Alertmanager | `prom/alertmanager:v0.27.0` | 告警路由 |
| cAdvisor | `gcr.io/cadvisor/cadvisor:v0.50.0` | 容器指标 |
| Node Exporter | `prom/node-exporter:v1.8.2` | 主机指标 |
| Uptime Kuma | `louislam/uptime-kuma:1.23.15` | 服务可用性监控 |
| Grafana OnCall | `grafana/oncall:v1.9.22` | 值班告警管理 |

## 核心要求

### 1. Prometheus 采集目标

`config/prometheus/prometheus.yml` 需采集：

```yaml
scrape_configs:
  - job_name: cadvisor        # 容器资源
  - job_name: node-exporter   # 主机资源
  - job_name: traefik         # 反代指标
  - job_name: authentik       # SSO 指标
  - job_name: nextcloud       # 存储指标
  - job_name: gitea           # 代码托管指标
  - job_name: prometheus      # 自监控
```

### 2. Grafana 预置 Dashboard

必须通过 `provisioning` 自动加载（不需要手动导入）：

| Dashboard | 来源 Dashboard ID |
|-----------|------------------|
| Node Exporter Full | 1860 |
| Docker Container & Host Metrics | 179 |
| Traefik Official | 17346 |
| Loki Dashboard | 13639 |
| Uptime Kuma | 18278 |

所有 Dashboard 以 JSON 文件存放在 `config/grafana/dashboards/`。

### 3. 告警规则

`config/prometheus/alerts/` 包含：

```yaml
# host.yml
- 主机 CPU > 80% 持续 5 分钟
- 主机内存 > 90%
- 主机磁盘 > 85%
- 主机磁盘 IO 异常

# containers.yml  
- 容器重启次数 > 3 次/小时
- 容器 OOM 被杀
- 容器健康检查失败

# services.yml
- Traefik 5xx 错误率 > 1%
- 服务响应时间 P99 > 2s
```

所有告警路由到 Alertmanager → ntfy 推送。

### 4. Loki 日志采集

Promtail 配置采集：
- 所有 Docker 容器日志（自动发现）
- 系统日志 `/var/log/syslog`
- Traefik access log

Grafana 中提供 Loki Explore 快捷链接：`/d/logs/logs`

### 5. Uptime Kuma

`scripts/uptime-kuma-setup.sh` 自动创建监控项：
- 检测所有已部署服务的健康端点
- 状态页通过 `status.${DOMAIN}` 公开访问（无需登录）
- 宕机通知发送到 ntfy

### 6. Grafana 认证

- 集成 Authentik OIDC
- `homelab-admins` 组 → Grafana Admin 角色
- `homelab-users` 组 → Grafana Viewer 角色

### 7. 数据保留策略

```bash
# .env
PROMETHEUS_RETENTION=30d
LOKI_RETENTION=7d
TEMPO_RETENTION=3d
```

## 验收标准

- [ ] Grafana 可访问，所有预置 Dashboard 自动加载
- [ ] Prometheus targets 页面所有 job 显示 UP
- [ ] Loki 中可查询到任意容器日志
- [ ] 手动触发 CPU 告警（`stress --cpu 4`），ntfy 在 5 分钟内收到告警
- [ ] Uptime Kuma 状态页可公开访问
- [ ] `uptime-kuma-setup.sh` 自动创建所有服务监控项
- [ ] Grafana 可用 Authentik 账号登录，权限正确
- [ ] cAdvisor 容器资源面板正常显示

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
