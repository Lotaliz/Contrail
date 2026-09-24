---
id: visual-token-pruning-motivation
type: synthesis
title: "研究动机：长政策条件下的视觉—政策协同预算"
tags: [research, writing, visual-token-pruning, multimodal-safety, efficient-inference]
project_id: visual-token-pruning
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, webpage-cvpr-2027-cfp]
status: deprecated
created: 2026-09-08
updated: 2026-09-23
---

# 研究动机：长政策条件下的视觉—政策协同预算

> **历史动机。** 本页对应 2026-09-22 的联合压缩主线；当前课题已改为短政策条件下的文本政策指导视觉剪枝，见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|新版课题方案]]。下文保留原场景约束和候选假设，不作为当前贡献主张。

## 场景约束

目标是输入图像 $I$ 与运行时政策 $P$，预测 $y(I,P)$。在当前数据和模型上，用户报告 $N_p>4N_v$，90% pre-ViT 视觉剪枝只有 1.14× 端到端加速且质量明显下降。这个结果说明：即使视觉选择器本身接近无损，视觉路径也不是当前系统的主要可移除成本。

## 失败假设

原计划假设“越早删除视觉 patch，越能获得足以支撑论文的端到端收益”。Dyna-ViT 复现和 token 分布推翻了该假设。只筛选短政策数据会改变任务以适配方法，无法说明真实政策 Guard 的效率；把主张改成普通分类精度提升，又容易被校准、类别不平衡或 dropout 正则化解释。

## 已有证据与剩余问题

| 论点 | 直接证据 | 写作边界 |
|---|---|---|
| 联合图文 token 压缩属于 CVPR 范围 | MADTP, CVPR 2024 | 不能声称首次；其架构和成本结构不同 |
| 政策自适应图像 Guard 是视觉问题 | SafeEditBench/SafeGuard-VL, CVPR 2026 | 不等于已有大规模短政策训练集 |
| 同图异策数据可用于政策敏感评测 | PolicyShiftBench | 政策长度、模板捷径和许可证仍需本地审计 |
| 提示可编译为少量可缓存 token | Gist Tokens | 普通提示质量不能替代安全条款保持；墙钟收益可能远小于 FLOPs |
| pre-ViT 与 query-guided visual pruning 已有先例 | Dyna-ViT、QuietPrune | 视觉 selector 只能作为联合方案的一部分 |

## 正式研究问题

> 当长自然语言政策主导多模态 Guard 成本时，能否把政策编译为可审计条款表示，并根据图像联合选择政策条款与视觉 patch，在未见政策、否定/例外和同图政策翻转上保持安全非劣，同时获得真实端到端加速？

该问题保留明确的视觉核心：图像证据决定哪些政策条款激活，政策条款决定哪些 patch 值得高成本编码。创新不在“两侧都删”，而在**视觉—条款协同覆盖与风险约束回退**。

## 方法假设

若完整政策先离线编译为条款图或少量 policy memory，低成本视觉预览能以高召回检索候选条款，再由候选条款指导 pre-ViT patch 选择，那么联合预算可能同时缩短主导的 LLM 输入和视觉路径。full-policy/full-vision teacher、同图异策边界对和不确定回退可能控制安全退化。以上均为 hypothesis，尚无本地实验。

## 不能提前写成贡献

- 不声称首次联合图文剪枝、首次政策自适应 Guard 或首次 pre-ViT pruning。
- 不把用户报告的 1.14× 写成已归档 reproduced 结果。
- 不把政策摘要、token 比例或 FLOPs 直接等同于 wall-clock 加速。
- 不把平均 accuracy 提升等同于安全鲁棒性。
- 不把只在短政策数据上的收益外推到真实长政策。

完整方法和实验见 [[LLM-Wiki/research/visual-token-pruning/research-plan.md]]；三路线评估见 [[LLM-Wiki/research/visual-token-pruning/long-policy-bottleneck-pivot-assessment.md]]。
