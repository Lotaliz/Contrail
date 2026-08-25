---
id: paper-note-alvar-2025-divprune
type: paper-note
title: "DivPrune: Diversity-based Visual Token Pruning for Large Multimodal Models"
authors: ["Saeed Ranjbar Alvar", "Gursimran Singh", "Mohammad Akbari", "Yong Zhang"]
year: 2025
venue: "CVPR 2025"
source_id: paper-alvar-2025-divprune
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

# DivPrune: Diversity-based Visual Token Pruning for Large Multimodal Models

## 核心问题与方法

论文认为高压缩下不应只追逐单 token importance，而应避免保留集合内部重复。DivPrune 把选择建模为 max-min diversity problem，在视觉 token 间最大化最小两两距离；在进入 LLM 的 layer 0 前一次执行，无需微调或校准集（§3）。

## 任务与结果

- 模型：LLaVA-1.5/1.6、LLaVA-NeXT-Video；覆盖开放/封闭 QA、推理、captioning 与视频 QA，共 16 个 image/video-language 数据集。
- 极端约 15% TFLOPs 配置下，DivPrune 在多个 captioning/QA 指标上显著优于 FastV/VTW；Table 1 还显示不同基础模型的高压缩敏感性很不一致。
- 视频设置从 6.539T 降到 0.937T（14.1%）；prefill 0.330→0.161s，端到端 4.37→3.39s（Table 2）。这表明 prefill 大降不会等比例转化为总生成时延。
- Table 4：random 平均分比 DivPrune 低 5.6%，Min-Max 冗余选择低约 15.8%，支持“多样性”比单纯高分更重要。

## 局限

两两距离计算增加 prefill 开销；论文报告其 prefill 比部分简单基线慢 6%–7%，但由于只计算一次，端到端生成反而快 1%–7%（§4.5）。该结论与输出长度、解码实现和 batch 强相关。多样性是 task-agnostic 覆盖信号，不保证保留与具体问题最相关的细节。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
