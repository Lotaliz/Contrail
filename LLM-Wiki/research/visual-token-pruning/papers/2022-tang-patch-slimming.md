---
id: note-2022-tang-patch-slimming
type: paper-note
title: "Patch Slimming for Efficient Vision Transformers"
tags: [paper-note, research, visual-token-pruning, efficient-inference]
source_id: paper-tang-2022-patch-slimming
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Patch Slimming for Efficient Vision Transformers

来源：[arXiv 原文](https://arxiv.org/abs/2106.02852)；阅读摘要与方法概述，未运行代码。

## 方法与直接证据

论文采用自顶向下的 patch slimming：先识别最后层对输出有效的 patch，再用其指导前层选择，并近似每个 patch 对最终输出特征的影响。作者在 ImageNet 上报告 ViT-Ti 约 45% FLOPs 降低、top-1 下降 0.2 个百分点。

## 与本课题的边界

“用深层结果监督更早 patch 选择”已有直接先例，不能作为安全视觉前缀的新颖性。它研究纯视觉分类，不含文本/政策条件、Guard 误报率、压缩状态攻击或学生可观察性；作者 FLOPs 结果不能代替端到端判定时延。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。
