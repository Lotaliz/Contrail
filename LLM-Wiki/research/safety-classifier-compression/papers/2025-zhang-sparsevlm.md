---
id: paper-note-zhang-2025-sparsevlm
type: paper-note
title: "SparseVLM: Visual Token Sparsification for Efficient Vision-Language Model Inference"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-zhang-2025-sparsevlm
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# SparseVLM

来源：[ICML 2025 PMLR 官方页面](https://proceedings.mlr.press/v267/zhang25s.html)。本轮阅读摘要与方法概要，未运行代码。

SparseVLM 先从文本 token 中选择与视觉相关的 raters，再用它们在 LLM self-attention 中评价视觉 token；随后按层渐进剪枝，以矩阵秩估计自适应保留率，并把被删视觉 token 压缩回收到少量表示。作者在 LLaVA 上报告 FLOPs 降低 54%、CUDA time 降低 37%，保持 97% accuracy。

它比简单 FastV 多了文本 rater 过滤、样本/层级预算和信息回收，但仍需先运行视觉塔与前几层 LLM。安全迁移时最值得保留的是“只让视觉相关文本投票”和“被删证据回收”，而非直接照搬 attention Top-k。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]。

