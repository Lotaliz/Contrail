---
id: multimodal-safety-guard-two-track-plan
type: research-overview
title: "多模态安全 Guard 双路线研究计划"
aliases: [图文联合风险与政策条件协同压缩]
tags: [research, multimodal-safety, safety-guardrail, safety-evaluation, visual-token-pruning, efficient-inference]
status: active
related: [multimodal-compositional-safety, visual-token-pruning, safety-classifier-compression]
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-singguard-team-2026-singguard, paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, webpage-usenix-security-2027-cfp-ml, webpage-ieee-sp-2027-cfp-compositional-safety, webpage-acm-ccs-2026-cfp-ml, webpage-ndss-2027-cfp-ml, webpage-cvpr-2027-cfp]
created: 2026-09-21
updated: 2026-09-22
---

# 多模态安全 Guard 双路线研究计划

## 总体决策

研究计划收束为两篇边界清楚、可以独立成立的论文：

1. **路线一：图文联合风险的攻击、测量与防御。** 以 strict `S-S-U` 数据构造为手段，测量专业多模态 Guard 的组合式漏检，提出不损害既有判别能力的增量防御；主投安全顶会。
2. **路线二：长政策条件下的视觉—政策协同压缩。** 先编译和检索政策条款，再让条款与 pre-ViT 视觉 patch 协同分配预算，在安全非劣下削减真实端到端成本；主投 CVPR。

两条路线共享政策体系、数据治理规范、Guard 评测工具和部分骨干，但不共享主贡献。路线一研究的是**安全属性是否被组合语义规避**；路线二研究的是**长政策主导时如何协同减少政策与视觉证据计算**。路线一不把速度作为主要贡献，路线二不把 `S-S-U` 漏洞发现作为主要贡献。

## 可行性总评

| 维度 | 路线一：联合风险 | 路线二：视觉—政策协同压缩 |
|---|---|---|
| 问题必要性 | 高：SIUO、MSTS、VLSU 已从生成、回复审核和三标签分类重复观察失败 | 高：当前 workload 的政策 token 超过视觉 token 四倍，pure-visual 90% 剪枝实测仅 1.14×，原成本假设已经失效 |
| 创新空间 | 中高：空白不在“首次发现 S-S-U”，而在专业 Guard 的统一测量、可利用性和无回退防御 | 中高：MADTP 已覆盖一般联合图文剪枝；增量需来自长政策编译、视觉—条款协同覆盖、政策翻转与安全非劣 |
| 工程可行性 | 高：数据、开源 Guard 和评测协议可分阶段建立 | 中：需政策解析/检索、pre-ViT 选择、缓存与回退共同闭环；模块更多但可分层实现 |
| 最大风险 | 数据同源、Guard 任务错位、只提高平均 F1、无法证明安全系统影响 | 条款遗漏导致漏报、简单摘要/cache 已足够、联合 selector 开销、视觉贡献被文本压缩掩盖 |
| 顶会匹配 | 有条件适配安全四大：必须有威胁模型、系统流水线、攻击与防御闭环 | 有条件适配 CVPR：视觉—政策协同机制和视觉证据分析必须居中；若主要是 prompt compression，应换综合/NLP venue |
| 当前建议 | **主线优先级 A**；先验证漏洞普遍性，再扩数据和防御 | **路线二内部优先：结构化联合压缩 > 精度副主张 > 短政策筛选** |

## 共享边界与避免重复投稿

- 路线一的数据是 `(image, user text, policy)` 的组合语义安全；路线二的数据是 `(image, policy)` 的政策条件图像审核。前者中的 user text 不能被悄悄重命名为 policy。
- 路线一的核心指标是 strict unsafe recall、端到端逃逸和既有能力非劣；路线二的核心指标是相同风险约束下的 encoder/端到端加速。
- 路线二可以把路线一 strict 数据作为压力测试，但不能再次把同一漏洞、同一数据集或同一防御结果列为主要贡献。
- 若共享模型或数据，论文须披露关系，并为每篇论文保留独立研究问题、独立主表和独立结论。

## 资源分配与阶段门

### Gate A：路线一是否存在可发表的系统漏洞

用小规模、高质量配对集先回答三个问题：最新专业 Guard 是否在 strict 子集显著漏检；错误是否在不同 Guard 家族间重复；漏检是否能穿过输入 Guard—任务模型—输出 Guard 的至少一个现实级联。若答案都是否，则不扩成大数据集。

### Gate B：路线二是否突破视觉侧硬上限

先完成 policy-length × image-resolution 成本剖析，并比较 full、pure-visual、policy cache、政策条款检索、两侧独立压缩与联合协同。只有在固定安全质量下明显超过 pure-visual 约 1.15× 的净收益上限，且联合方案优于简单 cache/摘要，才进入复杂训练。

### 排期判断

CVPR 2027 的官方截稿为 2026-11-16 AoE。以 2026-09-21 为起点，路线二只有在数据管线、骨干和计时基线已可用时才适合冲本轮；否则应以完整证据为先，转下一投稿周期。USENIX Security 2027 Cycle 2 的论文截止为 2027-01-26 AoE，但路线一若要达到安全顶会标准，数据审计、自适应评测和 artifact 仍可能比方法实现更耗时。

## 路线入口

- [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|路线一：图文联合风险攻击、测量与防御研究计划]]
- [[LLM-Wiki/research/visual-token-pruning/research-plan.md|路线二：长政策条件下的视觉—政策协同压缩研究计划]]
- [[LLM-Wiki/research/multimodal-compositional-safety/overview.md|路线一已有调研与证据]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|路线二已有调研与证据]]
