---
id: paper-note-liu-2023-adaptive-sparse-vit
type: paper-note
title: "Adaptive Sparse ViT: Towards Learnable Adaptive Token Pruning by Fully Exploiting Self-Attention"
authors: ["Xiangcheng Liu", "Tianyi Wu", "Guodong Guo"]
year: 2023
venue: "IJCAI 2023"
source_id: paper-liu-2023-adaptive-sparse-vit
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# Adaptive Sparse ViT: Towards Learnable Adaptive Token Pruning by Fully Exploiting Self-Attention

## 收录与问题

在不增加重型预测器和 Top-K 排序开销的前提下，为每个样本学习 token 保留量。

## 核心方法

以 attention-head importance 加权 class attention 作为 token 分数，用可学习阈值比较代替排序，并通过 budget-aware loss 与蒸馏在 30 epoch 微调中控制平均计算。

## 实验与直接证据

ImageNet-1K 上评测 DeiT-S、LV-ViT-S/M。作者报告 DeiT-S throughput 提升 50%、Top-1 仅下降 0.2；当计算下降 30%–35% 时多模型精度损失不超过 0.2。Table 1 的吞吐在单张 RTX 2080 Ti、batch=64 测量；hardware latency 为同卡 batch=1、100 次推理平均。

## 证据定位

§3（head scoring、adaptive sparsity module、budget loss）；Table 1 与 §4.2（Top-1、GFLOPs、throughput、latency）；Table 2–5（模块、mask、蒸馏、batch 消融）。

## 局限与启发

依赖 class token 与自注意力中间量，不直接适用于无 attention 的视觉 SSM；动态 token 数对 GPU kernel 和尾时延的影响未展开。它是少数同时明确吞吐与单图时延协议的论文。

