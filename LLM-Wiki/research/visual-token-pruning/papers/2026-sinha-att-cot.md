---
id: note-2026-sinha-att-cot
type: paper-note
title: "Attention-guided Fine-tuning of Multimodal Large Language Models Improves Chain-of-Thought Reasoning"
tags: [paper-note, research, vision-language-model, representation-probing, multimodal-pretraining]
source_id: paper-sinha-2026-att-cot
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Attention-guided Fine-tuning of Multimodal Large Language Models Improves Chain-of-Thought Reasoning

来源：[原文](https://arxiv.org/abs/2606.01558)；阅读版本：2606.01558v1。

## 原文事实
阅读引言、§3–5、主表及结论。Att-CoT 以视觉 attention 和延迟 answer commitment 辅助 CoT-SFT，不改架构；覆盖三类模型、六个规模和三个推理基准。§5.5 在 CLEVR/ChartQA 遮挡关键区域验证视觉依赖，避免只看 attention。

## 边界与研究判断
“过早承诺”和训练纠正并非新的通用发现；它仍研究 CoT 输出，不保证短标签 Guard 的时延。我们可将 reasoning 教师作为训练期监督，但必须实测压缩学生的 first-verdict 能力，不能假设 CoT 蒸馏就能把额外计算无损消除。未复现；完整超参与推理长度待专项复核。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

