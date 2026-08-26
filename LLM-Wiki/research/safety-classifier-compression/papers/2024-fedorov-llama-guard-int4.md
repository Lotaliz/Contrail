---
id: paper-note-fedorov-2024-llama-guard-int4
type: paper-note
title: "Llama Guard 3-1B-INT4: Compact and Efficient Safeguard for Human-AI Conversations"
authors: ["Igor Fedorov", "Kate Plawiak", "Lemeng Wu", "Tarek Elgamal", "Naveen Suda", "Eric Smith", "Hongyuan Zhan", "Jianfeng Chi", "Yuriy Hulovatyy", "Kimish Patel", "Zechun Liu", "Changsheng Zhao", "Yangyang Shi", "Tijmen Blankevoort", "Mahesh Pasupuleti", "Bilge Soran", "Zacharie Delpierre Coudert", "Rachad Alao", "Raghuraman Krishnamoorthi", "Vikas Chandra"]
year: 2024
venue: "arXiv"
source_id: paper-fedorov-2024-llama-guard-int4
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, safety-guardrail, structured-pruning, knowledge-distillation, quantization, hardware-aware-optimization]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Llama Guard 3-1B-INT4

## 研究问题与方法

把安全 Guard 部署到资源受限设备。模型从 Llama 3.2 1B 出发，经结构压缩，以 Llama Guard 3-8B 做 token-level Logit 蒸馏，并进行 INT4 quantization-aware training；最终仍以自回归格式输出安全判断。

## 主要证据

约 440 MB，较 1B BF16 约小 7×；Moto Razr 普通 Android CPU 上至少 30 token/s、TTFT 不超过 2.5 秒。内部多语言安全集上，英文 F1/FPR 为 0.904/0.084，多数非英语语言与 1B 接近。

## 证据定位与局限

模型压缩第 3 节；结果表 1；移动端结果第 4 节；限制第 5 节。数据主要为内部 MLCommons taxonomy 派生集，论文为官方预印本；知识、语言、类别和对抗攻击能力仍受 1B 底座限制。
