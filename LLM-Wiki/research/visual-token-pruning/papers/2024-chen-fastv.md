---
id: paper-note-chen-2024-fastv
type: paper-note
title: "An Image is Worth 1/2 Tokens After Layer 2: Plug-and-Play Inference Acceleration for Large Vision-Language Models"
authors: ["Liang Chen", "Haozhe Zhao", "Tianyu Liu", "Shuai Bai", "Junyang Lin", "Chang Zhou", "Baobao Chang"]
year: 2024
venue: "ECCV 2024"
source_id: paper-chen-2024-fastv
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, training-free, efficient-inference]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-26
---

# An Image is Worth 1/2 Tokens After Layer 2

## 问题与观察

FastV 观察到 decoder-only LVLM 深层对视觉 token 的平均注意力远低于系统/文本 token，并据此提出：先让浅层吸收视觉信息，再在某一 LLM 层之后删除低分视觉 token（§3–§4）。

## 方法

在过滤层 $K$，按 token 接收到的平均 attention score 排序，删除末尾 $R\%$ 视觉 token，后续 MHA 与 FFN 均不再处理它们；无需训练，可配置过滤层与比例（§4.1）。

## 任务与证据

- 模型：LLaVA-1.5-7B/13B、QwenVL-Chat、Video-LLaVA。
- 任务覆盖 captioning（NoCaps、Flickr30K）、A-OKVQA/MMMU、OCR-VQA、MME/MMVet/SEED、视频 QA。
- Table 1：LLaVA-1.5-13B 在 layer 2 后删 50% 视觉 token，FLOPs 约为基线 55%，四任务平均分 73.6，与基线相同；删 75% 或 90% 时，生成式 captioning 指标更早下降。
- Table 4 报告真实推理预算，说明理论 FLOPs 可转化为部分 latency 收益，但测量范围有限。

## 边界与后续反证

FastV 的 attention-based 排名后来被 [[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-token-pruning-right-problem.md|Wen et al.]] 发现存在明显空间位置偏置，在高压缩和 RefCOCO 定位上可弱于随机/池化。FastV 仍是重要的 training-free 基线，但不能把平均 benchmark 保持解释为视觉证据完整保留。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
