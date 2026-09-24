---
id: ai-system-security-landscape
type: research-overview
title: AI 系统安全问题版图
aliases: [AI Security Landscape, AI 系统安全分类]
tags: [research]
status: active
related: [ai-safety-systems-security-venues, model-compression-privacy]
sources: [webpage-usenix-security-2026-cfp-ml, report-nist-2025-adversarial-ml-taxonomy, webpage-owasp-2025-llm-top-10, knowledgebase-mitre-atlas-2026]
created: 2026-09-15
updated: 2026-09-15
---

# AI 系统安全问题版图

## 一句话概述

以安全属性 × AI 生命周期/系统资产为主轴，统一组织模型级 adversarial ML、LLM/RAG/agent 应用风险、隐私攻击、供应链和运行时基础设施安全。

## 研究范围

### 包含

- 攻击者故意操纵、窃取、滥用、耗尽或绕过 AI 系统的攻击与防御。
- 数据、训练、模型、推理接口、RAG、memory、agent、工具、serving 和硬件等完整系统组件。
- 机密性、完整性、可用性、授权控制、来源与问责等安全目标。

### 不包含

- 没有攻击者、攻击面和安全影响的一般准确率、鲁棒性或效率改进。
- 仅因模型能力不足产生的普通 hallucination、偏差或 benign distribution shift；当攻击者可诱导或放大并造成系统影响时再纳入。
- 单纯使用 AI 完成传统安全任务的 AI-for-security 工作，除非研究问题是该 AI 系统自身的安全。

## 当前结论

USENIX Security 将相关投稿宏观分为 `Security of ML` 与 `Privacy of ML`，并要求覆盖数据整理、预训练/后训练和部署阶段的明确威胁模型。NIST 以 evasion、poisoning、privacy 和 GenAI misuse 组织 adversarial ML；OWASP 更偏 LLM 应用组件；MITRE ATLAS 更偏真实攻击行动链。最实用的内部分类不是只选其一，而是组合为二维矩阵：

1. **攻击目标/安全属性**：完整性、机密性/隐私、可用性/成本、授权/控制、来源/问责。
2. **攻击面/生命周期**：数据供应链、训练与适配、模型产物、推理与 guard、RAG/向量库/memory、agent/工具、多租户 serving/硬件、用户与内容生态。

## 项目文档

- [[LLM-Wiki/research/ai-system-security-landscape/landscape.md|热门问题与技术版图]]
- [[LLM-Wiki/research/ai-system-security-landscape/comparison.md|USENIX、NIST、OWASP、MITRE 分类对照]]
- [[LLM-Wiki/research/ai-system-security-landscape/reading-log.md|检索与范围说明]]

## 相关项目

- [[LLM-Wiki/research/ai-safety-systems-security-venues/overview.md|安全顶会中的 AI 安全系统工作]]
- [[LLM-Wiki/research/model-compression-privacy/overview.md|模型压缩与隐私泄露]]

