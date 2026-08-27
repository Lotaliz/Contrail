---
id: paper-note-dai-2024-apparate
type: paper-note
title: "Apparate: Rethinking Early Exits to Tame Latency-Throughput Tensions in ML Serving"
authors: ["Yinwei Dai", "Rui Pan", "Anand Iyer", "Kai Li", "Ravi Netravali"]
year: 2024
venue: "SOSP 2024"
source_id: paper-dai-2024-apparate
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, dynamic-inference, early-exit, model-serving, slo-aware-serving, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-26
---

# Apparate

## 与当前课题的关系

Apparate 自动注入并管理 early exits，以请求级早退缓和 serving 的 latency-throughput 冲突；它还让已提前返回的请求继续执行到完整模型，用最终结果持续监控精度并在线调节 ramp 与阈值。这已经覆盖“主干自适应 + serving + 在线质量反馈”的大部分一般性表述。

## 对新颖性的约束

当前课题不能只把分类置信度门控换成 Guard。需要证明安全判别存在不同于普通 accuracy 的约束，例如 fixed-FPR 下漏报、风险类别 worst-group、不可对所有请求继续完整执行的资源限制，以及视觉证据压缩与主干早退之间的耦合失效。
