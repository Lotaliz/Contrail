---
id: paper-note-lin-2020-autoregressive-kd
type: paper-note
title: "Autoregressive Knowledge Distillation through Imitation Learning"
authors: ["Alexander Lin", "Jeremy Wohlwend", "Howard Chen", "Tao Lei"]
year: 2020
venue: "EMNLP 2020"
source_id: paper-lin-2020-autoregressive-kd
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: low
tags: [paper-note, research, method]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-25
---

# Autoregressive Knowledge Distillation through Imitation Learning

## 论文角色

把自回归 KD 明确表述为 imitation learning：训练时让教师监督学生会访问的状态，以减轻 teacher-forcing 的 exposure bias。它是现代 OPD 的方法谱系证据，不是安全或现代 LLM 的直接证据。

## 方法与证据

- 采用学生生成前缀上的教师监督，并讨论参考数据、教师轨迹和学生轨迹的状态分布差异。
- 在机器翻译和摘要任务中，相对从头训练报告 1.4–4.8 BLEU/ROUGE 增益，并给出相对教师最高 14× 推理加速。
- 证据位置：§2–3 方法；§4 实验；§5 结果。

## 边界

实验模型和任务早于当前指令 LLM；没有安全分类、校准、teacher-query 成本或长推理证据。

