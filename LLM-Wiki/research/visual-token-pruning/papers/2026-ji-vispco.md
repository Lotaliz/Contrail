---
id: paper-note-ji-2026-vispco
type: paper-note
title: "VisPCO: Visual Token Pruning Configuration Optimization via Budget-Aware Pareto-Frontier Learning for Vision-Language Models"
authors: ["Huawei Ji", "Yuanhao Sun", "Yuan Jin", "Cheng Deng", "Jiaxin Ding", "Luoyi Fu", "Xinbing Wang"]
year: 2026
venue: "ACL 2026"
source_id: paper-ji-2026-vispco
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-24
---

# VisPCO: Visual Token Pruning Configuration Optimization

## 研究问题与方法

VisPCO 不重新发明 importance score，而把“在哪些层、保留多少 token”建模为给定计算预算下的 Pareto configuration optimization。它以原模型/剪枝模型 logits 的 KL divergence 表示性能损失，用连续松弛、straight-through estimator 与 augmented Lagrangian 搜索 layer-wise retention ratios（§3）。

## 证据

- 八个视觉语言 benchmark，跨 FastV、SparseVLM、FitPrune 等 pruning rules 与 LLaVA、Gemma3、Qwen2.5VL。
- 论文报告中等 50% budget 下不同启发式配置可相差最多 19 个百分点，而极高/极低预算时配置选择影响较小（§4.2）。
- Qwen2.5VL-3B、50% budget：FastV 平均性能 63.1，加入 VisPCO 为 71.5；TTFT 74ms vs 76ms、throughput 均约 20 tokens/s，说明配置优化可在近似硬件成本下恢复质量（Table 4）。
- 低于 50% budget 时 multi-step progressive pattern 优于单层或简单线性/指数/sigmoid schedule（Table 5）。

## 局限

论文主要是单图任务；作者明确把 multi-image/video 与 input-adaptive non-parametric patterns 列为未来工作。优化目标仍以 FLOPs budget 为主，真实 TTFT/throughput 只作后验验证；不同输出长度、KV cache 与尾延迟没有进入搜索目标。

## 项目意义

该工作表明研究热点已经从“提出一个 selector”推进到“预算、层位置与方法组合的配置优化”，但尚未完成向生成时延、多轮和跨硬件 cost model 的统一。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
