---
id: paper-note-yang-2025-alignment-recovery
type: paper-note
title: "Alleviating the Fear of Losing Alignment in LLM Fine-tuning"
authors: ["Kang Yang", "Guanhong Tao", "Xun Chen", "Jun Xu"]
year: 2025
venue: "IEEE S&P 2025"
source_id: paper-yang-2025-alignment-recovery
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# Alleviating the Fear of Losing Alignment in LLM Fine-tuning

## 研究问题与收录理由

论文研究下游微调破坏原有安全对齐后，能否在保留任务能力的同时恢复拒答行为。它提供了“效用基本保持但安全退化”的直接证据，对压缩后安全回归测试具有参考价值。

## 方法概览

方法比较原始对齐模型与微调模型的有害方向，利用梯度选择少量关键权重，将这些参数迭代恢复为原模型值；若恢复步骤损害下游任务，则通过回滚机制撤销该轮修改。

## 主要实验与结论

作者在由多种模型、任务和微调设置组成的 125 个微调模型上评估，报告平均有害回答率从 33.25% 降至 1.74%，下游任务性能平均下降 2.93%。论文同时展示即使使用干净数据微调，也可能提高有害回答率。

## 局限与项目关联

该方法需要访问原始对齐模型及其权重，适用于微调后的恢复，不等同于剪枝或量化防御。结果说明通用任务精度不能替代安全指标，但不能据此推断所有压缩方法都会产生相同退化。

## 泛读结论

适合作为安全—效用双目标评测依据；若后续研究压缩后的权重恢复，可升级精读。
