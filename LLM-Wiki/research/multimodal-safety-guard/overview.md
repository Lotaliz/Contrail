---
id: multimodal-safety-guard-two-track-plan
type: research-overview
title: "多模态安全 Guard 双路线研究计划"
aliases: [图文联合风险与政策条件视觉剪枝]
tags: [research, multimodal-safety, safety-guardrail, safety-evaluation, visual-token-pruning, efficient-inference]
status: active
related: [multimodal-compositional-safety, visual-token-pruning, safety-classifier-compression]
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-singguard-team-2026-singguard, paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, webpage-usenix-security-2027-cfp-ml, webpage-ieee-sp-2027-cfp-compositional-safety, webpage-acm-ccs-2026-cfp-ml, webpage-ndss-2027-cfp-ml, webpage-cvpr-2027-cfp]
created: 2026-09-21
updated: 2026-09-24
---

# 多模态安全 Guard 双路线研究计划

## 总体决策

研究计划收束为两篇边界清楚、可以独立成立的论文：

1. **路线一：图文联合风险的攻击、测量与防御。** 以 strict `S-S-U` 数据构造为手段，测量专业多模态 Guard 的组合式漏检，提出不损害既有判别能力的增量防御；主投安全顶会。
2. **路线二：短政策条件下的文本政策指导视觉 Token 剪枝。** 将模板派生的可读短政策作为输入条件，在同一 Guard 下比较政策条件视觉证据选择、判定质量和真实端到端时延；主投 CVPR。

两条路线共享政策体系、数据治理规范、Guard 评测工具和部分骨干，但不共享主贡献。路线一研究的是**安全属性是否被组合语义规避**；路线二研究的是**短政策条件下如何选择视觉证据并降低视觉计算**。路线一不把速度作为主要贡献，路线二不把 `S-S-U` 漏洞发现作为主要贡献。

## 可行性总评

| 维度 | 路线一：联合风险 | 路线二：政策条件视觉剪枝 |
|---|---|---|
| 问题必要性 | 高：SIUO、MSTS、VLSU 已从生成、回复审核和三标签分类重复观察失败 | 有条件：模板短政策的初步分类/召回接近长政策，但完整指标尚未归档；视觉路径占比须重新测量 |
| 创新空间 | 中高：空白不在“首次发现 S-S-U”，而在专业 Guard 的统一测量、可利用性和无回退防御 | 有条件：QuietPrune 与 Dyna-ViT 已覆盖文本引导和早剪先例；增量需来自可变政策下的证据保留、质量约束与真实加速 |
| 工程可行性 | 高：数据、开源 Guard 和评测协议可分阶段建立 | 中：先复测短政策完整视觉与现有剪枝基线，再决定是否训练政策条件 selector |
| 最大风险 | 数据同源、Guard 任务错位、只提高平均 F1、无法证明安全系统影响 | 短政策语义未覆盖复杂规则、局部危险证据被剪掉、selector 开销抵消视觉收益 |
| 顶会匹配 | 有条件适配安全四大：必须有威胁模型、系统流水线、攻击与防御闭环 | 有条件适配 CVPR：政策条件视觉选择、安全质量和端到端加速需同时成立 |
| 当前建议 | **主线优先级 A**；先验证漏洞普遍性，再扩数据和防御 | **先固定短政策 manifest 与 Guard，再运行同场景视觉剪枝基线** |

## 共享边界与避免重复投稿

- 路线一的数据是 `(image, user text, policy)` 的组合语义安全；路线二的数据是 `(image, policy)` 的政策条件图像审核。前者中的 user text 不能被悄悄重命名为 policy。
- 路线一的核心指标是 strict unsafe recall、端到端逃逸和既有能力非劣；路线二的核心指标是相同风险约束下的 encoder/端到端加速。
- 路线二可以把路线一 strict 数据作为压力测试，但不能再次把同一漏洞、同一数据集或同一防御结果列为主要贡献。
- 若共享模型或数据，论文须披露关系，并为每篇论文保留独立研究问题、独立主表和独立结论。

## 资源分配与阶段门

### Gate A：路线一是否存在可发表的系统漏洞

用小规模、高质量配对集先回答三个问题：最新专业 Guard 是否在 strict 子集显著漏检；错误是否在不同 Guard 家族间重复；漏检是否能穿过输入 Guard—任务模型—输出 Guard 的至少一个现实级联。若答案都是否，则不扩成大数据集。

### Gate B：短政策条件下视觉剪枝是否成立

先归档短政策模板、样本清单和 Guard checkpoint，测完整视觉下的分体系质量与分阶段时延；在同一场景比较随机/下采样、纯视觉早剪和可运行的文本条件基线。只有政策条件方法在固定安全质量下带来可重复的净时延收益，才进入复杂 selector 训练。

### 排期判断

CVPR 2027 的官方截稿为 2026-11-16 AoE。以 2026-09-21 为起点，路线二只有在数据管线、骨干和计时基线已可用时才适合冲本轮；否则应以完整证据为先，转下一投稿周期。USENIX Security 2027 Cycle 2 的论文截止为 2027-01-26 AoE，但路线一若要达到安全顶会标准，数据审计、自适应评测和 artifact 仍可能比方法实现更耗时。

## 路线入口

- [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|路线一：图文联合风险攻击、测量与防御研究计划]]
- [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|路线二：短政策条件视觉剪枝研究计划]]
- [[LLM-Wiki/research/multimodal-compositional-safety/overview.md|路线一已有调研与证据]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|路线二已有调研与证据]]
