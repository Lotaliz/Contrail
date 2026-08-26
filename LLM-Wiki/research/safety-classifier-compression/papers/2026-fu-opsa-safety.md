---
id: paper-note-fu-2026-opsa-safety
type: paper-note
title: "Reducing the Safety Tax in LLM Safety Alignment with On-Policy Self-Distillation"
authors: ["Yu Fu", "Longxuan Yu", "Haz Sameen Shahgir", "Zhipeng Wei", "Hui Liu", "N. Benjamin Erichson", "Yue Dong"]
year: 2026
venue: "arXiv preprint"
source_id: paper-fu-2026-opsa-safety
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, safety-alignment, knowledge-distillation, on-policy-distillation]
status: active
related: [on-policy-distillation]
created: 2026-08-25
updated: 2026-08-26
---

# Reducing the Safety Tax in LLM Safety Alignment with On-Policy Self-Distillation

## 核心方法

OPSA 让当前模型生成 rollout；冻结的教师副本在额外“特权安全上下文”条件下，对同一学生前缀提供逐 token KL。Teacher flip rate 衡量特权条件把不安全学生响应转为安全教师响应的频率。作者认为更新集中在早期“是否顺从危险请求”的决策 token。

## 直接结果

- 在两个推理模型家族、五个规模上评估安全—推理权衡；作者报告相对匹配基线，R1-Distill-1.5B 和 Qwen3-0.6B 的综合权衡分别提高 8.85 和 5.49 点，并测试 adaptive jailbreak。
- 证据位置：§3 方法；§4 主结果；安全上下文/early-token 分析；Limitations。

## 局限与项目解释

- 截至 2026-08-25 为预印本，未经过正式会议评审。
- 方法依赖基础模型已有可被 prompt 激活的潜在安全能力，教师仍是冻结的同源模型；不能创造教师缺失的能力。
- 有害数据过滤和部分评估使用 Llama-Guard，继承其误差。
- 这是生成式安全对齐而非独立 Guard 分类压缩。它支持在“会生成归因的自回归 Guard”中做直接实验，但不能替代固定 FPR、每类召回、校准和归因忠实度验证。
