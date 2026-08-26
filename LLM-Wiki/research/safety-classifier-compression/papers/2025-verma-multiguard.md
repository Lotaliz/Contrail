---
id: paper-note-verma-2025-multiguard
type: paper-note
title: "MULTIGUARD: An Efficient Approach for AI Safety Moderation Across Languages and Modalities"
authors: ["Sahil Verma", "Keegan Hines", "Jeff Bilmes", "Charlotte Siska", "Luke Zettlemoyer", "Hila Gonen", "Chandan Singh"]
year: 2025
venue: "EMNLP 2025"
source_id: paper-verma-2025-multiguard
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, safety-guardrail, multimodal-safety, representation-probing, efficient-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# MULTIGUARD

## 核心方法

识别 LLM/MLLM 内跨语言或跨模态较一致的中间表征，以其训练轻量有害 prompt 分类器；可在主模型本来要生成时复用已经计算的 embedding。

## 主要证据

作者报告相对最强基线，跨语言准确率提升 11.57%、图像 prompt 提升 20.44%，音频达到新 SOTA；复用生成表征时约比下一最快基线快 120×。

## 证据定位与局限

摘要、方法和效率实验。速度结论依赖底座 forward 已经发生；若作为生成前独立 Guard，不能把大模型表征成本忽略。
