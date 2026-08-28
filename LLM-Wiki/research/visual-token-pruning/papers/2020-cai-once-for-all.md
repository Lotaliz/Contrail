---
id: paper-note-cai-2020-once-for-all
type: paper-note
title: "Once-for-All: Train One Network and Specialize it for Efficient Deployment"
authors: ["Han Cai", "Chuang Gan", "Tianzhe Wang", "Zhekai Zhang", "Song Han"]
year: 2020
venue: "ICLR 2020"
source_id: paper-cai-2020-once-for-all
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, model-compression, structured-pruning, dynamic-inference, hardware-aware-optimization]
status: active
related: []
created: 2026-08-28
updated: 2026-08-28
---

# Once-for-All

## 核心方法

用 progressive shrinking 训练一个覆盖深度、宽度、卷积核和输入分辨率的 once-for-all network，再针对设备与时延约束搜索并导出专用子网，不为每个子网重新训练。

## 对自适应模型规模判断的作用

它支持“训练一张大超网、部署前选择较小子网”，但不是请求到来后现场运行剪枝算法。论文的主要适应对象是设备和部署约束，不是同一在线服务中按每个请求的风险动态切换。它也不证明必须加载超网全部权重：专用子网可以独立导出部署。

## 对当前课题的边界

可以作为多预算 Guard 子网训练的经典先例，但原任务以视觉分类和边缘设备为主，没有多模态安全、固定 FPR、风险回退或异构批处理。
