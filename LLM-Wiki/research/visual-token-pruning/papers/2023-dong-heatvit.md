---
id: paper-note-dong-2023-heatvit
type: paper-note
title: "HeatViT: Hardware-Efficient Adaptive Token Pruning for Vision Transformers"
authors: ["Peiyan Dong", "Mengshu Sun", "Alec Lu", "Yanyue Xie", "Kenneth Liu", "Zhenglun Kong", "Xin Meng", "Zhengang Li", "Xue Lin", "Zhenman Fang", "Yanzhi Wang"]
year: 2023
venue: "HPCA 2023"
source_id: paper-dong-2023-heatvit
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, hardware-aware-optimization, dynamic-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# HeatViT: Hardware-Efficient Adaptive Token Pruning for Vision Transformers

## 收录与问题

系统顶会核心证据。研究目标是在嵌入式 FPGA 上把图像自适应 token 剪枝转化为真实 ViT 推理加速，同时控制 ImageNet 分类精度损失。

## 核心方法

- 用可学习的多头评价选择器逐阶段识别 token，并把非信息 token 的表示聚合到保留 token。
- 选择器复用主干 GEMM 数据通路，减少动态控制开销。
- 在目标 ZCU102 上测量 keep ratio—block latency 表，以 latency-sparsity loss 学习选择器位置和平均保留率；再配合 8-bit 定点量化。

## 实验与直接证据

- ImageNet-1K；DeiT-T/S/B 与 LV-ViT-S/M。
- 相近精度下计算下降 28.4%–65.3%；部分设置在不降精度时可剪 16.1%–23.1%。
- FPGA 上仅 token pruning 把 FPS 提升 1.82×–2.58×；叠加 8-bit 量化后总加速 3.46×–4.89×。两种贡献不能混写。
- 选择器资源额外开销为 8%–11% DSP 与 5%–8% LUT。

## 证据定位

摘要与 §I；Table IV（block latency LUT）；§VI（latency-aware training）；Table V/Fig. 2（精度—计算）；§VII-B、Table VII（硬件 FPS、功耗与分项加速）。

## 局限与启发

硬件结果依赖专用 FPGA 设计，不能外推到通用 GPU/NPU；多阶段训练成本约为从头训练主干的 90%。最重要启发是直接优化目标硬件时延并拆分选择器、剪枝和量化贡献。
