---
id: paper-note-cui-2023-brainstorm
type: paper-note
title: "Optimizing Dynamic Neural Networks with Brainstorm"
authors: ["Weihao Cui", "Zhenhua Han", "Lingji Ouyang", "Yichuan Wang", "Ningxin Zheng", "Lingxiao Ma", "Yuqing Yang", "Fan Yang", "Jilong Xue", "Lili Qiu", "Lidong Zhou", "Quan Chen", "Haisheng Tan", "Minyi Guo"]
year: 2023
venue: "OSDI 2023"
source_id: paper-cui-2023-brainstorm
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, dynamic-inference, dynamic-sparsity, model-serving, hardware-aware-optimization, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# Brainstorm

## 与当前课题的关系

Brainstorm 直接处理输入依赖的动态子网执行，提出 Cell 表达发生动态性的细粒度数据单元、Router 表达分发，并根据运行时动态分布做专门化优化。视觉/文本 Token 剪枝与主干路径剪枝正好同时产生 sub-tensor dispatch 和 control-flow divergence，因此它是 OSDI 定位下必须超越的系统基线。

## 证据边界

作者在多类动态网络上报告最高 11.7×、平均 3.29× 加速或 42% 内存降低。论文不是多模态 Guard serving，也没有 Guard 的误报/漏报不对称约束、双维预算联动或安全 SLO；这些才可能构成当前课题的差异化。
