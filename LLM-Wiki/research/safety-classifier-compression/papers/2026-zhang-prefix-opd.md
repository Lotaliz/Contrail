---
id: paper-note-zhang-2026-prefix-opd
type: paper-note
title: "Fast and Effective On-Policy Distillation from Reasoning Prefixes"
authors: ["Dongxu Zhang", "Zhichao Yang", "Sepehr Janghorbani", "Jun Han", "Andrew Ressler II", "Qian Qian", "Gregory D Lyng", "Sanjit Singh Batra", "Robert E. Tillman"]
year: 2026
venue: "Findings of ACL 2026"
source_id: paper-zhang-2026-prefix-opd
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, knowledge-distillation, on-policy-distillation, model-compression]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-26
---

# Fast and Effective On-Policy Distillation from Reasoning Prefixes

## 核心方法与结果

作者观察长推理序列的 reverse-KL 监督在早期 token 更强，因而截断学生 rollout，只蒸馏 reasoning prefix。Qwen3 系列在数学/OOD 推理上的实验报告与完整 OPD 相近的效果，同时将训练 FLOPs 降低约 2–40×。

## 证据边界

证据位置：§3 方法、§4 结果及 prefix-length 消融。结果针对长推理；短 `safe/unsafe` 标签可能本就没有可截断冗余。对 Guard 的启发是假设“判定 token 优先”，而非已验证结论。
