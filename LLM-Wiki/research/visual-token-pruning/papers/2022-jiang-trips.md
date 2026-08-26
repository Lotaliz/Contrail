---
id: paper-note-jiang-2022-trips
type: paper-note
title: "TRIPS: Efficient Vision-and-Language Pre-training with Text-Relevant Image Patch Selection"
authors: ["Chaoya Jiang", "Haiyang Xu", "Chenliang Li", "Ming Yan", "Wei Ye", "Shikun Zhang", "Bin Bi", "Songfang Huang"]
year: 2022
venue: "EMNLP 2022"
source_id: paper-jiang-2022-trips
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, multimodal-pretraining]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-26
---

# TRIPS: Efficient Vision-and-Language Pre-training with Text-Relevant Image Patch Selection

## 收录与问题

早期“文本条件化视觉剪枝”代表：同一图像面对不同问题时，重要 patch 不同，纯视觉重要性不足以决定视觉语言任务的保留集合（§1，pp. 4084–4085）。

## 核心方法与训练流程

在视觉编码器内部插入 text-guided patch-selection layers，以文本上下文计算 patch 相关性；保留高相关 token，并把低相关 token 融合成一个 token，而非全部硬删除。默认在 ViT 的第 5、10 层选择，每次 keep rate 70%。模型以 CLIP ViT-B/16 初始化，在 4M image-text pairs 上预训练 30 epochs，再按下游任务微调（§3–§4）。

## 任务、指标与结果

- VQA 被建模为答案生成；NLVR2 是二分类；另含 Flickr30K/MSCOCO 图文检索。
- Table 3 报告 TRIPS 为 20.89G FLOPs、343.05 image-text pairs/s、11ms；表内 ALBEF-C 为 36.63G、197.52/s、21ms。输入长度统一为 197 image patches + 40 text tokens。
- Table 4 显示剪枝越早/越强，吞吐越高但 VQA/NLVR2 下降；[5,10] 两层各保留 70% 是论文选择的折中。

## 局限与项目意义

作者明确指出仅用 4M 对预训练数据，扩展到更大数据规模的行为未知（§7）。TRIPS 说明多模态剪枝的选择信号应由文本条件化，但它需要在视觉骨干中提前获得文本指导，架构耦合度高，且不覆盖 decoder-only MLLM 的 KV cache 与多轮生成问题。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
