---
id: note-2026-gao-quietprune
type: paper-note
title: "QuietPrune: Query-Guided Early Token Pruning for Vision-Language Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-gao-2026-quietprune
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# QuietPrune

来源：[CVPR 2026 官方页](https://openaccess.thecvf.com/content/CVPR2026/html/Gao_QuietPrune_Query-Guided_Early_Token_Pruning_for_Vision-Language_Models_CVPR_2026_paper.html)；阅读摘要、官方题录及方法概览，未运行代码。

## 方法与直接证据

QuietPrune 用轻量 adapter 将上下文 query 变换到视觉域，形成 `[Q-CLS]`，在 ViT 内早期执行查询引导的视觉 token 剪枝。方法还使用半结构分组和冗余 token 聚合；训练 adapter，不是完全 training-free。官方摘要明确把同时降低 ViT 与后续 LLM 开销作为目标。

## 与本课题的边界

“文本/任务引导的视觉塔早剪”已有高度重合工作。新的方法不能只把 query 换成安全 policy，也不能把 adapter 小称作不改结构。可保留的差异是：训练一个可真正截断的安全视觉前缀，并对图文—政策反事实效应、学生可观察性和压缩诱发 harmful flip 做联合约束；QuietPrune 是输入/早剪强基线。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。

