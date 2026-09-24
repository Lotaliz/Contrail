---
id: note-2023-mu-gist-tokens
type: paper-note
title: "Learning to Compress Prompts with Gist Tokens"
authors: [Jesse Mu, Xiang Lisa Li, Noah Goodman]
year: 2023
venue: NeurIPS 2023
source_id: paper-mu-2023-gist-tokens
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: high
tags: [paper-note, research, model-compression, efficient-inference]
status: active
created: 2026-09-22
updated: 2026-09-24
---

# Gist Tokens：可复用提示压缩

来源：[NeurIPS 2023 官方页](https://proceedings.neurips.cc/paper_files/paper/2023/hash/3d77c6dcc7f143aa2154e7f4d5e22d68-Abstract.html)与 [arXiv HTML](https://arxiv.org/html/2304.08467)。定向核验方法概览与 §6 效率实验；未运行代码。

## 来源陈述

Gisting 通过 attention mask 训练模型把指令压入少量可缓存 gist token，在 LLaMA-7B 与 FLAN-T5-XXL 上报告最高 26× 提示压缩、40% FLOPs 降低。墙钟收益远小于 token/FLOPs：作者报告的最高 wall-time 加速为 4.2%，而 LLaMA-7B 相对完整指令 KV cache 只有约 1%。

## 对当前课题的判断

Gist token 提供“政策离线编译/缓存”的机制先例，也再次说明压缩比不能替代端到端计时。安全政策含否定、例外、范围和角色边界，不能直接套普通指令质量指标；需要条款召回、同图政策翻转、未见政策和 fixed-FPR unsafe recall 约束。

它更适合作为 policy compiler 的基线或初始化，不足以单独构成长政策图像 Guard 的 CVPR 贡献。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。
