---
id: paper-note-uddin-2026-conformal-routing
type: paper-note
title: "Conformal LLM Routing with Distribution-Free Safety Guarantees"
authors: ["Iqtedar Uddin", "André Bauer"]
year: 2026
venue: "ACL 2026 Student Research Workshop"
source_id: paper-uddin-2026-conformal-routing
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, model-routing, efficient-inference, safety-guardrail]
status: active
related: []
created: 2026-09-04
updated: 2026-09-04
---

# Conformal LLM Routing with Distribution-Free Safety Guarantees

## 与 Profile 路由的关系

论文以文本 embedding 上的 logistic gate 路由便宜/昂贵 LLM，并用 Clopper–Pearson conformal calibration 为“被路由到便宜模型的请求中失败比例”提供有限样本概率保证。它直接说明：profile 不应只绑定平均 accuracy，而可绑定校准后的 violation contract。

## 证据边界

论文发表于 ACL 2026 Student Research Workshop，评测是 GSM8K/MMLU 的通用 LLM 路由，不是内容安全、多模态 token 剪枝或分布漂移下的长期保证。对 Guard 的迁移仍需改成 unsafe false-negative、policy-wise worst group 和选择性拒绝/回退。

