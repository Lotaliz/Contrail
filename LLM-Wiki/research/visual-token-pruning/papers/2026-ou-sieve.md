---
id: note-2026-ou-sieve
type: paper-note
title: "When Vision Becomes Text: Visual Token Pruning via Cross-Modal Residual Guidance in VLMs"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-ou-2026-sieve
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v1 Efficiency Analysis/Table 6](https://arxiv.org/html/2608.10489v1)；未复现。结合文本子空间残差、文本注意力相关性与残差空间多样性剪视觉 token，另给 FlashAttention-compatible 评分。

LLaVA-NeXT-7B、POPE yes/no 生成、保留 11.1%；GPU 与请求 batch 在所核正文未明确。作者概括 2.49× E2E，但表 total 是整套 POPE 46:11→18:32；prefill 37:21→10:20（3.62×），F1 86.5→85.7。不能转为单请求绝对时延、长答案吞吐或服务级并发结论；97.5% 是多任务归一平均而非该 F1。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
