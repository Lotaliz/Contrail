---
id: note-2025-he-zipvl
type: paper-note
title: "ZipVL: Accelerating Vision-Language Models through Dynamic Token Sparsity"
tags: [paper-note, research, visual-token-pruning, sparse-attention, efficient-inference]
source_id: paper-he-2025-zipvl
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [ICCV Table 5](https://openaccess.thecvf.com/content/ICCV2025/papers/He_ZipVL_Accelerating_Vision-Language_Models_through_Dynamic_Token_Sparsity_ICCV_2025_paper.pdf) 与 [arXiv v2 §5.4/Table 4](https://arxiv.org/html/2410.08584v2)；未复现。层级动态 attention 稀疏性与 KV eviction 联合优化 prefill 和 decode。

LLaVA-NeXT-13B、A100、输入 8K–128K。TTFT 明确 batch 1：128K 48.01→20.57 s（2.33×），16K 2.64→2.61 s（约 1.01×）。Decode throughput 用各方法单卡能支持的最大 batch，正文明确缩小 KV 后能扩大 batch；16K 14.10→40.87 tokens/s（约 2.9×，作者概括 2.8×）。未列实际 batch 值，不是固定 batch 比较，更不是 batch 1 的 decode 加速。时延段未充分界定视觉编码是否计入；质量 VQA 测试也不自动绑定长输入 profiling 点。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
