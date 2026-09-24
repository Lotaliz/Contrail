---
id: note-2026-zhu-hawk
type: paper-note
title: "HAWK: Head Importance-Aware Visual Token Pruning in Multimodal Models"
tags: [paper-note, research, visual-token-pruning, attention-calibration, efficient-inference]
source_id: paper-zhu-2026-hawk
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v1 §4.1/4.5/Table 5](https://arxiv.org/html/2604.07812v1)；CVPR 2026，未复现。按 attention head 重要性加权文本引导视觉选择。

效率用 Qwen2.5-VL-7B、MME、单 GPU；作者称 E2E latency，数值为整套评测 20:15→15:04（剪 80%，1.34×），同点 MME 2315→2311。不是单请求耗时。正文 VLMEvalKit/8 GPU/96GB 指质量评测环境，不能认定效率也用 8 卡；具体单卡型号、请求 batch、预处理/完整 decode 起止未明确。摘要的 96% 平均性能和该时延表 MME 不是一个指标。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
