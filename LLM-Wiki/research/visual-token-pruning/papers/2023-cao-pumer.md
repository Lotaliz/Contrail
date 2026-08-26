---
id: paper-note-cao-2023-pumer
type: paper-note
title: "PuMer: Pruning and Merging Tokens for Efficient Vision Language Models"
authors: ["Qingqing Cao", "Bhargavi Paranjape", "Hannaneh Hajishirzi"]
year: 2023
venue: "ACL 2023"
source_id: paper-cao-2023-pumer
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, token-merging, vision-language-model]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-26
---

# PuMer: Pruning and Merging Tokens for Efficient Vision Language Models

## 研究问题

如何利用图文相关性减少 cross-modal encoder 中的视觉与文本 token，同时避免纯删除的信息损失和跨模态直接合并造成的表示混淆？

## 方法与流程

PuMer 在多个 cross-modal layers 渐进插入无参数 token reducers：用文本指导视觉 token 剪枝，并分别在图像、文本模态内部合并相似 token；训练基本沿用下游微调，并加入知识蒸馏缩小精度差距（§4.1–§4.3）。它同时减少视觉与文本 token，是本调研中少见的联合模态压缩方案。

## 实验与直接证据

- 主干：ViLT-110M 与 METER-330M；任务：Flickr30K 检索、VQAv2、SNLI-VE、NLVR2。
- Table 1：METER 各任务 throughput 1.79–2.07×、峰值显存下降 38%–43%，绝对性能下降 0.5–0.9；ViLT 为 1.74–2.01×、显存下降 45%–51%，下降 0.4–0.7。
- Table 3：ViLT/VQAv2 从 69.5 降到 68.9，throughput 1.76×；移除文本指导或模态内合并会分别降低速度收益，表明两部分作用不同。
- Table 4：更早、更强压缩带来更高吞吐但更大精度损失；分散在多层的渐进策略更稳。

## 局限

作者指出：若 cross-modal encoder 本身较轻、主要成本在视觉编码器（如 ALBEF、X-VLM），只在融合层减 token 的端到端收益有限（§8）。方法针对编码式 VLM，不直接解决长自回归输出、multi-turn cache 或生成时相关性漂移。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
