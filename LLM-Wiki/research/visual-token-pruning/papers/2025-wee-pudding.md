---
id: paper-note-wee-2025-pudding
type: paper-note
title: "Prompt-based Depth Pruning of Large Language Models"
authors: ["Juyun Wee", "Minjae Park", "Jaeho Lee"]
year: 2025
venue: "ICML 2025"
source_id: paper-wee-2025-pudding
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, dynamic-inference, model-routing, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# PuDDing

## 与当前课题的关系

PuDDing 观察到 Transformer block 重要性具有任务依赖性，并训练轻量 router 按 prompt 从若干 omission sets 中选择执行路径。它与“基于任务自适应的 LLM 主干剪枝”直接重合，因此该模块本身不能作为当前论文的主要算法新颖性。

## 可区分空间

安全 Guard 可研究 prompt 任务类型之外的风险难度、模态证据和策略类别，并将主干路径选择与视觉/文本 Token 覆盖、批处理效率及安全约束联合优化。仍需实验验证 Guard 中的最优省略层是否确实依赖这些因素。
