---
id: paper-note-shi-2023-upop
type: paper-note
title: "UPop: Unified and Progressive Pruning for Compressing Vision-Language Transformers"
authors: ["Dachuan Shi", "Chaofan Tao", "Ying Jin", "Zhendong Yang", "Chun Yuan", "Jiaqi Wang"]
year: 2023
venue: "ICML 2023"
source_id: paper-shi-2023-upop
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, vision-language-model, structured-pruning, model-compression]
status: active
related: []
created: 2026-08-27
updated: 2026-08-27
---

# UPop

## 核心方法

在统一连续搜索空间内学习视觉与语言 Transformer 不同结构的 mask 和压缩率，再渐进式搜索、剪枝和恢复，避免手工给各模态分配相同比例。

## 对本课题的证据与边界

它说明多模态模型的剪枝预算应跨模态、跨结构联合分配，不能把文本 LLM 的统一阈值直接用于视觉编码器、连接器和语言主干。原任务是通用 VLP，不包含安全长尾、固定 FPR 或对抗切片。
