---
id: paper-note-chen-2023-diffrate
type: paper-note
title: "DiffRate: Differentiable Compression Rate for Efficient Vision Transformers"
authors: ["Mengzhao Chen", "Wenqi Shao", "Peng Xu", "Mingbao Lin", "Kaipeng Zhang", "Fei Chao", "Rongrong Ji", "Yu Qiao", "Ping Luo"]
year: 2023
venue: "ICCV 2023"
source_id: paper-chen-2023-diffrate
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, token-merging, budget-optimization]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# DiffRate: Differentiable Compression Rate for Efficient Vision Transformers

## 收录与问题

手工为每层选择剪枝/合并率既耗时又可能次优；论文将离散 compression rate 变成可微优化变量。

## 核心方法

为每层候选保留率建立概率分布，以连续代理和 straight-through 方式传播梯度；同一框架联合 token pruning 与 token merging，并以目标 FLOPs 正则学习层级配置。

## 实验与直接证据

在 ImageNet 上覆盖 DeiT、MAE ViT 等现有模型。代表结果：MAE ViT-H 在无需全量微调的设置中，FLOPs 下降 40%、throughput 提升 1.5×、Top-1 仅下降 0.16 个百分点。论文还显示同一预算下联合剪枝/合并优于单一操作。

## 证据定位

摘要与 Fig. 1；§3（differentiable rate 与联合压缩）；ImageNet 主表及 layer-wise rate 消融。

## 局限与启发

优化的是计算预算而不是特定设备的真实 latency，搜索出的层配置可能受 kernel、动态 shape 和内存访问反转。适合作为“精度优先预算搜索”基线，再加硬件成本模型。
