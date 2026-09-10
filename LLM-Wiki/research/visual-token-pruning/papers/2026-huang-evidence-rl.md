---
id: note-2026-huang-evidence-rl
type: paper-note
title: "Evidence-RL: Towards Evidence-intensive Visual Reasoning"
tags: [paper-note, research, vision-language-model, representation-probing, multimodal-pretraining]
source_id: paper-huang-2026-evidence-rl
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Evidence-RL: Towards Evidence-intensive Visual Reasoning

来源：[原文](https://arxiv.org/abs/2608.08021)；阅读版本：2608.08021v1。

## 原文事实
阅读引言、图 2、§3、§4 主表和讨论/结论。CED 比较 evidence region 与匹配 non-evidence region 中和后的回答支持度下降，将该信号和正确性纳入 GRPO；反事实计算仅在训练期。实验含九个视觉推理基准，并有证据提案和干预方式消融。

## 边界与研究判断
训练期局部反事实监督、无需推理期审计已有直接先例。本文不研究 Guard 的压缩预算或固定 FPR；其 grounding 定义也不是任意政策关系的因果证明。候选贡献必须进一步处理压缩前后证据可见性、图文关系和过度蒸馏，不能只加 occlusion loss。未复现；后续需核对弱区域提案对 OCR/关系证据的覆盖。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

