---
id: paper-note-zhang-2025-sparsevlm
type: paper-note
title: "SparseVLM: Visual Token Sparsification for Efficient Vision-Language Model Inference"
authors: ["Yuan Zhang", "Chun-Kai Fan", "Junpeng Ma", "Wenzhao Zheng", "Tao Huang", "Kuan Cheng", "Denis A. Gudovskiy", "Tomoyuki Okuno", "Yohei Nakata", "Kurt Keutzer", "Shanghang Zhang"]
year: 2025
venue: "ICML 2025"
source_id: paper-zhang-2025-sparsevlm
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-24
---

# SparseVLM: Visual Token Sparsification for Efficient Vision-Language Model Inference

## 核心方法

SparseVLM 是 decoder 内部的 training-free 渐进压缩：先选出与视觉信号相关的文本 token 作为 raters，再复用视觉—文本 self-attention 为视觉 token 打分；以 attention matrix rank 自适应决定各层保留率，并把部分被删 token 聚类回收成紧凑表示（§3.1–§3.3）。

## 实验与证据

- LLaVA、Qwen2-VL、Mini-Gemini、Video-LLaVA；八个图像 benchmark 与四个视频 QA benchmark。
- LLaVA 保留 192/576 token 时，综合相对性能 99.1%，FLOPs 4.62→2.14T，latency 57.82→36.50ms；保留 128 时为 96.7%、1.72T、33.28ms（Table 1）。
- Video-LLaVA 从 2048 减至 194 token：SparseVLM 平均 accuracy 相对值 95.0%，FastV 为 80.3%（Table 3）。
- 论文报告 37% CUDA latency 下降、仅 0.9% accuracy drop 的配置（摘要/§1）。

## 局限与反证

方法需访问或重构 decoder attention；论文为兼容 FlashAttention 设计了额外实现，实际 kernel 开销不可由 FLOPs直接推断。[[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-token-pruning-right-problem.md|Wen et al.]] 在统一复核中发现 SparseVLM 在部分普通 benchmark 与 RefCOCO 上弱于随机/池化，说明 text-guided attention 不是稳定的通用重要性估计器；但在 Visual Haystack 等强文本条件任务中，语言指导又确实必要。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
