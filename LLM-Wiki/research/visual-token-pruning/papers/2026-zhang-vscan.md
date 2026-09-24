---
id: note-2026-zhang-vscan
type: paper-note
title: "VScan: Rethinking Visual Token Reduction for Efficient Large Vision-Language Models"
tags: [paper-note, research, visual-token-pruning, token-merging, efficient-inference]
source_id: paper-zhang-2026-vscan
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v3 §5.4/Table 5](https://arxiv.org/html/2505.22654v3)；未复现。此前位置复核：global/local scan 用视觉输出层特征选择并合并，再在 LLM 中层剪枝，不是 ViT 内早剪。

LLaVA-NeXT-7B、平均保留 11.1%、POPE yes/no 生成。Total 为整套所有 POPE 样本 2294→1120 s（2.05×），prefill 累计 1420→488 s（2.91×）；不是单请求千秒或固定长输出延迟。另核 FlashAttention-compatible 评分及启用后的 prefill 数值，不能把兼容性等同主表使用所有优化。所核主文未明确该效率表 GPU 与请求 batch；标为待核，不反推 batch 1。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
