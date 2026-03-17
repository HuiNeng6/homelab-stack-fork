---
name: 💰 Bounty - AI Stack
about: 实现 AI 服务栈 (Ollama, Open WebUI, Stable Diffusion, LocalAI)
title: '[BOUNTY $220] AI Stack — 本地 AI 服务'
labels: bounty, hard
assignees: ''
---

## 赏金金额

**$220 USDT**

## 任务描述

实现完整的本地 AI 推理栈，支持 CPU/GPU 自适应部署。

## 服务清单

| 服务 | 镜像 | 用途 |
|------|------|------|
| Ollama | `ollama/ollama:0.3.12` | LLM 推理引擎 |
| Open WebUI | `ghcr.io/open-webui/open-webui:0.3.32` | LLM Web 界面 |
| Stable Diffusion | `universonic/stable-diffusion-webui:latest-sha` | 图像生成 |
| Perplexica | `itzcrazykns1337/perplexica:main-sha` | AI 搜索引擎 |

## 核心要求

### 1. GPU 自适应

```yaml
# docker-compose.yml 需支持：
# 1. NVIDIA GPU (CUDA)
# 2. AMD GPU (ROCm)
# 3. 纯 CPU fallback
# 通过环境变量

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
