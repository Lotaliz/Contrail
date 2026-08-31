---
id: paper-note-wang-2026-gisp
type: paper-note
title: "From Local to Global: Revisiting Structured Pruning Paradigms for Large Language Models"
authors: ["Ziyan Wang", "Enmao Diao", "Qi Le", "Pu Wang", "Minwoo Lee", "Shu-ping Yeh", "Evgeny Stupachenko", "Hao Feng", "Li Yang"]
year: 2026
venue: "ACL 2026"
source_id: paper-wang-2026-gisp
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, model-compression, efficient-inference]
status: active
related: []
created: 2026-08-31
updated: 2026-08-31
---

# From Local to Global / GISP

## 核心方法与发现

GISP 以目标 loss 的一阶梯度为 head 和 MLP channel 打分，在结构级聚合后做 block-wise normalization，再以全局、迭代方式联合分配剪枝预算。论文对语言建模使用 PPL 目标，对 decision-style task 使用 margin 目标；迭代剪枝形成嵌套子网。在 20%–50% 稀疏率上，作者报告相对局部重构式结构剪枝更稳，并显示任务对齐校准可提升 GSM8K exact match。

## 对本课题的证据与边界

它直接支持“head 与 MLP channel 应在统一成本预算下、围绕目标决策 loss 联合排序”，而不是先验决定剪 MHA 或 MLP。其 decision evidence 来自推理/问答而非多模态安全；论文也指出 attention 结构决策可能高度敏感，因此安全任务需加入 fixed-FPR 与 worst-group 约束复核。

## 证据位置

- 摘要与方法：全局一阶重要性、block-wise normalization、迭代嵌套子网。
- Appendix A.5：MedQA 任务对齐结果；Appendix 的结构分布与 attention 敏感性讨论。
