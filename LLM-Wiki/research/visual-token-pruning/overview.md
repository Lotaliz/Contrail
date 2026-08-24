---
id: visual-token-pruning
type: research-overview
title: 视觉模型 Token 剪枝：精度保持与推理时延优化
aliases: [视觉 Token 剪枝, 视觉 Token 压缩]
tags: [research, method]
status: active
related: []
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner]
created: 2026-08-24
updated: 2026-08-24
---

# 视觉模型 Token 剪枝：精度保持与推理时延优化

## 一句话概述

近三年顶会进展已从“按固定比例丢弃低分 patch”转向四类更可部署的设计：样本/层自适应预算、剪枝与合并协同、架构感知的信息保真，以及硬件时延驱动的选择策略；但跨硬件、batch=1 的端到端时延证据仍明显不足。

## 研究问题

在图像分类、检测、姿态估计及视觉语言判别任务中，如何在将精度下降约束在可接受范围内的同时，获得可复现的端到端推理时延下降，而非仅减少理论 FLOPs？

## 范围与时间截点

- 时间窗：按会议年份纳入 2023-01-01 至 2026-08-24 已正式发表论文。
- 会议白名单：AI/CV/NLP 顶会 ICLR、NeurIPS、ICML、CVPR、ICCV、ECCV、AAAI、IJCAI、ACL；系统/体系结构顶会 HPCA、ISCA、MICRO、ASPLOS、MLSys、OSDI、SOSP、USENIX ATC。
- 包含：在视觉编码器或视觉序列模型内部减少、跳过、合并或压缩 token，并报告判别任务质量；核心结论优先要求吞吐或真实时延。
- 不包含：仅权重/通道/注意力头剪枝；只做生成质量的 DiT/VAR；期刊、workshop、未录用或仅 arXiv 论文；没有判别任务结果的纯多模态生成加速。
- 邻接方法：ToMe、STViT、TCA 属于 token 合并/凝聚而非严格“丢弃”，只用于说明信息保真和可部署边界。

## 核心结论

1. 对纯 ViT 分类，轻量重要性信号和层/样本自适应预算已能将 ImageNet Top-1 损失控制在约 0.1–0.4 个百分点，同时获得约 45%–50% 吞吐提升；代表为 AS-ViT 与 Zero-TPrune。
2. 信息完全丢弃并非总是最佳。DiffRate 联合剪枝与合并，STViT 用语义 token 聚合，ToMe 直接合并相似 token；它们在高压缩率下通常比纯剪枝更稳，但合并算子的真实开销必须计入。
3. 剪枝规则不可无条件跨架构迁移。ViT 的注意力分数直接迁移到视觉 SSM 会破坏扫描邻接，NeurIPS 2024 的结果显示即使充分微调仍可能有显著精度缺口。
4. FLOPs 只是筛选指标。HeatViT 将目标硬件的 latency-sparsity 表直接纳入训练，证明软硬协同可把 token 稀疏转成实际加速；多数 AI 论文仍以 GPU 吞吐为主，batch=1、预处理、选择器与数据搬运的端到端时延报告不足。
5. 2025–2026 的趋势是从局部贪心走向全局效应和分布鲁棒性：TCA 在分布偏移下把凝聚用于测试时适应，V-Pruner 把逐层剪枝建模为全局序列决策。

## 面向判别任务的建议路线

优先复现 `Zero-TPrune / AS-ViT → DiffRate/ToMe 信息保真 → 硬件感知预算搜索` 三段式基线。统一在同一模型、输入分辨率、batch=1 与目标设备上报告 Top-1/mAP、P50/P95 端到端时延、吞吐、峰值显存、选择器开销与能耗。若主干是视觉 SSM，必须使用保持扫描位置的架构专用机制。

## 项目文档

- [[LLM-Wiki/research/visual-token-pruning/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/visual-token-pruning/landscape.md|技术路线图]]
- [[LLM-Wiki/research/visual-token-pruning/comparison.md|统一维度比较]]
- [[LLM-Wiki/research/visual-token-pruning/gaps.md|证据缺口]]
- [[LLM-Wiki/research/visual-token-pruning/motivation.md|研究动机]]
- [[LLM-Wiki/research/visual-token-pruning/hypotheses.md|待验证假设]]
