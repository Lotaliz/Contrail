---
id: paper-note-khare-2025-superserve
type: paper-note
title: "SuperServe: Fine-Grained Inference Serving for Unpredictable Workloads"
authors: ["Alind Khare", "Dhruv Garg", "Sukrit Kalra", "Snigdha Grandhi", "Ion Stoica", "Alexey Tumanov"]
year: 2025
venue: "NSDI 2025"
source_id: paper-khare-2025-superserve
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, dynamic-inference, model-routing, model-serving, slo-aware-serving, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# SuperServe

## 与当前课题的关系

SuperServe 用权重共享 supernetwork 近即时激活大量精度—时延子网，并由 SlackFit 根据请求 slack 选择子网。它是“双自适应”课题最接近的 serving 先例之一：简单地预生成多个剪枝配置再按 SLO 路由，可能只是把 SuperServe 应用到 Guard。

## 可区分空间

当前课题需要证明 Token 预算和主干预算不是独立的两个旋钮，而会共同决定安全证据是否在特定层仍可判别；同时需要解决同一 GPU batch 中二维执行签名不一致、Guard 特有风险约束和安全回退。否则系统贡献容易被评价为已有 subnet serving 加一种新 workload。
