---
id: note-2025-wang-internvl35-vico
type: paper-note
title: "InternVL3.5: Advancing Open-Source Multimodal Models in Versatility, Reasoning, and Efficiency"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation, dynamic-inference]
source_id: paper-wang-2025-internvl35
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# InternVL3.5: Advancing Open-Source Multimodal Models in Versatility, Reasoning, and Efficiency

来源：[原文](https://arxiv.org/abs/2508.18265)；阅读版本：2508.18265v2；仅聚焦 ViR/ViCO，authors 登记第一作者，完整名单见原文。

## 原文事实
阅读引言、架构/训练图、§2 的 ViCO、§3.15 表 17 和结论，未精读其余任务。式 7 用冻结参考模型做跨压缩率输出 KL；同一 patch 可表示为 256 或 64 tokens。随后冻结主模型、训练 ViR；式 8–9 从压缩损失比构造路由标签。表 17：8B 的总体均分 80.2→79.8，不能外推安全无损。

## 边界与相关性
视觉 token 网格压缩不等于在视觉塔之前降低原图分辨率；ViR 是额外组件。固定预算复用一致性训练可作无 router 基线，但这是本项目改编。论文直接阻止“首次跨预算一致性学习与质量损失驱动路由”的主张。
待升级：复现 ViCO 数据规模、投影/像素重排和视觉塔耗时。代码入口以论文/InternVL 官方项目为准，本轮未运行。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

