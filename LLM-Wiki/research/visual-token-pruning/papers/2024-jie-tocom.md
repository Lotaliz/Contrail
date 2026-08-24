---
id: paper-note-jie-2024-tocom
type: paper-note
title: "Token Compensator: Altering Inference Cost of Vision Transformer Without Re-Tuning"
authors: ["Shibo Jie", "Yehui Tang", "Jianyuan Guo", "Zhi-Hong Deng", "Kai Han", "Yunhe Wang"]
year: 2024
venue: "ECCV 2024"
source_id: paper-jie-2024-tocom
project: visual-token-pruning
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

# Token Compensator: Altering Inference Cost of Vision Transformer Without Re-Tuning

## 收录与问题

当训练时 compression degree 与部署时预算不一致，现有 token compression 的精度会明显下降；论文试图无需为每个预算重新训练完整模型。

## 核心方法

用参数高效自蒸馏学习 Token Compensator，将不同压缩度模型的参数差近似为可迁移插件；推理时把插件插入下游 off-the-shelf 模型，补偿源/目标 compression degree 的差异。

## 实验与直接证据

覆盖 CIFAR100、细粒度分类与 VTAB-1k 等 20 多个下游任务。作者报告平均性能最高提升分别可达 2.3、1.5、2.0 个百分点。Fig. 3 展示 DeiT-B 随 ToMe 合并率变化的训练/推理吞吐，证明预算变化确有速度收益，但 ToCom 本身解决的是精度补偿。

## 证据定位

Fig. 2（源/目标压缩率不匹配）；Table 1（模型差跨任务迁移）；Fig. 3（吞吐—合并率）；§4（LoRA 式 compensator）；下游主表。

## 局限

需要先训练并存储补偿插件；不能替代目标硬件上的 budget profiling，也没有提出新的 selector。

