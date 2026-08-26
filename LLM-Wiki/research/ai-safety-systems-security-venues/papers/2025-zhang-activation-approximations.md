---
id: paper-note-zhang-2025-activation-approximations
type: paper-note
title: "Activation Approximations Can Incur Safety Vulnerabilities in Aligned LLMs: Comprehensive Analysis and Defense"
authors: ["Jiawen Zhang", "Kejia Chen", "Lipeng He", "Jian Lou", "Dan Li", "Zunlei Feng", "Mingli Song", "Jian Liu", "Kui Ren", "Xiaohu Yang"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-zhang-2025-activation-approximations
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, safety-alignment, safety-evaluation, efficiency-evaluation, efficient-inference, quantization]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-26
---

# Activation Approximations Can Incur Safety Vulnerabilities in Aligned LLMs: Comprehensive Analysis and Defense

## 研究问题与收录理由

论文检验部署中常见的激活近似是否会在通用效用变化不明显时破坏对齐安全。它与量化、稀疏化等效率优化直接相邻，是压缩研究必须纳入安全指标的核心反例。

## 方法概览

作者在 10 个已对齐 LLM 上系统评估 7 种激活近似技术，覆盖多项式近似、稀疏化和量化三类，并分析近似误差在不同层的影响。针对共同风险，论文提出 QuadA，通过面向近似误差的对齐训练增强鲁棒性。

## 主要实验与结论

结果显示，多种激活近似可显著提高越狱攻击成功率，同时保持常规模型效用；早期层近似尤其危险。QuadA 在多类误差分布和自适应越狱下改善安全表现，说明需要直接针对部署近似进行对齐，而非仅验收任务精度。

## 局限与项目关联

结论针对激活近似及论文所选模型、攻击与参数范围，不能扩展为所有结构剪枝的普遍定律。对压缩实验应联合报告任务精度、安全攻击成功率和真实硬件时延，并做逐层敏感性分析。

## 泛读结论

与安全压缩最直接相关，若要确定具体量化或稀疏配置，应升级精读并复核各表格设置。
