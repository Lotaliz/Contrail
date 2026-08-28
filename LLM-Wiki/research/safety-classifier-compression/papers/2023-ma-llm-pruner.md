---
id: paper-note-ma-2023-llm-pruner
type: paper-note
title: "LLM-Pruner: On the Structural Pruning of Large Language Models"
authors: ["Xinyin Ma", "Gongfan Fang", "Xinchao Wang"]
year: 2023
venue: "NeurIPS 2023"
source_id: paper-ma-2023-llm-pruner
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, model-compression]
status: active
related: []
created: 2026-08-27
updated: 2026-08-27
---

# LLM-Pruner

## 核心方法

先识别必须共同删除的依赖结构，再以校准集损失对参数置零的 Taylor 近似评估组重要性。论文保留一阶项 `|gradient × weight|`，并以经验 Fisher 近似 Hessian 对角项；参数级得分再以 sum、product、max 或 last-only 聚合为耦合组得分，剪枝后用 LoRA 恢复。

## 对本课题的证据

它为“安全任务损失上的 `gradient × weight`”提供直接方法基础，并说明真正的剪枝对象应是可执行的耦合组，而非任意单参数。论文原实验是通用语言建模与零样本任务，不证明安全或多模态最优；梯度估计还高度依赖校准分布。

## 证据位置

- 方法与 Taylor/Fisher 公式：§3.2，Eq. 3–5。
- 组聚合与结构依赖：§3.1–3.2。
- 质量恢复与成本：§3.3、实验部分。
