---
id: paper-note-chang-2023-stvit
type: paper-note
title: "Making Vision Transformers Efficient From a Token Sparsification View"
authors: ["Shuning Chang", "Pichao Wang", "Ming Lin", "Fan Wang", "David Junhao Zhang", "Rong Jin", "Mike Zheng Shou"]
year: 2023
venue: "CVPR 2023"
source_id: paper-chang-2023-stvit
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# Making Vision Transformers Efficient From a Token Sparsification View

## 收录与问题

探索以少量语义 token 表示大量 patch token，并通过恢复机制兼容分类以外的判别任务。

## 核心方法

STViT 以池化初始化语义 token，再用注意力学习聚类中心；STViT-R 进一步恢复空间细节以服务检测和实例分割。

## 主要结论

作者报告 DeiT-T/S/B 仅用 16 个语义 token 时可保持相同分类精度、FLOPs 下降近 60%、inference speed 提升超过 100%；Swin 窗口内采用 16 个语义 token 可提速约 20%且精度轻微上升。检测/分割主干 FLOPs 可降 30% 以上。

## 证据定位

摘要；方法总览图；ImageNet 主表；下游检测/分割表。

## 局限

方法改变 token 表达并引入恢复模块，不是简单即插即用剪枝；摘要级速度主张需要在统一实现上复核。

