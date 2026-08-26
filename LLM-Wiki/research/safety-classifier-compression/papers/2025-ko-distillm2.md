---
id: paper-note-ko-2025-distillm2
type: paper-note
title: "DistiLLM-2: A Contrastive Approach Boosts the Distillation of LLMs"
authors: ["Jongwoo Ko", "Tianyi Chen", "Sungnyun Kim", "Tianyu Ding", "Luming Liang", "Ilya Zharkov", "Se-Young Yun"]
year: 2025
venue: "ICML 2025"
source_id: paper-ko-2025-distillm2
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, method, knowledge-distillation, on-policy-distillation, model-compression]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-26
---

# DistiLLM-2

## 核心方法

区分教师生成的正序列与学生生成的负序列：提高教师响应似然、降低学生失败响应似然，并配套数据筛选/课程，而不是把两类数据都当作普通 MLE 样本。

## 证据与边界

论文覆盖 instruction following、代码、preference alignment 和 vision-language 任务，为 OPD 的对比式数据配对与多模态扩展提供证据。证据位置：§3 方法、§4 实验与附录数据细节。它没有专门验证安全判别或多模态 Guard。
