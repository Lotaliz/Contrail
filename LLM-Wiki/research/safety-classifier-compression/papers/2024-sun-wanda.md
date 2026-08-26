---
id: paper-note-sun-2024-wanda
type: paper-note
title: "A Simple and Effective Pruning Approach for Large Language Models"
authors: ["Mingjie Sun", "Zhuang Liu", "Anna Bair", "J. Zico Kolter"]
year: 2024
venue: "ICLR 2024"
source_id: paper-sun-2024-wanda
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, method, unstructured-pruning, model-compression, training-free]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Wanda

## 核心方法

按输出通道计算 weight magnitude × input activation norm，删除低分权重；无需 retraining 或 weight update，支持非结构化与半结构化稀疏。

## 主要证据与边界

在 LLaMA/LLaMA-2 上明显优于单纯 magnitude pruning，并接近更昂贵的重构方法；附录报告 Wanda 额外计算远低于 SparseGPT。论文主要验证困惑度和通用任务，不能在没有稀疏 kernel 的设备上把稀疏率直接解释为吞吐。
