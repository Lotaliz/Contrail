---
id: note-2025-yang-visionzip
type: paper-note
title: "VisionZip: Longer is Better but Not Necessary in Vision Language Models"
tags: [paper-note, research, visual-token-pruning, token-merging, efficient-inference]
source_id: paper-yang-2025-visionzip
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-17
updated: 2026-09-17
---

本轮定向核本地不可改写的 CVPR 2025 原件 §3.3/Table 4；[官方来源](https://openaccess.thecvf.com/content/CVPR2025/html/Yang_VisionZip_Longer_is_Better_but_Not_Necessary_in_Vision_Language_CVPR_2025_paper.html)。未复现，非整篇精读。

视觉塔输出侧选择 dominant tokens 并聚合 context，属于剪枝—合并混合。时延测量为 LLaVA-NeXT-7B、单 A800-80GB、POPE yes/no 自回归生成；2880→160 token 时整套 total 2293→756 s（3.03×），prefill 218→27.8 ms（7.84×）。作者把 prefill 定义为生成首 token 的时间，但视觉编码是否纳入这个小计未清晰界定。推理请求 batch 未明确；伪代码 B 与 8 卡训练不作为 batch 1/大 batch 推理证据。

关联：[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]。
