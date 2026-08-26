---
id: paper-note-xia-2024-sheared-llama
type: paper-note
title: "Sheared LLaMA: Accelerating Language Model Pre-training via Structured Pruning"
authors: ["Mengzhou Xia", "Tianyu Gao", "Zhiyuan Zeng", "Danqi Chen"]
year: 2024
venue: "ICLR 2024"
source_id: paper-xia-2024-sheared-llama
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, method, structured-pruning, model-compression, efficient-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Sheared LLaMA

## 核心方法

把 LLaMA2-7B 定向结构剪枝到 1.3B/2.7B，联合裁剪层、head、中间维与 hidden size；恢复训练用 dynamic batch loading 根据各数据域损失动态配比。

## 主要证据与边界

派生模型优于多种同尺寸开源模型，作者报告只需从头训练这些小模型约 3% 的 compute。结论支持“复用大模型权重比每个尺寸从头预训练便宜”，但没有安全分类或统一真实设备时延实验。
