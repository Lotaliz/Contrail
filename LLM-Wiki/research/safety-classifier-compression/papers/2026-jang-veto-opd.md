---
id: paper-note-jang-2026-veto-opd
type: paper-note
title: "Stable On-Policy Distillation through Adaptive Target Reformulation"
authors: ["Ijun Jang", "Jewon Yeom", "Juan Yeo", "Hyunggyu Lim", "Taesup Kim"]
year: 2026
venue: "Findings of ACL 2026"
source_id: paper-jang-2026-veto-opd
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-25
---

# Stable On-Policy Distillation through Adaptive Target Reformulation

## 核心方法

Veto 在教师与学生 logits 之间构造几何目标分布，以参数控制错误 token 抑制和分布多样性。论文把 forward KL 在低学生概率处的梯度病态与 reverse KL 的 mode collapse 作为目标重构动机。

## 证据边界

证据位置：§2 分析、§3 方法、§4 实验与消融。作者限制包括依赖教师质量、超参数敏感和数据规模有限。本项目将其视为安全 OPD 的稳定化候选，不视为 Guard 上已成立的安全收益。

