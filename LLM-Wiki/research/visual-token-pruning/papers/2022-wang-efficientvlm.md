---
id: note-2022-wang-efficientvlm
type: paper-note
title: "EfficientVLM: Fast and Accurate Vision-Language Models via Knowledge Distillation and Modal-adaptive Pruning"
tags: [paper-note, research, vision-language-model, model-compression, knowledge-distillation, structured-pruning, efficient-inference]
source_id: paper-wang-2022-efficientvlm
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# EfficientVLM

来源：[arXiv 原文](https://arxiv.org/abs/2210.07795)；阅读版本：2210.07795v1；阅读摘要、方法概览和报告结果，未运行代码。

## 方法与直接证据

作者先在视觉语言预训练阶段把大模型蒸馏为紧凑模型，再根据下游任务对视觉、文本和跨模态模块做 modal-adaptive 结构/神经元剪枝。论文给出的 EfficientVLM 配置含 6 个视觉层、3 个文本层和 3 个融合层；作者报告模型为教师参数量的 44.3%，保留 98.4% 表现并有 2.2 倍推理加速。

## 与本课题的边界

它直接表明“蒸馏后减少视觉层数”不是新原语。其任务是通用视觉语言理解，且学生结构整体缩小；未研究独立多模态 Guard、固定 FPR 困难召回、输入分辨率/patch 与视觉深度的联合最坏状态。本文所报数字不能迁移为本地安全判别收益。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。

