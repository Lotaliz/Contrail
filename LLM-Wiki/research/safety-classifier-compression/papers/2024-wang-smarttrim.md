---
id: paper-note-wang-2024-smarttrim
type: paper-note
title: "SmartTrim: Adaptive Tokens and Attention Pruning for Efficient Vision-Language Models"
authors: ["Zekun Wang", "Jingchang Chen", "Wangchunshu Zhou", "Haichao Zhu", "Jiafeng Liang", "Liping Shan", "Ming Liu", "Dongliang Xu", "Qing Yang", "Bing Qin"]
year: 2024
venue: "LREC-COLING 2024"
source_id: paper-wang-2024-smarttrim
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, visual-token-pruning, structured-pruning, vision-language-model, dynamic-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# SmartTrim

## 核心方法

在各层用轻量模块按输入动态剪除冗余 token 和 attention heads；以 full-capacity 路径对 pruned 路径做 self-distillation，减少动态剪枝的质量损失。

## 主要证据与局限

在多类 vision-language 任务上，作者报告 2–3× 加速且性能下降较小。动态 gate 与不规则张量的实际收益依运行时实现；论文不是安全审核评测，不能推断对稀有危险视觉线索的召回。
