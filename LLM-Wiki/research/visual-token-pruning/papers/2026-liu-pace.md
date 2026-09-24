---
id: note-2026-liu-pace
type: paper-note
title: "PACE: A Unified Condense-and-Extract Paradigm for Fast VLM Inference"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-liu-2026-pace
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v1 §4.3/Table 2/Appendix A.3](https://arxiv.org/html/2608.27206v1)；未复现。自适应像素 condense 后，浅层双 attention extract；包含预编码预览开销。

Qwen2.5-VL-7B、固定分辨率、10% 预算、单 RTX 4090；DocVQA/TextVQA profiling，greedy。请求 batch 未明确。作者明确不加速自回归 decode，因此只报 TTFT 而非完整生成 E2E：视觉编码 148.84→49.47 ms，LLM prefill 217.05→32.69 ms；preview/resize 平均 34.62 ms 不含在两个阶段列，但包含在 TTFT 365.89→116.79 ms（3.13×）。不能将 prefill 6.64× 或 TTFT 3.13× 写成全答案加速。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
