---
id: paper-note-ko-2024-distillm
type: paper-note
title: "DistiLLM: Towards Streamlined Distillation for Large Language Models"
authors: ["Jongwoo Ko", "Sungnyun Kim", "Tianyi Chen", "Se-Young Yun"]
year: 2024
venue: "ICML 2024"
source_id: paper-ko-2024-distillm
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, knowledge-distillation, on-policy-distillation, model-compression]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-26
---

# DistiLLM

## 核心方法

以 skew KL 平衡 forward/reverse KL 的病态行为，并通过自适应 off-policy 数据机制复用、刷新学生生成样本，减少连续 on-policy rollout 的训练成本。

## 证据与边界

- 作者在通用 LLM 蒸馏任务中报告相对近期 KD 约 2.5–4.3× 训练提速并保持性能。
- 证据位置：§3 方法；§4 实验；消融表验证散度与数据更新机制。
- 速度来自论文自身设置，不能外推到 Guard；历史 rollout 复用也意味着算法不是每一步严格 on-policy。
