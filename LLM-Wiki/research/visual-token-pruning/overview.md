---
id: visual-token-pruning-overview
type: research-overview
title: "短政策条件下的文本政策指导视觉 Token 剪枝"
tags: [research, visual-token-pruning, multimodal-safety, efficient-inference, vision-language-model]
status: active
related: [multimodal-compositional-safety, safety-classifier-compression]
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, webpage-cvpr-2027-cfp, paper-zheng-2025-safety-attention-heads, paper-wang-2025-sasa, paper-zou-2025-shiftdc, paper-chen-2025-safeptr, paper-wang-2026-sap, paper-arxiv-2609-27988, paper-arxiv-2609-34861, code-hf-2026-qwen3-vl-modeling, paper-arxiv-2610-13263]
created: 2026-09-08
updated: 2026-10-13
---

# 短政策条件下的文本政策指导视觉 Token 剪枝

## 当前主线

**2026-10-10 安全表征分支：** 用户报告新的自适应预算实验正在运行，实际配置及结果尚未核验；同时提出用特定政策下正反样本的早期激活指导选择。新增 [[LLM-Wiki/research/visual-token-pruning/cx-policy-safety-representation-pruning.md|政策条件证据保留调研]]，区分语言拒答表征、原生 image-only ViT、区域贡献与预算收益。该方向暂为研究假设，可与当前 Cx 分工；本轮新增三篇略读并复用 SafeWatch/SafePTR/SAP 等，未修改正式 motivation。

**2026-10-10 命名更新：** 当前逐样本自适应视觉预算方法统一称为 **Cx**；**C5** 保留为原固定 5% 方法与历史结果的名称。当前方案及方法记录已同步更名，见 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|Cx 方法方案]]。

**2026-10-10 小图条件补充：** 用户报告当前全图平均约 400 个视觉 Token，1/16 裁图难支持原示例的较大原尺寸档位。当前方法中的局部绝对示例改为 0/8/16，并补充相对裁图参考网格的三档表达；框覆盖、原图信息分辨率及编码容量分别讨论。400 为用户报告，未独立复测，数据构造来源见历史研究计划。源码与判断边界见 [[LLM-Wiki/research/visual-token-pruning/qwen3-vl-resolution-budget-notes.md|Qwen 网格说明]]；未确定扩大数据或改变网格的执行配置。

**2026-10-10 方法细化：** 用户提出全局/局部两种指导指标及两个轻量预测网络。最新 v2 方法将其定义为共同审核代价单位的全局升级收益、给定全局预算的条件局部收益，代价仅含 NLL 和标签不一致；每个视图三个预算档位，局部包含零档。方法不规定数据规模/范围、执行步骤、门禁或失败处置。完整定义及条件局部收益与局部独立充分性的区别见 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|双重要性方法方案]]；[[LLM-Wiki/experiments/20261010-cx-global-local-importance/README.md|记录入口]]现登记用户报告的新自适应实验运行状态，尚无结果。前版配置分类器保留为结构对照。

**2026-10-10 最新决策：** 用户不将 5% 作为核心，先解决逐样本预算划分，暂不考虑 batch。Cx 复用原 C5 图文预览，选择全局/单局部框各自的实际 Token 数 $(K_g,K_l,b)$；前版配置分类器设计保留为结构对照。详见 [[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md|逐样本分配的前版设计]]；ResAdapt、M3、VisionThink 补查笔记已关联。全部新增效果待验证。

**2026-10-09 观察与历史建议：** 用户以 NLL 构造路线收益训练新 router，报告 50/50 使用率很低、总体指标与原方法接近；尚无具体数值或配对显著性结论。原 [[LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md|5% 高清升级 pilot]]保留为对照选项；最新设计不受其固定档位约束。原始定性观察见 [[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md|NLL router 记录]]。

**2026-10-08 最新进展：** 用户完成 C5 的 2,967 行冻结 test：实际平均约 5.0792% 视觉预算、宏召回 0.4974、Unsafe recall 0.7624、E2E 均值 58.90 ms，相对完整 B0 加速 1.438×。系统使用 128×128 图文 router，从全局及全局＋单局部框共 33 路线中选一条，并配套低预算恢复 Guard。用户确定后续保留单局部框，重点改善政策指导的解释性与效果。原始报告与证据边界见 [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md|C5 实验分析]]；具体假设与消融见 [[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md|单局部框后续建议]]。本 Wiki 未复现模型运行。

2026-09-23 起，主线改为**文本政策指导的视觉 Token 剪枝**：从已有长政策按模板派生可读短政策，使其成为目标工作负载的输入条件，再研究政策如何影响视觉证据选择与实际推理成本。短政策改写不作为论文贡献；仍需验证其同图政策翻转、FPR、未见政策和各体系覆盖情况。

此前用户报告：约 882-token 长政策主导输入时，90% pre-ViT 视觉剪枝仅约 1.14× 端到端加速且精度明显下降；该数字仍缺可复核原始 profiler。用户现报告约 32-token 模板短政策可经训练取得接近长政策的初步分类/召回，但完整结果尚未归档。缩短政策后视觉路径占比和可得加速须重新测量，不能沿用旧上限。

完整场景数据构造、首轮 baseline 协议、方法假设和 CVPR 边界见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。历史路线的决策和证据边界见 [[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md|清理记录]]与阅读日志。

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

- [[LLM-Wiki/research/visual-token-pruning/papers/2026-ma-sheafprune.md|SheafPrune精读笔记]]：图传播与度修正、固定配置消融、预算条件和prefill口径（2026-10-13）。

- [[LLM-Wiki/research/visual-token-pruning/reading-log.md|2026-10-10：两批 selected 精读（六篇＋七篇）与证据边界]]
- [[LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md|C5 自适应总预算：高清救回门与共同尺度候选评分]]
- [[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md|NLL 收益 router 的初步观察与预算假设]]

- [[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md|C5 后续：条款级收益、像素反事实监督与单框预算选择]]
- [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md|C5 结果与比较边界]]

- [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划：短政策条件下的文本政策指导视觉剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|SafeGuard-VL 与 PolicyShiftGuard 定义、方法和边界比较]]
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

既有 XGuard、双向 Token 干预、双证据压缩和其他实验记录继续保留，因为它们包含基线、失败和可复用诊断；它们不是当前 C5 的实验结果。旧长政策下的 1.14× 与 token 比例仍是历史用户报告，不能替代 C5 的新测量。2026-10-08 的新 baseline 与 C5 汇总已存入实验分析；其逐样本 logits、路线缓存、实现 revision 和完整 profiler 尚未纳入本 Wiki，不标为 reproduced。
