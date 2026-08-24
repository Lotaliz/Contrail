---
id: paper-note-wang-2025-tca
type: paper-note
title: "Is Less More? Exploring Token Condensation as Training-free Test-time Adaptation"
authors: ["Zixin Wang", "Dong Gong", "Sen Wang", "Zi Huang", "Yadan Luo"]
year: 2025
venue: "ICCV 2025"
source_id: paper-wang-2025-tca
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# Is Less More? Exploring Token Condensation as Training-free Test-time Adaptation

## 收录与问题

在 CLIP/SigLIP 的跨数据集与腐化分类中，能否让 token condensation 同时降低计算并提升测试时适应效果？

## 核心方法

选择代表 token 并合并其邻域，引入 reservoir-based domain anchor tokens 保存域信息，再用 logit correction 改善视觉—文本对齐；全流程无需训练。

## 主要结论

作者报告在跨数据集和 CIFAR-100-C 上，相对最强基线最高提升 21.4%，同时 GFLOPs 降低 12.2%–48.9%。这说明分布偏移下 token reduction 可能改变有效特征选择，而不仅是压缩。

## 证据定位

摘要；方法中的 token condensation、domain anchors 与 logit correction；跨数据集/CIFAR-100-C 主表；补充材料的 condensation algorithm。

## 局限

性能提升含测试时适应贡献，不能与 IID ImageNet 剪枝数字直接比较；主要效率证据是 GFLOPs，真实 latency 仍需复核。

