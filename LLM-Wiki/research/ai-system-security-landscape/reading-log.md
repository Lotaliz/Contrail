---
id: ai-system-security-landscape-reading-log
type: synthesis
title: AI 系统安全版图：检索与范围说明
tags: [research]
project_id: ai-system-security-landscape
sources: [webpage-usenix-security-2026-cfp-ml, report-nist-2025-adversarial-ml-taxonomy, webpage-owasp-2025-llm-top-10, knowledgebase-mitre-atlas-2026]
status: active
created: 2026-09-15
updated: 2026-09-15
---

# AI 系统安全版图：检索与范围说明

## 研究问题

截至 2026-09-15，AI 系统安全的热门问题主要有哪些；USENIX Security 的主题划分与 NIST、OWASP、MITRE 等框架如何对应？

## 检索范围

- 官方来源：USENIX Security 2026 CFP 的 `Security of ML`/`Privacy of ML` 说明；NIST AI 100-2 E2025；OWASP Top 10 for LLMs and GenAI Apps 2025；MITRE ATLAS 当前知识库。
- 观察窗口：以 2025—2026 的分类和术语为主；ENISA 生命周期思想仅作为背景，没有作为核心来源展开。
- 纳入：AI/ML 特有攻击，或因 AI 组件引入新控制流、数据流和信任边界的系统攻击。
- 排除：纯 AI-for-security、无对手的一般模型缺陷、与 AI 无关的传统系统漏洞。

## 方法

1. 先提取四个来源各自的分类单位：投稿主题、攻击类型、应用风险、行动链。
2. 再以“被保护资产/生命周期”和“安全属性/攻击目标”交叉归并，避免把 prompt injection、RAG 泄露等同时重复列为多个互斥大类。
3. “热门”是基于近期标准持续更新、顶会明确纳入和多个新系统面的共同出现做定性判断，不是论文数量的严格计量排名。

## 证据边界

- 本页不是对 USENIX/IEEE S&P/CCS/NDSS 全部论文的计量分析。
- OWASP 是工程风险清单，MITRE ATLAS 是威胁行动知识库，不能直接等价为学术研究分类或论文热度。
- 安全与安全性（security vs safety）存在交叉；是否属于安全顶会问题，关键取决于有没有明确攻击者、攻击能力、攻击面和可验证系统影响。

