---
id: note-2026-wang-stc
type: paper-note
title: "Accelerating Streaming Video Large Language Models via Hierarchical Token Compression"
tags: [paper-note, research, visual-token-pruning, video-understanding, efficient-inference]
source_id: paper-wang-2026-stc
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

定向核 [arXiv v2 §4.1/Tables 1–2](https://arxiv.org/html/2512.00891v2) 与 [作者仓库](https://github.com/lern-to-write/STC)；CVPR 2026，未复现。STC-Cacher 缓存相邻帧特征省 ViT；STC-Pruner 在编码后按时空相关性压缩 LLM 输入。

ReKV/LLaVA-OV-7B 在 OVO-Bench/StreamingBench 的流式视频生成式问答，采用 0.5 fps 协议；所核主文 GPU 和请求 batch 未明确。ViT 编码 16 帧时间 103.7→78.3，LLM prefill 482.4→263.7，分别 -24.5%/-45.3%；主文 caption 与 README 标 s，必须沿用作者单位，异常绝对量级仍需实现核验，不换算为 ms。两列都不包含完整答案 decode，16 帧也不是 16 请求。Online VideoLLM 是模型场景，不等于提供服务级全响应计时。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
