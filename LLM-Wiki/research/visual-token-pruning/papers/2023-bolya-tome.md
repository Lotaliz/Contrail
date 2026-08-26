---
id: paper-note-bolya-2023-tome
type: paper-note
title: "Token Merging: Your ViT But Faster"
authors: ["Daniel Bolya", "Cheng-Yang Fu", "Xiaoliang Dai", "Peizhao Zhang", "Christoph Feichtenhofer", "Judy Hoffman"]
year: 2023
venue: "ICLR 2023"
source_id: paper-bolya-2023-tome
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, token-merging, training-free, efficient-inference]
status: active
related: []
created: 2026-08-24
updated: 2026-08-26
---

# Token Merging: Your ViT But Faster

## 收录与问题

作为纯剪枝的强邻接基线：能否不训练模型，通过快速匹配合并相似 token，在保留信息的同时提高现有 ViT 吞吐？

## 核心方法

在 block 内逐层执行 bipartite soft matching，把相似 token 合并并跟踪 token size；不依赖任务专用 selector，可在训练或推理时插入。

## 主要结论

作者报告高分辨率 ViT-L/H 图像推理吞吐约 2×，精度仅下降 0.2–0.3 个百分点；视频 ViT-L 约 2.2×。该结果说明高压缩率下“聚合”可优于不可逆删除。

## 证据定位

摘要；§3（matching 与 proportional attention）；Table 1（设计消融）；图像/视频/音频主实验表。

## 局限

属于 token merging 而非严格剪枝；速度依赖 matching kernel、分辨率和 batch，固定每层合并数未针对目标硬件优化。
