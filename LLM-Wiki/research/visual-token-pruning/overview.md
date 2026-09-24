---
id: visual-token-pruning-overview
type: research-overview
title: "短政策条件下的文本政策指导视觉 Token 剪枝"
tags: [research, visual-token-pruning, multimodal-safety, efficient-inference, vision-language-model]
status: active
related: [multimodal-compositional-safety, safety-classifier-compression]
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, webpage-cvpr-2027-cfp]
created: 2026-09-08
updated: 2026-09-23
---

# 短政策条件下的文本政策指导视觉 Token 剪枝

## 当前主线

2026-09-23 起，主线改为**文本政策指导的视觉 Token 剪枝**：从已有长政策按模板派生可读短政策，使其成为目标工作负载的输入条件，再研究政策如何影响视觉证据选择与实际推理成本。短政策改写不作为论文贡献；仍需验证其同图政策翻转、FPR、未见政策和各体系覆盖情况。

此前用户报告：约 882-token 长政策主导输入时，90% pre-ViT 视觉剪枝仅约 1.14× 端到端加速且精度明显下降；该数字仍缺可复核原始 profiler。用户现报告约 32-token 模板短政策可经训练取得接近长政策的初步分类/召回，但完整结果尚未归档。缩短政策后视觉路径占比和可得加速须重新测量，不能沿用旧上限。

完整场景数据构造、首轮 baseline 协议、方法假设和 CVPR 边界见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|新版课题方案]]。原 [[LLM-Wiki/research/visual-token-pruning/research-plan.md|视觉—政策联合压缩方案]]与[[LLM-Wiki/research/visual-token-pruning/long-policy-bottleneck-pivot-assessment.md|转向评估]]保留为历史方案和背景依据。

## 与另一条路线的边界

本路线中的文本是运行时**政策**，不是与图片共同构成风险的用户请求。[[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|图文联合风险路线]]负责 strict `S-S-U` 数据、专业 Guard 漏洞和防御；本路线负责政策自适应图像 Guard 的视觉计算和执行成本。strict 数据可以作为压力测试，但不能成为本论文重复的主贡献。

## 最近邻结论

- [[LLM-Wiki/research/visual-token-pruning/papers/2026-rubab-dyna-vit.md|Dyna-ViT]] 已证明 encoder 前视觉显著性剪枝存在正式先例，所以“ViT 前”本身不新。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]] 已把 query 送入视觉塔并做 early pruning，所以“文本指导视觉剪枝”本身不新。
- [[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md|SafeWatch]] 已做 policy-aware video token pruning，所以“政策感知安全剪枝”本身不新。
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-cao-madtp.md|MADTP]] 已在 CVPR 同时压视觉与语言 token，所以“联合图文 token 剪枝”本身也不新。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-piao-safeguard-vl.md|SafeEditBench]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-song-policyshiftguard.md|PolicyShiftBench]] 提供政策自适应图像 Guard 评测基础，但长政策压缩和安全非劣仍未解决。
- 当前候选贡献来自交叉处：**可变政策下的视觉证据选择、安全质量保持和真实端到端加速**；短政策改写仅为场景构造。

## 研究入口

- [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划：短政策条件下的文本政策指导视觉剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/research-plan.md|历史方案：长政策下的视觉—政策协同压缩]]
- [[LLM-Wiki/research/visual-token-pruning/long-policy-bottleneck-pivot-assessment.md|长政策瓶颈下的转向评估]]
- [[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|SafeGuard-VL 与 PolicyShiftGuard 定义、方法和边界比较]]
- [[LLM-Wiki/research/visual-token-pruning/motivation.md|历史联合压缩动机与论点—证据边界]]
- [[LLM-Wiki/research/visual-token-pruning/gaps.md|历史联合压缩缺口与可证伪问题]]
- [[LLM-Wiki/research/visual-token-pruning/landscape.md|视觉 Token 剪枝与安全训练版图]]
- [[LLM-Wiki/research/visual-token-pruning/comparison.md|方法比较]]
- [[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md|早期视觉编码器剪枝与解释性综述]]
- [[LLM-Wiki/research/visual-token-pruning/pumer-cdpruner-text-conditioning-cost.md|PuMer/CDPruner 文本条件开销比较]]
- [[LLM-Wiki/research/visual-token-pruning/token-merging-landscape.md|Token 合并综述]]
- [[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|自回归 VLM 剪枝与时延基线]]
- [[LLM-Wiki/research/visual-token-pruning/region-rationale-guided-safety-token-pruning.md|区域/理由监督综述]]
- [[LLM-Wiki/research/visual-token-pruning/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/visual-token-pruning/watch/overview.md|近期论文追踪]]
- [[LLM-Wiki/research/multimodal-safety-guard/overview.md|双路线总计划]]

## 保留的实验与证据边界

既有 XGuard、双向 Token 干预、双证据压缩和其他实验记录继续保留，因为它们包含基线、失败和可复用诊断；它们不是当前路线的实验结果。旧长政策下的 1.14× 与 token 比例是用户报告的场景约束，尚未链接原始 profiler；新短政策视觉 baseline 尚未运行。
