---
id: note-2026-cho-restore
type: paper-note
title: "Improving Visual Token Reduction via Rectifying Distortions for Efficient Multimodal LLM Inference"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-cho-2026-restore
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-09
updated: 2026-09-09
---

# RESTORE

来源：[作者项目页](https://cvlab.yonsei.ac.kr/projects/RESTORE/)与 [arXiv 原文](https://arxiv.org/abs/2606.01711)；阅读摘要、机制与相关消融，未运行代码。

## 方法与直接证据

RESTORE 指出缩短视觉序列会同时扭曲位置关系与 LLM 内部视觉注意力：连续重编号改变原空间关系，保留原位置又会因 RoPE 距离偏置压低视觉注意力。方法保留原位置索引、按被合并组大小和相对距离校准注意力，并用区别性 anchor 做 token merging。论文还报告 TextVQA 在 merging 下会因局部高频信息被平均而退化。

## 与本课题的边界

RESTORE 对齐的是压缩前后的**位置与注意力行为**，不是用教师监督恢复视觉 hidden states。它说明即使 token 内容相近，位置和注意力质量也可能导致下游偏差；安全小字/OCR 路线必须把它作为实现基线。其校准不能恢复已被平均掉的像素证据。

关联：[[LLM-Wiki/research/visual-token-pruning/landscape.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。
