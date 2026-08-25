---
id: paper-note-gao-2025-content-moderation-products
type: paper-note
title: "I Cannot Write This Because It Violates Our Content Policy: Understanding Content Moderation Policies and User Experiences in Generative AI Products"
authors: ["Lan Gao", "Oscar Chen", "Rachel Lee", "Nick Feamster", "Chenhao Tan", "Marshini Chetty"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-gao-2025-content-moderation-products
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# I Cannot Write This Because It Violates Our Content Policy: Understanding Content Moderation Policies and User Experiences in Generative AI Products

## 研究问题与收录理由

论文关注生成式 AI 产品如何公开内容审核规则，以及真实用户如何体验误拦截、漏拦截和申诉。它补充了纯模型指标无法覆盖的产品治理与用户救济视角。

## 方法概览

作者分析 14 个生成式 AI 在线工具的审核政策，并研究 Reddit 上围绕创作型任务的用户讨论，将规则范围、输入输出治理、检测和处置方式与用户实际遭遇相互对照。

## 主要实验与结论

研究发现这些产品的政策通常覆盖较广，也强调输入与输出治理，但经常缺少具体执行细节、用户参与式审核机制和清晰申诉通道。用户一方面认可对恶意生成的阻断，另一方面频繁报告判定理由不足、错误处置和支持渠道欠缺。

## 局限与项目关联

这是一项社会技术研究，不提供可与 Guard 模型直接比较的准确率、吞吐或时延基线。它提示压缩后的判别器即使总体精度不变，也必须评估可解释反馈、误杀处置和申诉流程。

## 泛读结论

适合作为产品层需求与失效后治理证据；除非后续要设计用户研究或政策编码体系，否则无需升级精读。
