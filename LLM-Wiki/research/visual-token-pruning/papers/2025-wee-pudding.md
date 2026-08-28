---
id: paper-note-wee-2025-pudding
type: paper-note
title: "Prompt-based Depth Pruning of Large Language Models"
authors: ["Juyun Wee", "Minjae Park", "Jaeho Lee"]
year: 2025
venue: "ICML 2025"
source_id: paper-wee-2025-pudding
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, dynamic-inference, model-routing, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-28
---

# PuDDing

## 与当前课题的关系

PuDDing 观察到 Transformer block 重要性具有任务依赖性，先离线从多任务数据生成候选 omission sets，再训练轻量 router 预测给定 prompt 在各候选上的任务损失并选择最优集合。推理时只路由一次，不为当前 prompt 现场运行静态剪枝搜索。

在论文面向低内存设备的执行模型中，router 选定 omission set 后，从存储向高速内存加载构成该深度子网所需的 Transformer blocks；因此它是“按请求选择并加载预定义子网模块”的直接正例。论文也指出重复推理面对不同 prompt 时可能产生额外权重加载，只加载此前未加载的重叠块可缓解该成本。该语义并非所有弹性推理系统共有：若大模型权重已经全部常驻 GPU，加载节省会消失，只剩计算跳过收益。

它与“基于任务自适应的 LLM 主干剪枝”直接重合，因此该模块本身不能作为当前论文的主要算法新颖性。对 Guard 仍需把 task likelihood 改为风险、证据充分性和固定 FPR 约束，并解决多模态输入和异构批处理。

证据位置：§1 的执行模型与 Table 1，§5 的候选集合/router，§7.1 的路由与参数加载开销，§7.2 的任务相关 omission set。

## 可区分空间

安全 Guard 可研究 prompt 任务类型之外的风险难度、模态证据和策略类别，并将主干路径选择与视觉/文本 Token 覆盖、批处理效率及安全约束联合优化。仍需实验验证 Guard 中的最优省略层是否确实依赖这些因素。
