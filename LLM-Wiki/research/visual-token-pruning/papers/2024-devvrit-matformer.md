---
id: paper-note-devvrit-2024-matformer
type: paper-note
title: "MatFormer: Nested Transformer for Elastic Inference"
authors: ["Devvrit", "Sneha Kudugunta", "Aditya Kusupati", "Tim Dettmers", "Kaifeng Chen", "Inderjit Dhillon", "Yulia Tsvetkov", "Hannaneh Hajishirzi", "Sham Kakade", "Ali Farhadi", "Prateek Jain"]
year: 2024
venue: "NeurIPS 2024"
source_id: paper-devvrit-2024-matformer
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, vision-language-model, model-compression, structured-pruning, dynamic-inference]
status: active
related: []
created: 2026-08-28
updated: 2026-08-28
---

# MatFormer

## 核心方法

在每层 FFN 中训练嵌套宽度，形成参数包含关系的 universal MatFormer；Mix'n'Match 可为不同层选择不同粒度，组合出大量未被单独训练的子模型。论文覆盖 decoder-only MatLM 与视觉 MatViT。

## 对自适应模型规模判断的作用

论文同时允许两种部署语义：提前抽取一个小模型，或把 universal model 保存在内存中，随资源、输入难度、query/token 动态抽取子模型。两种情况都不是在请求关键路径重新估计重要性并永久删除权重，而是利用训练好的嵌套索引进行切片或条件执行。

## 证据位置与边界

- universal model 与子模型抽取：§1、§3.3。
- dynamic workload 下按 token/query 抽取：§3.3 的 Dynamic Workloads。
- MatViT 自适应检索与内存驻留：§4。
- 原论文没有安全判别、风险不对称、模型加载时延或动态路径组批实验；它证明模型弹性，不提供完整 Guard serving runtime。
