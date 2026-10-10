---
id: note-2026-ramachandram-pf-cbm
type: paper-note
title: "Spatially Grounded Concept Bottleneck Models via Part-Factorized Attention"
authors: [Dhanesh Ramachandram]
year: 2026
venue: arXiv
source_id: paper-ramachandram-2026-pf-cbm
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, visual-evidence, representation-probing]
status: active
created: 2026-10-08
updated: 2026-10-08
---

# PF-CBM

来源：[arXiv 2606.04364v1](https://arxiv.org/html/2606.04364v1)。快读摘要、引言、方法、图注、主表与限制；未复现，未保存 PDF。

**作者方法：** 在冻结 DINOv3 上用命名部位 query、前景门与空间先验形成 part tokens，把 CUB 属性硬路由到对应部位；分类器读取概念概率。Table 2 中空间先验条件 top-1 为 88.85%、pointing 为 52.57%。Table 3 顺序训练改善概念校准但降低分类精度，揭示软概念值携带额外类别信息的风险。

**边界与项目判断：** 单对象/规范姿态假设限制了向任意安全场景迁移。借鉴命名中间量实际进入决策图、分别检查语义和干预效果；不能直接套用鸟类空间先验、压制背景或把条款 attention 当忠实解释。仅监督最终 verdict 不能保证“暴力”等命名头学到对应视觉事实。该建议见 [[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md]]。
