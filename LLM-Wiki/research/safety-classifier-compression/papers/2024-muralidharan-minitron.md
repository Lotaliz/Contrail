---
id: paper-note-muralidharan-2024-minitron
type: paper-note
title: "Compact Language Models via Pruning and Knowledge Distillation"
authors: ["Saurav Muralidharan", "Sharath Turuvekere Sreenivas", "Raviraj Joshi", "Marcin Chochowski", "Mostofa Patwary", "Mohammad Shoeybi", "Bryan Catanzaro", "Jan Kautz", "Pavlo Molchanov"]
year: 2024
venue: "NeurIPS 2024"
source_id: paper-muralidharan-2024-minitron
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, structured-pruning, knowledge-distillation, model-compression]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Minitron

## 核心方法

用约 1024 个校准样本的激活统计评估 layer、head、FFN neuron 和 embedding channel，裁剪到目标结构，再以原模型做 KD 恢复；可迭代派生多个尺寸。

## 主要证据

Nemotron 15B 派生 8B/4B，每个尺寸最高使用少 40× 训练 token，训练整个 15B/8B/4B 家族成本节省 1.8×；相对从头训练，MMLU 最高提高 16%。同等计算下，剪枝后蒸馏优于普通继续训练。

## 证据定位与局限

图 2；重要性第 2.2 节；best practices 第 4 节，尤其第 4.3 节；主结果图 1。核心任务是通用语言模型，不是安全分类；恢复 KD 需要教师 forward。
