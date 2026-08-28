---
id: paper-note-men-2025-shortgpt
type: paper-note
title: "ShortGPT: Layers in Large Language Models are More Redundant Than You Expect"
authors: ["Xin Men", "Mingyu Xu", "Qingyu Zhang", "Qianhao Yuan", "Bingning Wang", "Hongyu Lin", "Yaojie Lu", "Xianpei Han", "Weipeng Chen"]
year: 2025
venue: "Findings of ACL 2025"
source_id: paper-men-2025-shortgpt
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, structured-pruning, model-compression, training-free]
status: active
related: []
created: 2026-08-27
updated: 2026-08-27
---

# ShortGPT

## 核心方法

Block Influence 使用残差块输入与输出隐藏状态的余弦距离衡量层影响；输入输出越相似，越可能删除。该指标一次前向即可同时得到所有层的分数。

## 对本课题的证据与边界

BI 是低成本、整块级的激活代理，适合预筛；但隐藏状态接近不等于安全决策不变，尤其可能忽略只影响少数长尾危害样本或最终判定 margin 的模块。因此不宜作为安全 Guard 的唯一排序依据。
