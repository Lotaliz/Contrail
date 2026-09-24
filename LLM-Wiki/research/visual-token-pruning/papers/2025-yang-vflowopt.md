---
id: note-2025-yang-vflowopt
type: paper-note
title: "VFlowOpt: A Token Pruning Framework for LMMs with Visual Information Flow-Guided Optimization"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-yang-2025-vflowopt
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v2 §4.4/Table 5](https://arxiv.org/html/2508.05211v2)；ICCV 2025，未复现。结合信息流校准、渐进剪枝、token 回收与离线策略优化。

LLaVA-OneVision-7B、单 A100-SXM4-80GB、MME 生成式短答案，所有样本平均效率。剪 90%：inference latency 1040.1→272.1 ms（3.82×），MME 1581→1464（-7.4%），KV -89%。剪 75%：328.5 ms、MME 1570（-0.7%）。请求 batch 与视觉/完整 decode 的计时起止未明确；正文的大 batch 容量优势是潜力讨论，不是实测大 batch 曲线。不能把最高速度称无损或严格完整 E2E。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
