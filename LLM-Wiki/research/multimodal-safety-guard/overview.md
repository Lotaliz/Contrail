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
updated: 2026-10-20
---

# 多模态安全 Guard 双路线研究计划

## 总体决策

研究计划收束为两篇边界清楚、可以独立成立的论文：

1. **路线一：图文联合风险的攻击、测量与防御。** 以 strict `S-S-U` 数据构造为手段，测量专业多模态 Guard 的组合式漏检，提出不损害既有判别能力的增量防御；主投安全顶会。
2. **路线二：政策文本指导图像安全审核的视觉计算加速。** 当前研究整图输入分辨率，围绕信息读取、表征保留和决策作用提取可解释预算信号，再检验轻量选择器的安全质量与真实端到端收益。

两条路线共享政策体系、数据治理规范、Guard 评测工具和部分骨干，但不共享主贡献。路线一研究的是**安全属性是否被组合语义规避**；路线二研究的是**运行时政策条件下如何减少审核所需视觉计算**。路线一不把速度作为主要贡献，路线二不把 `S-S-U` 漏洞发现作为主要贡献。

## 可行性总评

| 维度 | 路线一：联合风险 | 路线二：政策条件视觉剪枝 |
|---|---|---|
| 问题必要性 | 高：SIUO、MSTS、VLSU 已从生成、回复审核和三标签分类重复观察失败 | 用户报告两套设置的低Token静态上限近乎无损；需核验逐样本输出与机制，不能据此证明自适应选择有效 |
| 创新空间 | 中高：空白不在“首次发现 S-S-U”，而在专业 Guard 的统一测量、可利用性和无回退防御 | 有条件：QuietPrune 与 Dyna-ViT 已覆盖文本引导和早剪先例；增量需来自可变政策下的证据保留、质量约束与真实加速 |
| 工程可行性 | 高：数据、开源 Guard 和评测协议可分阶段建立 | 先冻结已使用Guard和政策，对整图多预算作受控分析；机制信号可由便宜输入预测后再训练选择器 |
| 最大风险 | 数据同源、Guard 任务错位、只提高平均 F1、无法证明安全系统影响 | 机制归因不成立、低清预览无法预测升级收益、强静态上限已接近时延下限、selector开销抵消节省 |
| 顶会匹配 | 有条件适配安全四大：必须有威胁模型、系统流水线、攻击与防御闭环 | 有条件适配 CVPR：政策条件视觉选择、安全质量和端到端加速需同时成立 |
| 当前建议 | **主线优先级 A**；先验证漏洞普遍性，再扩数据和防御 | **从读取/保留/决策三个问题分析整图预算，再验证可解释选择器是否超过静态上限** |

## 共享边界与避免重复投稿

- 路线一的数据是 `(image, user text, policy)` 的组合语义安全；路线二的数据是 `(image, policy)` 的政策条件图像审核。前者中的 user text 不能被悄悄重命名为 policy。
- 路线一的核心指标是 strict unsafe recall、端到端逃逸和既有能力非劣；路线二的核心指标是相同风险约束下的 encoder/端到端加速。
- 路线二可以把路线一 strict 数据作为压力测试，但不能再次把同一漏洞、同一数据集或同一防御结果列为主要贡献。
- 若共享模型或数据，论文须披露关系，并为每篇论文保留独立研究问题、独立主表和独立结论。

## 资源分配与阶段门

### Gate A：路线一是否存在可发表的系统漏洞

用小规模、高质量配对集先回答三个问题：最新专业 Guard 是否在 strict 子集显著漏检；错误是否在不同 Guard 家族间重复；漏检是否能穿过输入 Guard—任务模型—输出 Guard 的至少一个现实级联。若答案都是否，则不扩成大数据集。

### Gate B：整图自适应预算是否有增量价值

先固定样本、政策和Guard，建立整图预算的输出曲线，分析注意力、隐藏状态与受控替换。保留完整错而低预算对的样本；机制信号须能预测预算收益并由便宜预览估计。训练后在同实际成本下对照强静态上限，同时检查同图政策对、漏检、误报和前端总开销。

### 历史排期判断（2026-09-21，非当前方案约束）

CVPR 2027 的官方截稿为 2026-11-16 AoE。以 2026-09-21 为起点，路线二只有在数据管线、骨干和计时基线已可用时才适合冲本轮；否则应以完整证据为先，转下一投稿周期。USENIX Security 2027 Cycle 2 的论文截止为 2027-01-26 AoE，但路线一若要达到安全顶会标准，数据审计、自适应评测和 artifact 仍可能比方法实现更耗时。

## 路线入口

- [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|路线一：图文联合风险攻击、测量与防御研究计划]]
- [[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|路线二：政策条件审核的整图分辨率研究计划]]
- [[LLM-Wiki/research/multimodal-compositional-safety/overview.md|路线一已有调研与证据]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|路线二已有调研与证据]]
