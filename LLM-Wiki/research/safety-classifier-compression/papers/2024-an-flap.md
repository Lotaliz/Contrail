---
id: paper-note-an-2024-flap
type: paper-note
title: "Fluctuation-Based Adaptive Structured Pruning for Large Language Models"
authors: ["Yongqi An", "Xu Zhao", "Tao Yu", "Ming Tang", "Jinqiao Wang"]
year: 2024
venue: "AAAI 2024"
source_id: paper-an-2024-flap
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, model-compression, training-free]
status: active
related: []
created: 2026-08-27
updated: 2026-08-27
---

# FLAP

## 核心方法

以输入特征相对样本均值的波动和对应权重估计删除通道后输出特征是否容易恢复，再按层和模块标准化分数、全局分配压缩率，并用基线均值形成额外 bias 补偿。全流程只需前向校准，不做恢复训练。

## 对本课题的证据

FLAP 比“激活均值/幅值越小越不重要”更接近可恢复性：稳定但非零的通道可由均值补偿，波动较大的通道更难删除。论文在通用 LLM 上报告优于结构化 Wanda 与带 LoRA 的 LLM-Pruner，但仍以 PPL/通用任务验收；迁移到安全判别时应在安全校准集上采集波动，并用任务消融复核。

## 证据位置

- Structured Fluctuation Metric 与 bias compensation：§3。
- 指标、结构搜索与补偿消融：§4.3。
- 校准样本敏感性与真实速度：§4.3–4.4。
