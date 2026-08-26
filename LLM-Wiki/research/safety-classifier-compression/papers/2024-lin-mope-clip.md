---
id: paper-note-lin-2024-mope-clip
type: paper-note
title: "MoPE-CLIP: Structured Pruning for Efficient Vision-Language Models with Module-wise Pruning Error Metric"
authors: ["Haokun Lin", "Haoli Bai", "Zhili Liu", "Lu Hou", "Muyi Sun", "Linqi Song", "Ying Wei", "Zhenan Sun"]
year: 2024
venue: "CVPR 2024"
source_id: paper-lin-2024-mope-clip
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, structured-pruning, vision-language-model, model-compression]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# MoPE-CLIP

## 核心方法

用剪掉某模块造成的跨模态任务性能下降定义 MoPE，评估 head、FFN neuron 和 Transformer layer；预训练阶段联合宽/深剪枝，任务阶段先宽后深，并蒸馏跨模态与单模态特征。

## 主要结论与局限

作者报告在零样本与下游任务压缩上优于单模态指标和昂贵 mask search。importance 需要校准任务，且没有直接多模态安全数据；其价值是证明跨模态敏感度应进入剪枝信号。
