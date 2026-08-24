---
id: paper-note-yao-2026-v-pruner
type: paper-note
title: "V-Pruner: A Fast and Globally-informed Token Pruning Framework for Vision Transformer"
authors: ["Guangzhen Yao", "Jiayun Zheng", "Zezhou Wang", "Wenxin Zhang", "Renda Han", "Chuangxin Zhao", "Zeyu Zhang", "Runhao Liu"]
year: 2026
venue: "AAAI 2026"
source_id: paper-yao-2026-v-pruner
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

# V-Pruner: A Fast and Globally-informed Token Pruning Framework for Vision Transformer

## 收录与问题

局部或静态 token importance 忽略跨层剪枝决策的长期相互作用；论文把全网剪枝变成序列决策。

## 核心方法

先以 Fisher information 得到 token 重要性先验，再由 PPO 策略在层间逐步调整剪枝配置；reward 同时包含模型性能和计算成本。

## 主要结论

作者在 ViT-L、DeiT-B/S/T 上同时比较准确率、GFLOPs、吞吐、单图 latency 和训练时间。代表性 15-GFLOPs DeiT-B 配置搜索约 1.3 小时；论文表中 DeiT-T/S 多组配置显示约 1.23–1.4× 级 latency speedup，同时优于局部打分方法的精度—效率权衡。

## 证据定位

摘要与 Fig. 1；Fisher 初始化和 PPO reward 方法节；ImageNet 主表、效率比较表与训练时间分析。

## 局限

RL 搜索依赖校准集、reward 标定和具体硬件；2026 结果尚无本地独立复现，不能仅据作者表格认定跨设备通用。

