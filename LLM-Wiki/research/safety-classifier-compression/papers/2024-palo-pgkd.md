---
id: paper-note-palo-2024-pgkd
type: paper-note
title: "Performance-Guided LLM Knowledge Distillation for Efficient Text Classification at Scale"
authors: ["Flavio Di Palo", "Prateek Singhi", "Bilal H Fadlallah"]
year: 2024
venue: "EMNLP 2024"
source_id: paper-palo-2024-pgkd
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

# PGKD

## 研究问题与方法

工业多分类常有标签稀少、类别多且不均衡的问题。PGKD 从 1000 个标注样本训练 BERT，向教师反馈验证指标、高置信误分类和 hard negatives，循环生成针对学生盲区的新数据，并以 early stopping 控制漂移。

## 主要证据

四个多类数据集上优于普通 BERT 与多种数据生成/KD 基线。批量 64 的延迟表中，BERT-base+PGKD GPU 为 0.46s，Llama 3 8B zero-shot 为 58.05s；作者概括最高约 130× 更快、25× 更便宜。

## 证据定位与局限

算法 1、图 1–2；消融表 4；成本表 5；限制节。循环教师生成本身昂贵，对 prompt 与教师领域能力敏感；未直接验证安全 taxonomy。
