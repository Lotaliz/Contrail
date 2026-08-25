---
id: change-2026-08-24-survey-multimodal-token-pruning
type: change
title: 调研图文多模态分类与生成中的 Token 剪枝
tags: [research, method]
date: 2026-08-24
change_type: content
---

# 调研图文多模态分类与生成中的 Token 剪枝

## 范围变化

- 将 `visual-token-pruning` 从纯视觉判别任务扩展到图文编码式 VLM 与 decoder-only MLLM 的分类、检索、VQA、captioning、开放式生成和视频理解。
- 时间主体仍为 2023–2026，额外追溯 EMNLP 2022 的 TRIPS 作为文本指导视觉选择的早期代表。

## 新增知识

- 登记并保存 TRIPS、PuMer、FastV、VisionZip、DivPrune、SparseVLM、Wen et al. 批判性复核与 VisPCO 八篇正式论文。
- 新建多模态 Token 剪枝概念、专题综合与八份论文笔记。
- 建立四阶段分析框架：视觉编码器、projector/LLM 前、LLM 层内、KV/cache/decode。
- 分离分类与生成任务，并新增 query dependence、future relevance、multi-turn、幻觉、空间覆盖、TTFT/decode/KV 等约束。

## 主要判断

- 该方向在 2024–2026 已形成明显热点，但集中于 visual-token reduction，且方法排名尚不稳定。
- attention importance 不是普适真值；Random、Pooling、spatial coverage 与 diversity 是必要基线。
- prefill/FLOPs 改善不能代表端到端生成时延；必须分项报告 vision encode、TTFT、decode、KV 和 P95。
- “当前 query 相关性”和“未来生成/多轮可复用性”的冲突达到多来源证据门槛，进入正式研究动机。

## 结构影响

- 更新项目 overview、reading log、landscape、comparison、gaps、motivation 与 hypotheses。
- 更新概念实体、标签、首页导航、来源注册表与 CHANGELOG。
