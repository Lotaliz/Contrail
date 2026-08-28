---
id: paper-note-raposo-2024-mixture-of-depths
type: paper-note
title: "Mixture-of-Depths: Dynamically Allocating Compute in Transformer-Based Language Models"
authors: ["David Raposo", "Sam Ritter", "Blake Richards", "Timothy Lillicrap", "Peter Conway Humphreys", "Adam Santoro"]
year: 2024
venue: "arXiv preprint"
source_id: paper-raposo-2024-mixture-of-depths
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, dynamic-inference, dynamic-sparsity, efficient-inference]
status: active
related: []
created: 2026-08-28
updated: 2026-08-28
---

# Mixture-of-Depths

## 核心方法

每个 block 的 router 为 token 打分，只让预先固定数量的 Top-k token 进入 attention/MLP，其余 token 绕过该 block。总计算预算和 tensor size 固定，但参与计算的 token 身份随上下文变化。

## 对自适应模型规模判断的作用

这是“运行时条件执行但不加载不同子网”的直接反例：完整权重结构存在，路由在前向过程中决定哪些 token 使用哪些 block；没有现场永久剪掉模型，也不按任务一次性选择统一 omission set。

## 边界

截至本轮核验，该来源是预印本。它优化通用语言建模的 token-level compute allocation，不涉及多模态安全 Guard、风险回退、稀有危害类别或在线批处理。
