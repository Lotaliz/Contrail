---
id: paper-note-liu-2023-dejavu
type: paper-note
title: "Deja Vu: Contextual Sparsity for Efficient LLMs at Inference Time"
authors: ["Zichang Liu", "Jue Wang", "Tri Dao", "Tianyi Zhou", "Binhang Yuan", "Zhao Song", "Anshumali Shrivastava", "Ce Zhang", "Yuandong Tian", "Christopher Ré", "Beidi Chen"]
year: 2023
venue: "ICML 2023"
source_id: paper-liu-2023-dejavu
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, dynamic-inference, dynamic-sparsity, hardware-aware-optimization, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# Deja Vu

## 与当前课题的关系

Deja Vu 在线预测输入相关的 attention head 与 MLP contextual sparsity，并通过异步、硬件感知实现获得 wall-clock 加速。它说明“任务自适应主干剪枝”不是空白，也提醒当前课题必须明确剪的是层、头、FFN 块还是激活神经元；不同粒度对应完全不同的 kernel、内存和组批约束。

## 证据边界

论文面向通用生成 LLM，不验证安全分类边界，也不联合视觉/文本 Token 预算。其大模型结果不能直接外推到 1B–8B Guard 或高 batch 分类服务。
