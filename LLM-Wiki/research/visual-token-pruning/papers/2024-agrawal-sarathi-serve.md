---
id: paper-note-agrawal-2024-sarathi-serve
type: paper-note
title: "Taming Throughput-Latency Tradeoff in LLM Inference with Sarathi-Serve"
authors: ["Amey Agrawal", "Nitin Kedia", "Ashish Panwar", "Jayashree Mohan", "Nipun Kwatra", "Bhargav Gulavani", "Alexey Tumanov", "Ramachandran Ramjee"]
year: 2024
venue: "OSDI 2024"
source_id: paper-agrawal-2024-sarathi-serve
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, model-serving, continuous-batching, slo-aware-serving, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# Sarathi-Serve

## 与当前课题的关系

Sarathi-Serve 通过 chunked-prefill 和 stall-free scheduling 构造更均匀的批次，直接证明 batch 内计算不均衡会同时损伤吞吐与尾延迟。双自适应 Guard 会让每个请求的序列长度和执行层集合都不同，形成二维异构，因此必须把 execution signature 纳入组批，而不应把 batch 支持留作普通工程优化。

## 证据边界

论文主要处理生成模型的 prefill/decode 干扰；若 Guard 只生成一个短标签，decode 优化价值有限。当前课题更应测 time-to-verdict、排队与 prefill，而不是机械照搬 TTFT/TPOT 全套目标。
