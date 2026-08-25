---
id: paper-note-chi-2024-llama-guard-vision
type: paper-note
title: "Llama Guard 3 Vision: Safeguarding Human-AI Image Understanding Conversations"
authors: ["Jianfeng Chi", "Ujjwal Karn", "Hongyuan Zhan", "Eric Smith", "Javier Rando", "Yiming Zhang", "Kate Plawiak", "Zacharie Delpierre Coudert", "Kartikeya Upasani", "Mahesh Pasupuleti"]
year: 2024
venue: "arXiv"
source_id: paper-chi-2024-llama-guard-vision
project: safety-classifier-compression
reading_level: discovered
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# Llama Guard 3 Vision

## 收录角色

面向图像—文本 prompt 与文本 response 的多模态安全分类，基于 Llama 3.2 Vision 微调，并评估内部 MLCommons taxonomy 与对抗攻击。作为多模态安全未压缩基线收录。

## 边界

论文主目标是安全能力而非剪枝或蒸馏，没有给出专门的压缩—精度—真实时延研究，因此不用于证明任何多模态压缩结论。
