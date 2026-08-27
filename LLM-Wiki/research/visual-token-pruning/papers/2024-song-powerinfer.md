---
id: paper-note-song-2024-powerinfer
type: paper-note
title: "PowerInfer: Fast Large Language Model Serving with a Consumer-grade GPU"
authors: ["Yixin Song", "Zeyu Mi", "Haotong Xie", "Haibo Chen"]
year: 2024
venue: "SOSP 2024"
source_id: paper-song-2024-powerinfer
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, dynamic-inference, dynamic-sparsity, model-serving, hardware-aware-optimization, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# PowerInfer

## 与当前课题的关系

PowerInfer 利用神经元激活的幂律局部性，将常热神经元常驻 GPU、冷神经元放在 CPU，并结合自适应预测器与稀疏算子。它说明主干“剪枝”若要成为系统贡献，必须落实为权重驻留、数据传输和稀疏 kernel 设计，而不只是减少理论计算。

## 证据边界

论文目标是消费级 GPU 上的通用 LLM，不涉及多请求安全 Guard、视觉 Token 或安全质量约束。若当前系统部署在数据中心 GPU 且权重全部常驻，PowerInfer 的 CPU-GPU 放置机制未必适用。
