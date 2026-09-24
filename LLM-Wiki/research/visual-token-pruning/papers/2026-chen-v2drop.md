---
id: note-2026-chen-v2drop
type: paper-note
title: "Variation-aware Vision Token Dropping for Faster Large Vision-Language Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-chen-2026-v2drop
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v2 Table 5/Appendix A](https://arxiv.org/html/2509.01552v2)；CVPR 2026，未复现。LLM 内按跨层 token variation 渐进 drop，不需显式完整 attention map。

环境 A100-PCIe-80GB、Python 3.10/PyTorch 2.1.2/CUDA 12.1；请求 batch 未明确。图像 LLaVA-1.5-7B/MMBench、视频 LLaVA-OV-7B/MVBench 均为自回归答案生成。Caption 明确三层：LLM-only response、full-model response、整套 benchmark total。

图像三层分别 400→273.9 s（-31.5%）、558→429.3 s（-23.1%）、10:14→8:06（-20.8%）；同表性能保持 95.7%。视频分别 752.2→193.8 s（-74.2%）、1201.6→642.4 s（-46.5%）、32:02→23:13（-27.5%）；同表 99.1%。Throughput 单位 item/s，不足以证明 batch>1；不能将摘要其他预算的 94.0%/98.6% 绑定这里，也不能把 LLM-only 3.88× 称 E2E。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
