---
id: paper-note-wang-2024-p-pruning
type: paper-note
title: "Pruning before Fine-tuning: A Retraining-free Compression Framework for Pre-trained Language Models"
authors: ["Pingjie Wang", "Hongcheng Liu", "Yanfeng Wang", "Yu Wang"]
year: 2024
venue: "LREC-COLING 2024"
source_id: paper-wang-2024-p-pruning
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, structured-pruning, model-compression, efficient-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# P-pruning

## 研究问题与方法

把剪枝移到 task fine-tuning 之前，避免先完整微调再压缩。Dual-CP 用目标任务无标签输入聚类 attention head 和 FFN neuron 输出，再选择代表 centroid 保留。

## 主要证据

BERT 在 GLUE/SQuAD、GPT-2 在语言建模上评估。MNLI 的 60% FLOPs 约束下，论文报告 fine-tuning 约 1.8× 加速并降低 40% FLOPs；多个任务在较高压缩率下优于其他 retraining-free 方法。

## 证据定位与局限

方法第 3 节；分类图 2；时间图 4；消融表 2 与图 6。模型规模较小，真实部署推理时延未形成跨设备主表；保留结构显著任务特异。
