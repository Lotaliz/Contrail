---
id: visual-token-pruning
type: research-overview
title: 视觉模型 Token 剪枝：精度保持与推理时延优化
aliases: [视觉 Token 剪枝, 视觉 Token 压缩]
tags: [research, method]
status: active
related: [multimodal-token-pruning]
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding]
created: 2026-08-24
updated: 2026-08-26
---

# 视觉模型 Token 剪枝：精度保持与推理时延优化

## 一句话概述

视觉 Token 剪枝已从纯 ViT 的固定比例删除，扩展到视觉 SSM 与图文多模态模型中的查询条件化选择、剪枝—合并协同、生成时 KV/cache 优化和层级预算搜索；但空间覆盖、multi-turn 复用与跨硬件端到端时延证据仍不足。

## 研究问题

在纯视觉分类/密集预测以及图文分类、检索和自回归生成任务中，如何在保留任务证据的同时减少 token，并获得可复现的端到端时延、KV cache 与显存收益，而非仅降低理论 FLOPs？

## 范围与时间截点

- 时间窗：主体为 2023-01-01 至 2026-08-24 已正式发表论文；多模态路线追溯一篇 EMNLP 2022 早期代表。
- 会议白名单：AI/CV/NLP 顶会 ICLR、NeurIPS、ICML、CVPR、ICCV、ECCV、AAAI、IJCAI、ACL；系统/体系结构顶会 HPCA、ISCA、MICRO、ASPLOS、MLSys、OSDI、SOSP、USENIX ATC。
- 包含：视觉编码器、视觉序列模型、跨模态 encoder 或 decoder-only VLM 内部减少、跳过、合并或压缩视觉/文本 token，并报告分类、检索、VQA、captioning 或开放式生成质量；核心结论优先要求真实时延/吞吐/TTFT/KV 证据。
- 不包含：仅权重/通道/注意力头剪枝；只做图像生成的 DiT/VAR；纯文本 KV pruning；期刊、workshop、未录用或仅 arXiv 论文。
- 邻接方法：ToMe、STViT、TCA 属于 token 合并/凝聚而非严格“丢弃”，只用于说明信息保真和可部署边界。

## 核心结论

1. 对纯 ViT 分类，轻量重要性信号和层/样本自适应预算已能将 ImageNet Top-1 损失控制在约 0.1–0.4 个百分点，同时获得约 45%–50% 吞吐提升；代表为 AS-ViT 与 Zero-TPrune。
2. 信息完全丢弃并非总是最佳。DiffRate 联合剪枝与合并，STViT 用语义 token 聚合，ToMe 直接合并相似 token；它们在高压缩率下通常比纯剪枝更稳，但合并算子的真实开销必须计入。
3. 剪枝规则不可无条件跨架构迁移。ViT 的注意力分数直接迁移到视觉 SSM 会破坏扫描邻接，NeurIPS 2024 的结果显示即使充分微调仍可能有显著精度缺口。
4. FLOPs 只是筛选指标。HeatViT 将目标硬件的 latency-sparsity 表直接纳入训练，证明软硬协同可把 token 稀疏转成实际加速；多数 AI 论文仍以 GPU 吞吐为主，batch=1、预处理、选择器与数据搬运的端到端时延报告不足。
5. 2025–2026 的趋势是从局部贪心走向全局效应和分布鲁棒性：TCA 在分布偏移下把凝聚用于测试时适应，V-Pruner 把逐层剪枝建模为全局序列决策。
6. 多模态选择具有 query dependence：TRIPS、PuMer、SparseVLM 证明文本可指导视觉选择；但 Wen et al. 的统一复核显示普通 benchmark 上 random/pooling 可胜部分 attention selector，语言信号与 attention 分数都不是普适真值。
7. 生成任务新增 prefill、decode 与 KV cache 三阶段。VisionZip 的 prefill 约 7.8× 改善只对应约 3× 总时间，DivPrune 的 prefill 约快 55%只对应 E2E 约快 22%，必须分项测量。
8. 该方向属于 2024–2026 的明显热点，但尚未成熟：研究已扩展到 multi-turn、视频、多样性与 Pareto 配置；联合图文 token 剪枝、未来生成相关性和跨硬件 P95 仍是空白。
9. 面向 OSDI 的“双自适应 Guard serving”方向合适，但视觉/文本 Token 剪枝、任务相关主干剪枝与动态 serving 均已有直接先例。可成立的系统问题不是三个模块相加，而是：请求级二维动态执行导致批次碎片化，如何在安全质量约束与时延 SLO 下联合选择、组批、执行和回退。
10. Brainstorm、Apparate 与 SuperServe 已分别覆盖动态网络运行时、在线 early-exit serving 和权重共享子网调度。当前课题必须利用 Guard 特有的漏报不对称、证据完整性和风险回退形成新的系统抽象；仅做置信度路由或若干固定剪枝 profile 不足以支持 OSDI 新颖性。

## 面向判别任务的建议路线

优先复现 `Zero-TPrune / AS-ViT → DiffRate/ToMe 信息保真 → 硬件感知预算搜索` 三段式基线。统一在同一模型、输入分辨率、batch=1 与目标设备上报告 Top-1/mAP、P50/P95 端到端时延、吞吐、峰值显存、选择器开销与能耗。若主干是视觉 SSM，必须使用保持扫描位置的架构专用机制。

## 面向图文多模态的建议路线

以 `Random/Pooling → FastV → VisionZip/DivPrune → SparseVLM → layer-budget search` 建立基线，任务至少覆盖普通 VQA、TextVQA/OCR、RefCOCO、POPE、multi-turn 与视频；分开报告 vision encode、TTFT/prefill、decode tokens/s、KV memory 和 E2E P50/P95。

## 面向 OSDI 的双自适应 Guard Serving 判断

建议把系统抽象为一个 **risk- and SLO-aware elastic Guard runtime**。每个请求不独立选择两个连续剪枝率，而是从少量可高效执行的二维 profile 中选择：`(视觉/文本 token budget, 主干执行路径)`。调度器将风险下限、deadline slack、队列状态和 GPU profile 共同纳入决策，并按 execution signature 组批；当证据覆盖、校准置信度或运行时漂移不满足安全约束时，恢复 token、升级主干或回退完整 Guard。

OSDI 贡献应至少包含：二维弹性 Guard 的执行抽象；避免动态 shape/path 破坏 GPU batch 的机制；安全约束下的在线策略；真实到达 trace、突发负载和分布漂移上的 goodput/P99 评估。模型剪枝算法本身可采用或扩展现有方法，不宜同时声称三个彼此松散的算法贡献。

## 项目文档

- [[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|基础入门：ViT、patch token 与 Token 剪枝]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|概念：多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|专题调研：图文分类与生成中的 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/visual-token-pruning/landscape.md|技术路线图]]
- [[LLM-Wiki/research/visual-token-pruning/comparison.md|统一维度比较]]
- [[LLM-Wiki/research/visual-token-pruning/gaps.md|证据缺口]]
- [[LLM-Wiki/research/visual-token-pruning/motivation.md|研究动机]]
- [[LLM-Wiki/research/visual-token-pruning/hypotheses.md|待验证假设]]
- [[LLM-Wiki/experiments/20260825-vispco-qwen25vl-small/README.md|计划实验：Qwen2.5-VL-3B 上的 VisPCO 小规模测试]]
