---
id: note-2025-islam-adaptmerge
type: paper-note
title: "AdaptMerge: Inference Time Adaptive Visual and Language-Guided Token Merging for Efficient Large Multimodal Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-islam-2025-adaptmerge
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-16
---

来源：[ACL Anthology](https://aclanthology.org/2025.findings-emnlp.387/)及[正式 PDF](https://aclanthology.org/2025.findings-emnlp.387.pdf)。本轮核 §3.2.1、Figure 2、§4，未复现或下载原件。

## 原文方法与执行位置

AVTM 在每个视觉 encoder layer 的 Attention 与 MLP 之间逐层合并；以 attention key 与其他 key 的平均余弦相似性衡量多样性，保留高多样性 token，将其余平均合并到最相似的保留 token。后续 ALVTM 在视觉塔之后基于文本特征做语言引导合并；不能把 ALVTM 的语言条件性误归给早期 AVTM。免训练，是真正 intra-ViT merging 而非 pure pruning。

## 生成式证据与数据

Gemma3-4B/12B，在 OKVQA、AI2D、SQA、TextVQA 上生成答案。4B：TFLOPs 7.91→5.12；OKVQA 53.67→53.47，AI2D 68.10→65.12，SQA 70.55→70.02，TextVQA 65.50→61.44（Table 1）。联合合并保持通用 VQA 较好，但 OCR/TextVQA 退化更明显。此表是 FLOPs，不是实测端到端 latency。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。

