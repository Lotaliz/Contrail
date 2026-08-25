---
id: paper-note-lee-2025-saferoute
type: paper-note
title: "SafeRoute: Adaptive Model Selection for Efficient and Accurate Safety Guardrails in Large Language Models"
authors: ["Seanie Lee", "Dong Bok Lee", "Dominik Wagner", "Minki Kang", "Haebin Seong", "Tobias Bocklet", "Juho Lee", "Sung Ju Hwang"]
year: 2025
venue: "Findings of ACL 2025"
source_id: paper-lee-2025-saferoute
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# SafeRoute

## 研究问题与方法

压缩 Guard 在少量困难输入上落后于大 Guard。SafeRoute 训练二分类 router，容易样本走小 Guard，预计大模型能纠错的困难样本走大 Guard。

## 主要证据

WildGuardMix oracle 分析：1B Guard F1 0.6702，8B Guard 0.7054；若仅 5.09% 样本使用 8B，可达 0.8101。正文与附录在多个基准上比较 FLOPs/F1 和大模型使用率。

## 证据定位与局限

观察与 oracle 表 2；方法第 3.2 节；trade-off 图 6–9；限制节。oracle 不是可部署结果；实际 router 依赖训练数据对边界样本的代表性，分布漂移可能把高风险样本误送小模型。
