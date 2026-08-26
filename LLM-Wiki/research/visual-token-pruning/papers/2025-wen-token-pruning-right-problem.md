---
id: paper-note-wen-2025-token-pruning-right-problem
type: paper-note
title: "Token Pruning in Multimodal Large Language Models: Are We Solving the Right Problem?"
authors: ["Zichen Wen", "Yifeng Gao", "Weijia Li", "Conghui He", "Linfeng Zhang"]
year: 2025
venue: "Findings of ACL 2025"
source_id: paper-wen-2025-token-pruning-right-problem
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, efficiency-evaluation]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-26
---

# Token Pruning in Multimodal Large Language Models: Are We Solving the Right Problem?

## 研究问题

该论文不是提出单一 SOTA selector，而是系统复核四个问题：精心设计的 attention ranking 是否优于 random/pooling；空间位置偏置是否破坏选择；语言指导何时有用；FLOPs/token ratio 是否反映真实加速。

## 设置与直接证据

- 模型：LLaVA-1.5-7B/13B、Qwen2-VL-72B；任务包括 GQA、MMBench、MME、POPE、ScienceQA、VQAv2、TextVQA、VizWiz、RefCOCO、Visual Haystack。
- 统一比较 FastV、SparseVLM、Random、Pooling、Window FastV 等，视觉 token 保留 144/576 或 64/576。
- LLaVA-1.5-7B 保留 144 时，Random/Pooling 综合相对性能 95.0%/96.4%，Vanilla FastV/SparseVLM 为 89.8%/93.5%；保留 64 时 Random 为 89.1%，FastV/SparseVLM 为 78.2%/87.3%（Table 1）。
- RefCOCO 保留约 22.2% token 时所有方法严重下降；SparseVLM 仅为原性能 4.8%，Random 23.2%，表明平均 VQA benchmark 会掩盖空间定位失败（Table 4）。
- FastV 的保留位置明显偏向视觉序列后部；加入 window spatial uniformity 后，75% pruning 的平均损失较 Vanilla FastV 缩小 3.4 个百分点，88.9% pruning 缩小 9 个百分点（§4.1–§4.2）。
- Visual Haystack 显示强文本条件任务中，去掉语言指导会明显下降；语言不是普遍无用，而是任务依赖（§5）。
- LLaVA-NeXT-7B 从 2880 降到 320 token：FastV 总时长 36:16→18:17，SparseVLM→23:11，MustDrop→23:40；相似 FLOPs/KV 并不产生相同 latency（Table 7）。

## 综合结论与边界

论文主张应同时平衡 predictive importance 与 redundancy/coverage：感知主导任务偏向结构覆盖，知识推理任务更需要任务相关性（§6，Table 6）。它支持把 random/pooling、空间覆盖、定位/OCR 以及真实 latency 设为强制基线。

该研究自身限制是模型与任务仍不可能覆盖所有 MLLM；其结论不能推出 attention 永远无效。它是对 FastV/SparseVLM 结果的独立反证，也构成当前调研判断研究成熟度的核心证据。

## 对当前课题的影响

- 不能再用“attention score 高”直接等同“应保留”。
- 生成任务需分开报告 TTFT、decode throughput、KV cache 与端到端 latency。
- 空间定位、OCR、计数、multi-turn 应进入最低评测集合。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
