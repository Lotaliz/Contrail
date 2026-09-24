---
id: note-2023-tang-mue
type: paper-note
title: "You Need Multiple Exiting: Dynamic Early Exiting for Accelerating Unified Vision Language Model"
tags: [paper-note, research, vision-language-model, early-exit, efficient-inference]
source_id: paper-tang-2023-mue
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-18
updated: 2026-09-21
---

# MuE

来源：[arXiv v2 原文](https://arxiv.org/html/2211.11152v2)与 [Google Research 题录](https://research.google/pubs/you-need-multiple-exiting-dynamic-early-exiting-for-accelerating-unified-vision-language-model/)。核验 §3–4、算法 1 和 Table 1，未复现。题录确认 CVPR 2023。

## 来源陈述

§3 将 OFA 的图文 encoder 分模态执行并共享参数，以跨层隐藏状态相似度决定各模态停止深度；decoder 同样早退出，并以各 decoder 层的任务损失训练。§4 评测 SNLI-VE 和 COCO captioning，不是独立安全 Guard。

## 本课题判断与边界

视觉/文本编码深度动态选择以及生成阶段多出口已有先例。但表示跨层相似不证明安全判别正确，停止 encoder 也不等于结束整个判别。不能把该 OFA 架构直接视作 Qwen-VL 的即插即用组件。

关联：[[LLM-Wiki/research/visual-token-pruning/research-plan.md]]。
