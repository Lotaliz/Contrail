---
id: paper-note-yu-2022-orca
type: paper-note
title: "Orca: A Distributed Serving System for Transformer-Based Generative Models"
authors: ["Gyeong-In Yu", "Joo Seong Jeong", "Geon-Woo Kim", "Soojeong Kim", "Byung-Gon Chun"]
year: 2022
venue: "OSDI 2022"
source_id: paper-yu-2022-orca
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, model-serving, continuous-batching, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# Orca

## 与当前课题的关系

Orca 以 iteration-level scheduling 允许自回归请求在每轮重新组批，并用 selective batching 处理不能统一批量化的操作。它奠定了连续批处理的基本抽象，但假设同一批请求执行相同模型图；当前课题的请求级 Token 数与主干子网同时变化，会进一步破坏这一同构假设。

## 证据边界

作者在 GPT-3 175B 设置中报告相同延迟水平下相对 FasterTransformer 的显著吞吐提升。该结果不能直接外推到只输出安全标签的 Guard；本项目只引用其调度抽象，不引用速度数字预测 Guard 收益。
