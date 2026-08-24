---
id: visual-token-pruning-hypotheses
type: synthesis
title: 视觉 Token 剪枝待验证假设
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-zhan-2024-token-pruning-vssm]
status: draft
created: 2026-08-24
updated: 2026-08-24
---

# 待验证假设

- H1（hypothesis）：在相同平均保留率下，“重要性 Top-K + 被删 token 向最近代表 token 聚合”会比纯删除更好地保持 ImageNet-A/C 与小目标性能。
- H2（hypothesis）：把 selector latency 和动态 shape/kernel 切换成本纳入 budget search 后，得到的层级保留率会显著不同于 FLOPs 约束下的 DiffRate 配置。
- H3（hypothesis）：batch=1 边缘推理中，动态样本级 token 数的方差会增加 P95 latency；分桶或量化到少量固定 budget 可在极小精度代价下降低尾延迟。
- H4（hypothesis）：位置保持是跨 ViT、视觉 SSM 通用化的必要条件，但不是充分条件；还需要匹配各主干的信息传播算子。

这些假设尚无本地实验支持，不进入来源陈述。
