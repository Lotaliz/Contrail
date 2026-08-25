---
id: paper-note-agarwal-2024-gkd
type: paper-note
title: "On-Policy Distillation of Language Models: Learning from Self-Generated Mistakes"
authors: ["Rishabh Agarwal", "Nino Vieillard", "Yongchao Zhou", "Piotr Stanczyk", "Sabela Ramos", "Matthieu Geist", "Olivier Bachem"]
year: 2024
venue: "ICLR 2024"
source_id: paper-agarwal-2024-gkd
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-25
---

# GKD

## 核心方法

Generalized Knowledge Distillation 用 $\lambda$ 混合固定数据序列和学生当前 rollout，并允许 forward/reverse KL、JSD 等散度。$\lambda=0$ 退化为监督式 KD，$\lambda=1$ 为纯 on-policy。其核心论点是教师应在学生自己的错误前缀上纠偏。

## 实验与结论

- 任务覆盖摘要、翻译、GSM8K 与 instruction tuning；学生通常从已有 SFT checkpoint 开始。
- 作者实验显示学生生成数据与合适散度通常优于只在固定序列上蒸馏；最优散度和混合比例依任务而变。
- 证据位置：§2 目标；§3 算法；§4–5 实验与结果；Appendix 实现细节。

## 对安全压缩的边界

该文支持“让自回归 Guard 在自己的 verdict/rationale 前缀上受教”，但没有安全判别、固定 FPR、多模态或归因忠实度实验。其“学生已能生成适当序列”的前提意味着弱 Guard 需要 SFT/静态数据预热。

