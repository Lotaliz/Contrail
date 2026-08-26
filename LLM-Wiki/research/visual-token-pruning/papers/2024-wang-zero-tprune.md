---
id: paper-note-wang-2024-zero-tprune
type: paper-note
title: "Zero-TPrune: Zero-Shot Token Pruning through Leveraging of the Attention Graph in Pre-Trained Transformers"
authors: ["Hongjie Wang", "Bhishma Dedhia", "Niraj K. Jha"]
year: 2024
venue: "CVPR 2024"
source_id: paper-wang-2024-zero-tprune
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, training-free, efficient-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Zero-TPrune: Zero-Shot Token Pruning through Leveraging of the Attention Graph in Pre-Trained Transformers

## 收录与问题

面向无法承担微调的边缘部署，研究如何仅利用预训练 Transformer 的注意力图完成训练自由 token 剪枝。

## 核心方法

把 token 视为注意力图节点，用 Weighted PageRank 估计全局重要性，再结合 token 相似性进行划分与删除，兼顾 relevance 和 redundancy。

## 主要结论

作者报告在 DeiT-S 上无需微调即可降低 34.7% FLOPs、提高 45.3% throughput，Top-1 仅下降 0.4 个百分点；与需要微调的同类方法相比精度差距约 0.1 点。

## 证据定位

摘要；方法中的 attention graph、WPR 与 similarity partition；ImageNet 主表及 pruning ratio 消融。

## 局限

WPR、相似性计算和排序有固定成本；当前主证据集中于 ImageNet 分类，端侧 batch=1 与 P95 latency 未形成统一报告。
