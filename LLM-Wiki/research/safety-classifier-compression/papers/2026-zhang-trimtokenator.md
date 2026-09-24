---
id: paper-note-zhang-2026-trimtokenator
type: paper-note
title: "TrimTokenator: Towards Adaptive Visual Token Pruning for Large Multimodal Models"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-zhang-2026-trimtokenator
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# TrimTokenator

来源：[ACL 2026 Findings 官方页](https://aclanthology.org/2026.findings-acl.1633/)。本轮阅读摘要、引言和模态冗余结论，未运行代码。

## 方法与直接证据

作者从 attention、语义分布和信息重复分析视觉与文本 token 的冗余差异，明确选择保留全部文本 token、只剪视觉 token；视觉侧再以跨模态互信息与模态内多样性选择。论文报告在 LLaVA 系列上删除 88.9% token 并改善推理速度。

## 对联合剪枝的边界

它构成对“视觉与文本应对称剪枝”的正式反证：通用 LMM 中文本序列较短、单 token 语义密度和因果依赖更高。安全 Guard 中长政策、长用户文本或重复模板可能改变这一成本结构，但必须由长度分布与真实时延证明，不能预设双模态同时剪一定优于只剪视觉。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。
