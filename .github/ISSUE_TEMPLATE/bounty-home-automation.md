---
name: 💰 Bounty - Home Automation Stack
about: 实现家庭自动化栈 (Home Assistant, Node-RED, Mosquitto, Zigbee2MQTT)
title: '[BOUNTY $130] Home Automation Stack — 家庭自动化'
labels: bounty, medium
assignees: ''
---

## 赏金金额

**$130 USDT**

## 任务描述

实现完整的智能家居自动化栈，支持 Zigbee 设备接入和可视化流程编排。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Home Assistant | `ghcr.io/home-assistant/home-assistant:2024.9.3` | 智能家居中枢 |
| Node-RED | `nodered/node-red:4.0.3` | 可视化流程编排 |
| Mosquitto | `eclipse-mosquitto:2.0.19` | MQTT Broker |
| Zigbee2MQTT | `koenkk/zigbee2mqtt:1.40.2` | Zigbee 设备网关 |
| ESPHome | `ghcr.io/esphome/esphome:2024.9.3` | ESP 设备固件管理 |

## 核心要求

### 1. Home Assistant 网络模式

Home Assistant 必须使用 `network_mode: host`，并在 README 中说明原因（mDNS/UPnP 设备发现）。

同时提供 bridge 模式的替代配置（注释掉），说明功能限制。

### 2. Mosquitto 安全配置

```
config/mosquitto/mosquitto.conf:
  -

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
