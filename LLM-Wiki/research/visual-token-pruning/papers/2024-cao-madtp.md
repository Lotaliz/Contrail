---
id: note-2024-cao-madtp
type: paper-note
title: "MADTP: Multimodal Alignment-Guided Dynamic Token Pruning for Accelerating Vision-Language Transformer"
authors: [Jianjian Cao, Peng Ye, Shengze Li, Chong Yu, Yansong Tang, Jiwen Lu, Tao Chen]
year: 2024
venue: CVPR 2024
source_id: paper-cao-2024-madtp
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, vision-language-model, visual-token-pruning, dynamic-inference, efficient-inference]
status: active
created: 2026-09-22
updated: 2026-10-20
---

# MADTP：图文双分支动态 Token 剪枝

来源：[CVPR 2024 官方页](https://openaccess.thecvf.com/content/CVPR2024/html/Cao_MADTP_Multimodal_Alignment-Guided_Dynamic_Token_Pruning_for_Accelerating_Vision-Language_Transformer_CVPR_2024_paper.html)与 [arXiv v1](https://arxiv.org/html/2403.02991)。定向核验摘要、§1、§3、主实验和附录 C.3；未运行代码或模型。

## 来源陈述

MADTP 面向 CLIP/BLIP 一类视觉、语言双分支 VLT。它先用共享可学习 token 对齐两种模态，再在 Transformer block 内按实例和层动态设置阈值。附录 C.3 分别评测只压视觉、只压语言和同时压两者；因此，“图文 token 联合压缩不属于 CVPR”这一顾虑不成立。

论文在 BLIP/NLVR2 上报告最高 80% GFLOPs 降低时测试精度从 83.08 降至 79.22。附录也显示该任务的语言分支计算很小且更敏感：只压语言几乎不降 GFLOPs却显著掉点；视觉与语言联合压缩仍由视觉侧节省主导。

## 对当前课题的边界

它是**会议范围与联合剪枝机制先例**，也是“首次联合剪图文 token”新颖性声明的直接反证。但其文本是普通短句、架构是 BERT/ViT 双分支，和“decoder-only Guard 中政策 token 超过视觉 token 四倍”的成本结构相反。当前贡献必须来自长政策、结构化政策压缩、同图异策安全约束和真实端到端计时，而不能只把 MADTP 移植到安全数据。

关联：[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]；[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。
