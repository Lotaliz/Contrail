---
id: paper-note-yang-2024-clip-kd
type: paper-note
title: "CLIP-KD: An Empirical Study of CLIP Model Distillation"
authors: ["Chuanguang Yang", "Zhulin An", "Libo Huang", "Junyu Bi", "Xinqiang Yu", "Han Yang", "Boyu Diao", "Yongjun Xu"]
year: 2024
venue: "CVPR 2024"
source_id: paper-yang-2024-clip-kd
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, knowledge-distillation, vision-language-model, model-compression]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# CLIP-KD

## 核心方法

系统比较 feature、relation、gradient、contrastive 等蒸馏信号。结果显示简单 feature MSE 很强，interactive contrastive 次之；核心解释是最大化 teacher/student 特征相似度。

## 主要证据与局限

在 CC3M+12M 上，多种学生的 zero-shot ImageNet 与图文检索均提升；以 LAION-400M 教师时，ViT-B/16 达 57.5% Top-1。teacher 预训练数据远大于学生，提升不能只归因于 loss；安全类别与校准未验证。
