---
id: paper-note-chen-2024-fastv
type: paper-note
title: "An Image is Worth 1/2 Tokens After Layer 2: Plug-and-Play Inference Acceleration for Large Vision-Language Models"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-chen-2024-fastv
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# FastV

来源：[ECCV 2024 官方页面](https://eccv.ecva.net/virtual/2024/poster/2009)及库内论文 PDF。本轮复核方法与主要效率结论，未运行代码。

FastV 复用 decoder-only LVLM 浅层中的文本—视觉 self-attention，以文本 token 对视觉 token 的聚合注意力给视觉 token 排序，并在后续 LLM 层物理删除低分 token。它 training-free、实现简单，是 text-guided intra-LLM pruning 的标准基线。

局限是选择发生在视觉编码器和若干 LLM 层之后，无法节省前段成本；attention 还可能带位置偏置，读取完整 attention 也可能影响 FlashAttention 路径。对安全任务，它应作为最低复杂度基线，而不是最终 selector。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]。

