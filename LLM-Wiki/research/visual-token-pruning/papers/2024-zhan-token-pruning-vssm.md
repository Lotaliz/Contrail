---
id: paper-note-zhan-2024-token-pruning-vssm
type: paper-note
title: "Exploring Token Pruning in Vision State Space Models"
authors: ["Zheng Zhan", "Zhenglun Kong", "Yifan Gong", "Yushu Wu", "Zichong Meng", "Hangyu Zheng", "Xuan Shen", "Stratis Ioannidis", "Wei Niu", "Pu Zhao", "Yanzhi Wang"]
year: 2024
venue: "NeurIPS 2024"
source_id: paper-zhan-2024-token-pruning-vssm
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, dynamic-inference, efficient-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Exploring Token Pruning in Vision State Space Models

## 收录与问题

检验 ViT token pruning 能否直接迁移到视觉状态空间模型，并解释其失败机制。

## 核心方法

从 SSM 输出聚合 token importance；pruning-aware hidden-state alignment 保留被删 token 所造成的位置间隔，使剩余 token 的扫描邻接关系不被重新编号破坏。

## 实验与直接证据

- ImageNet-1K 分类，COCO 检测/实例分割及 ADE20K；ViM 与 PlainMamba。
- 直接把 EViT 用于 ViM-S 时，zero-shot 精度下降超过 68 个百分点；微调后仍比原模型低 5.7 点，证明跨架构照搬会永久破坏扫描。
- 所提方法在 PlainMamba-L3 上取得 81.7% Top-1、FLOPs 下降约 41.6%；未剪枝基线为 82.3%。

## 证据定位

Fig. 1–2 与 §3.2（传统剪枝失败和邻接破坏）；Eq. 5–6 与 §4.1（hidden-state alignment）；Table 1（ImageNet）；后续 COCO/ADE20K 表。

## 局限与启发

论文强调实际加速但核心主表仍以 GFLOPs 为主，缺少跨设备端到端 latency。关键反例是：token 的“位置”属于算子语义，不能只保留内容重要性。
