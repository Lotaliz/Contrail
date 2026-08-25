---
id: paper-note-gu-2024-minillm
type: paper-note
title: "MiniLLM: Knowledge Distillation of Large Language Models"
authors: ["Yuxian Gu", "Li Dong", "Furu Wei", "Minlie Huang"]
year: 2024
venue: "ICLR 2024"
source_id: paper-gu-2024-minillm
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-25
---

# MiniLLM

## 核心方法

以学生生成序列上的 reverse KL 为目标，并推导为 on-policy policy-gradient 优化；用单步分解降方差、teacher-mixed sampling 抑制 reward hacking、长度归一化消除偏短/偏长偏差。

## 证据与边界

- 在 120M–13B 模型族和 instruction-following 任务中验证；证据位置为 §2–4 与实验表格。
- Reverse KL 更集中于教师高概率模式，但可能降低多样性。方法需要教师 logits，且学生/教师 vocabulary 兼容性影响实现。
- 未做安全 Guard 或校准实验；在本项目中主要作为散度与稳定化路线证据。

