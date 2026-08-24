---
id: visual-token-pruning-motivation
type: synthesis
title: 面向精度保持与低时延的研究动机
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-zhan-2024-token-pruning-vssm]
status: active
created: 2026-08-24
updated: 2026-08-24
---

# 研究动机

现有方法已经证明视觉 token 可大幅压缩，但“精度—FLOPs 最优”不能保证“精度—端到端时延最优”。至少两组独立证据支持这一动机：AS-ViT 显式比较吞吐与单图 latency，HeatViT 用实测 latency 表驱动训练；另一方面，STViT 和视觉 SSM 工作共同表明，简单删除会损失空间或序列结构信息，且这种损失在非标准主干或密集任务上更严重。

因此，一个有证据支持的研究方向是：在固定判别质量约束下，联合优化信息保真的 token 压缩策略与目标硬件的真实执行成本。目标函数应直接包含端到端 latency（最好含 P95）、选择器开销与能耗，并以精度下降上限而非单一 FLOPs budget 作为约束。

## 建议研究问题

能否用“轻量重要性 + 多样性聚合 + 架构位置约束”的统一选择器，在不同 ViT/视觉 SSM 主干上保持判别精度，并借助少量硬件 profiling 自动选择层位置和 token budget，使 batch=1 的 P95 推理时延稳定下降？

## 最小验证闭环

1. 主干：DeiT-S、一个较大 ViT/CLIP、一个视觉 SSM。
2. 基线：无压缩、ToMe、Zero-TPrune、AS-ViT/DiffRate；SSM 加 ToP-ViM。
3. 任务：ImageNet-1K + ImageNet-C/A（分类），可选 COCO 小目标子集。
4. 指标：Top-1/mAP、ECE、P50/P95 latency、throughput、peak memory、energy/image；分别报告 selector 与 backbone 时间。
5. 设备：至少一张服务器 GPU 与一类边缘 GPU/NPU；batch=1 为主，batch=8 作为吞吐对照。
