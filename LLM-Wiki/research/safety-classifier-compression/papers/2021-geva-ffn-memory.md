---
id: paper-note-geva-2021-ffn-memory
type: paper-note
title: "Transformer Feed-Forward Layers Are Key-Value Memories"
authors: ["Mor Geva", "Roei Schuster", "Jonathan Berant", "Omer Levy"]
year: 2021
venue: "EMNLP 2021"
source_id: paper-geva-2021-ffn-memory
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, representation-probing]
status: active
related: []
created: 2026-08-31
updated: 2026-08-31
---

# Transformer Feed-Forward Layers Are Key-Value Memories

## 核心发现

论文把 FFN 第一层方向解释为匹配输入模式的 key，第二层方向解释为影响输出词表分布的 value；较低层更多匹配浅层模式，较高层更多匹配语义模式，最终 FFN 输出是多个“记忆”的组合并经残差路径逐层细化。

## 对本课题的边界

这支持 MLP 承担逐 token 非线性特征变换和部分模式/知识表征，但不是“全部知识只存于 MLP”的证明，也没有直接比较剪 MHA 与剪 MLP 的任务损失。多模态安全中可把 FFN 视为危害概念与决策特征的候选承载处，仍须以安全任务消融验证。

## 证据位置

- 摘要；key-value memory 构造；层间浅层—语义模式分析。
