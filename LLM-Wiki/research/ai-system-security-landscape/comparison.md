---
id: ai-system-security-taxonomy-comparison
type: synthesis
title: USENIX、NIST、OWASP 与 MITRE 的 AI 安全分类对照
tags: [research]
project_id: ai-system-security-landscape
sources: [webpage-usenix-security-2026-cfp-ml, report-nist-2025-adversarial-ml-taxonomy, webpage-owasp-2025-llm-top-10, knowledgebase-mitre-atlas-2026]
status: active
created: 2026-09-15
updated: 2026-09-15
---

# USENIX、NIST、OWASP 与 MITRE 的 AI 安全分类对照

## 四套分类各自回答什么问题

| 框架 | 基本分类单位 | 最适合回答 | 不足 |
|---|---|---|---|
| USENIX Security | 学术投稿主题：Security of ML、Privacy of ML；再按具体传统系统领域归类 | 研究是否具有系统安全贡献、应投哪个方向 | 粒度较粗，不直接给出 LLM/agent 风险清单 |
| NIST AI 100-2 E2025 | AI 类型、生命周期、攻击者目标/知识/能力；evasion、poisoning、privacy、misuse | adversarial ML 的统一技术语言与风险分析 | 对应用集成、权限和 downstream 执行细节不如 OWASP 具体 |
| OWASP GenAI Top 10 2025 | LLM/GenAI 应用漏洞 | 工程团队应检查哪些应用风险和控制 | 类别可能跨生命周期和安全属性，不能直接当学术领域划分 |
| MITRE ATLAS | 从侦察、访问、执行、持久化到 exfiltration/impact 的战术技术 | 红队、威胁建模和真实攻击链 | 不表示论文热度，也不区分每个技术的学术成熟度 |

## 术语映射

| 本项目统一类别 | USENIX | NIST | OWASP 2025 | MITRE ATLAS |
|---|---|---|---|---|
| 对抗规避、越狱与 prompt injection | Security of ML | Evasion / GenAI misuse | LLM01 Prompt Injection | Execution、Defense Evasion、AI Attack Staging |
| 数据/模型投毒与后门 | Security of ML | Poisoning / Backdoor / Model Poisoning | LLM03 Supply Chain、LLM04 Data and Model Poisoning | Resource Development、Persistence、Impact |
| 隐私与训练数据泄露 | Privacy of ML | Privacy attacks | LLM02 Sensitive Information Disclosure、LLM07 System Prompt Leakage | Collection、Exfiltration |
| RAG、向量与 memory | Security/Privacy of ML 或具体系统领域 | Poisoning、Privacy、Misuse 的组合 | LLM08 Vector and Embedding Weaknesses | Collection、AI Attack Staging、Impact |
| Agent、工具和权限 | Security of ML / System Security | GenAI misuse | LLM06 Excessive Agency、LLM05 Improper Output Handling | Execution、Privilege Escalation、Lateral Movement、Impact |
| 可用性和成本攻击 | Security of ML / System Security | Evasion/availability-oriented abuse | LLM10 Unbounded Consumption | Impact |
| 输出/内容生态 | Human Aspects 或具体应用领域 | GenAI misuse | LLM09 Misinformation、LLM05 Improper Output Handling | Impact |

## 推荐使用方式

- 写安全顶会论文：先按 USENIX 的 threat model 和 systems relevance 判断是否是安全问题。
- 做算法威胁建模：用 NIST 的攻击者目标、能力、知识和生命周期术语。
- 设计 LLM/RAG/agent 产品检查表：用 OWASP 具体风险项。
- 做红队与攻击链覆盖：用 MITRE ATLAS 检查攻击的前置条件、横向移动、数据收集和最终影响。

