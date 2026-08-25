---
id: paper-note-wu-2023-tinyclip
type: paper-note
title: "TinyCLIP: CLIP Distillation via Affinity Mimicking and Weight Inheritance"
authors: ["Kan Wu", "Houwen Peng", "Zhenghong Zhou", "Bin Xiao", "Mengchen Liu", "Lu Yuan", "Hong Xuan", "Michael Valenzuela", "Xi Chen", "Xinggang Wang", "Hongyang Chao", "Han Hu"]
year: 2023
venue: "ICCV 2023"
source_id: paper-wu-2023-tinyclip
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

# TinyCLIP

## 核心方法

让学生模仿教师的图文 affinity，并通过 weight inheritance 从教师选择/继承结构；极端压缩使用多阶段 progressive distillation，避免一次裁剪损失过大。

## 主要证据

CLIP ViT-B/32 压到 50% 参数仍保持接近零样本性能；权重继承相对从头训练加快 1.4–7.8×。ViT-8M/16 只用原 CLIP ViT-B/16 的 8.9% 参数，在 YFCC-15M 上 ImageNet zero-shot Top-1 为 41.1%，高 3.5 点。

## 证据定位与局限

摘要、图 1、方法第 3 节、zero-shot 与训练效率表。极小模型的训练数据与原 CLIP 不完全相同；weight inheritance 对异构 teacher/student 的兼容性有限。
