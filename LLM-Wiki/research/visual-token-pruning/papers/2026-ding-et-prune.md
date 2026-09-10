---
id: note-2026-ding-et-prune
type: paper-note
title: "ET-Prune: Evidence-Aware Dynamic Budgeting for Visual Token Pruning in Text-Rich MLLMs"
tags: [paper-note, research, vision-language-model, visual-token-pruning, dynamic-inference, budget-optimization]
source_id: paper-ding-2026-et-prune
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# ET-Prune: Evidence-Aware Dynamic Budgeting for Visual Token Pruning in Text-Rich MLLMs

来源：[原文](https://arxiv.org/abs/2608.01979)；阅读版本：2608.01979v1。

## 原文事实
阅读引言、方法与示意、表 1、复杂度讨论和结论。使用 query-key 局部读取、文本状空间区域保护、熵/密度驱动预算下限和中层渐进压缩；保持参数固定。表 1 比较 OCR/TextVQA，在 Qwen3-VL 与 InternVL3.5 上约一半视觉保留。作者限定为每配置一次确定性评测的点估计。

## 边界与研究判断
证据不确定性驱动预算已被直接研究；文中 risk-calibrated 不能自动解释成统计安全保证。中层剪枝保留早段完整计算，不直接解决短标签前向总成本。对原方案 evidence-budget 新颖性作降级，作为训练方法需要击败的推理基线。代码可复现性待核对；未复现。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

