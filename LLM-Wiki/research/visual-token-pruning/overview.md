---
id: visual-token-pruning-overview
type: research-overview
title: "政策文本指导图像安全审核的视觉计算加速"
tags: [research, visual-token-pruning, multimodal-safety, efficient-inference, vision-language-model]
status: active
related: [multimodal-compositional-safety, safety-classifier-compression]
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, webpage-cvpr-2027-cfp, paper-zheng-2025-safety-attention-heads, paper-wang-2025-sasa, paper-zou-2025-shiftdc, paper-chen-2025-safeptr, paper-wang-2026-sap, paper-arxiv-2609-27988, paper-arxiv-2609-34861, code-hf-2026-qwen3-vl-modeling, paper-arxiv-2610-13263, paper-helff-2024-llavaguard, paper-qu-2024-unsafebench, paper-bao-2025-vmoda, paper-hang-2025-malicious-image-localization, report-user-20261013-visual-budget, report-user-20261013-cx-lambda-scan, paper-arxiv-2610-16615, paper-arxiv-2610-17530, paper-arxiv-2610-22957, paper-arxiv-2610-24740, paper-arxiv-2610-24968]
created: 2026-09-08
updated: 2026-10-21
---

# 政策文本指导图像安全审核的视觉计算加速

## 当前主线

输入图片与当前生效的文本政策，输出允许、拦截或违规类别；研究如何减少视觉计算，在维持政策适应和安全判定质量的同时降低真实端到端时延。文本是审核规则，不是与图片共同构成风险的用户请求。

**2026-10-20 当前方案：** [[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|整图分辨率研究计划]]从任务场景独立展开，围绕三个问题：文本从哪里读取信息、文本表征保留什么、这些信息是否影响最终审核决定。注意力、受控探针和状态替换分别提供不同层次的证据，目标是找到可解释且能便宜预测的预算需求信号，再训练轻量整图分辨率选择器。

先固定已使用的 Guard、政策与标签，比较完整输入、近乎无损的静态上限和明显退化的低预算；用同图政策对和允许/拦截两侧质量检验政策作用。当前不以全局＋局部框为方法前提。完整 Guard 的内部特征主要用于离线诊断或监督，在线预览、政策编码与选择器开销必须计入。

用户报告75 Token上限接近完整质量且约2×加速，并在PolicyShiftBench相应模型上观察到60 Token近乎无损。新方案标明各项会话观察的批次与证据边界；本次未复核新逐样本产物、重跑模型或证明文本中介成立。是否优于强静态预算，仍需同真实成本验证。

## 当前阅读与比较入口

- [[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|自包含研究方案：场景、三个问题、最小对照及预算选择]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-balaji-qart.md|QART]]：问题条件slot、重建停止标准和batch1成本（2026-10-21）。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-li-paa-bench.md|PAA-Bench]]：正确性转移、随机难度与同质量实测速度（2026-10-21）。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-li-visual-sufficiency-landscapes.md|Visual Sufficiency Landscapes]]：成功子集概率、行为保留与离线风险预测（2026-10-21）。

- [[LLM-Wiki/research/visual-token-pruning/papers/2026-song-policyshiftguard.md|PolicyShiftGuard / PolicyShiftBench：政策边界与同图配对]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-piao-safeguard-vl.md|SafeGuard-VL / SafeEditBench：政策自适应审核]]
- [[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|视觉剪枝基线与四项待补对照]]
- [[LLM-Wiki/research/visual-token-pruning/comparison.md|方法比较及带日期的历史判断]]
- [[LLM-Wiki/research/visual-token-pruning/landscape.md|机制背景与文献地图]]
- [[LLM-Wiki/research/visual-token-pruning/qwen3-vl-resolution-budget-notes.md|Qwen网格、信息分辨率与编码容量说明]]
- [[LLM-Wiki/research/visual-token-pruning/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/visual-token-pruning/watch/overview.md|近期论文追踪]]

## 历史资料与保留范围

旧短政策总方案、C5/Cx单框、双重要性预算及其空间安全表征分支已按用户要求删除。精确清单和历史链接去向见 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|清理记录]]。这些方案不再作为当前设计；C5/Cx名称继续保留在相应历史实验中。

- [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md|C5实验分析]]、[[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md|NLL router负结果]]、[[LLM-Wiki/experiments/20261010-cx-global-local-importance/README.md|Cx历史方法记录]]和[[LLM-Wiki/experiments/20261014-cx-lambda-scan-review/README.md|λ扫描分析]]继续保留，不能作为新方案的运行结果。
- [[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md|历史数据/政策样例审计]]、[[LLM-Wiki/research/visual-token-pruning/region-rationale-guided-safety-token-pruning.md|区域监督文献综述]]和其他实现、论文资料继续保留；其旧执行建议不作为当前扩数或局部路线要求。
- 所有原件、实验输出、论文阅读等级和人工候选决定保持原有证据口径。

## 与另一条路线的边界

[[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|图文联合风险路线]]研究图片与用户文本组合导致的安全漏洞；本路线研究图片在运行时政策下的审核计算。两者可以共享模型与工具，但不混用主贡献。总入口见 [[LLM-Wiki/research/multimodal-safety-guard/overview.md|双路线导航]]。