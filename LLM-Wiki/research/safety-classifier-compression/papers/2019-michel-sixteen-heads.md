---
id: paper-note-michel-2019-sixteen-heads
type: paper-note
title: "Are Sixteen Heads Really Better than One?"
authors: ["Paul Michel", "Omer Levy", "Graham Neubig"]
year: 2019
venue: "NeurIPS 2019"
source_id: paper-michel-2019-sixteen-heads
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, structured-pruning, model-compression]
status: active
related: []
created: 2026-08-31
updated: 2026-08-31
---

# Are Sixteen Heads Really Better than One?

## 核心发现

通过推理期逐头消融与重要性排序，论文发现许多注意力头可以删除而不显著影响 NLP 任务性能，部分层在单层独立消融时甚至只保留一个头。机器翻译中，自注意力比 encoder-decoder attention 更可剪，说明头冗余受注意力类型和信息路由位置影响。

## 对本课题的边界

该结果支持“头内存在冗余”，不支持“整个 MHA 块不重要”。单层、独立的 oracle 消融也不能代表多个头联合剪除后的交互损失；多模态安全中的跨模态注意力应类比更敏感的 encoder-decoder attention，作为待验证假设而非既成结论。

## 证据位置

- 摘要与主实验：大比例头可删除；自注意力与 encoder-decoder attention 的敏感性不同。
