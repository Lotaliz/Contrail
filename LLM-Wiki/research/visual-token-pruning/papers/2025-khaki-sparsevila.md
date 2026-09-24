---
id: note-2025-khaki-sparsevila
type: paper-note
title: "SparseVILA: Decoupling Visual Sparsity for Efficient VLM Inference"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-khaki-2025-sparsevila
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [ICCV 2025 原文 §4.4](https://openaccess.thecvf.com/content/ICCV2025/papers/Khaki_SparseVILA_Decoupling_Visual_Sparsity_for_Efficient_VLM_Inference_ICCV_2025_paper.pdf) 的可访问效率片段与 [后续 arXiv v1](https://arxiv.org/html/2510.17777v1) 的 Inference Setting/Latency Evaluation；版本不同，不拼接同一工作点，未复现。

Prefill 视觉压缩与 decode 的 query-aware 视觉 KV 检索解耦。ICCV 自报图像 1.4×、长上下文 prefill 3.6×、decode 1.7×；A6000、batch 1、AWQ/TinyChat 优化流水线。后续 v1 则明确视觉 W8A8、LLM W4A16、单 A6000、batch 1、greedy；所有后续加速相对已量化基线。E2E 包括视觉 E、prefill P 和 decode D，图像每轮固定输出 50 tokens、视频 250、reasoning 单轮 1500，多轮查询的 chunked prefill 摊入初始阶段；视频 Nemotron-Nano-VL-8B/256 帧表点报告 4.0× P、2.5× D、2.6× E2E。不是线上服务并发，也不能把量化加速额外算成剪枝收益。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
