---
id: note-2024-zhou-multimodal-situational-safety
type: paper-note
title: "Multimodal Situational Safety"
tags: [paper-note, research, multimodal-safety, safety-evaluation, vision-language-model]
source_id: paper-zhou-2024-multimodal-situational-safety
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-20
updated: 2026-09-20
---

# Multimodal Situational Safety

来源：[arXiv v2 HTML](https://arxiv.org/html/2410.06172v2)。核验摘要、数据构造、主要实验和分析；未复现。arXiv 页面标注 ICLR 2025 camera ready。

## 问题与构造

论文研究同一个语言活动在不同视觉情境中安全性翻转，例如普通环境下可进行的活动在悬崖、交通或其他危险环境中不应被直接鼓励。MSSBench 覆盖 chat 与 embodied agent，并为安全/危险情境成对构造图文样本。

数据流程从日常安全图片与活动出发，由语言模型生成危险情境描述，再检索或生成对应图片并人工核验。不同论文版本公开的总量口径有差异；本综述不合并版本数字，复现时应锁定 release。

## 主要发现

- 模型同时受视觉理解、显式安全知识和情境推理三项能力限制。
- 提供 ground-truth caption 可揭示视觉理解瓶颈；自生成 caption 对部分开放 chat 模型有帮助，但可能干扰 embodied 模型。
- 显式安全推理和多代理分解可改善平均表现，却也可能对安全情境过度敏感，不能简单以更多拒答代替情境理解。

## 与 strict `S-S-U` 的边界

语言活动通常单独安全，组合标签由视觉情境决定，因此机制上高度相关。但危险情境图片可能单独已呈现明显风险，不一定满足政策意义上的 $y_I=\mathrm{safe}$。本页将其作为现实情境扩展，而不计入最严格的 safe-safe-unsafe 核心证据。

关联：[[LLM-Wiki/research/multimodal-compositional-safety/landscape.md]]。

