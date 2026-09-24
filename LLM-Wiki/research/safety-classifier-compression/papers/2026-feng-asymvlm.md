---
id: paper-note-feng-2026-asymvlm
type: paper-note
title: "AsymVLM: Asymmetric Token Pruning for Efficient Vision-Language Model Inference"
tags: [paper-note, research, vision-language-model, visual-token-pruning, kv-cache, efficient-inference]
source_id: paper-feng-2026-asymvlm
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# AsymVLM

来源：[arXiv 预印本](https://arxiv.org/abs/2605.29535)。本轮阅读摘要、架构动机与方法概要，未运行代码；结论按预印本证据处理。

## 方法与直接证据

AsymVLM 将现代 decoder-only VLM 的两类瓶颈显式拆开：视觉 token 空间冗余高并主导 prefill，因此在 prefill 前由 learned cross-modal scorer 做样本级视觉预算；文本 token 具有因果依赖并随生成累积，因此只在解码序列超过预算后做阈值式 KV eviction。prompt/prefill 文本 token 无条件保护。作者报告最高 54% FLOPs 节省。

## 对“联合输入剪枝”的意义

它不是视觉与输入文本的共同剪枝，而是按模态和阶段采取不同压缩对象：视觉侧压输入，文本侧管生成期 cache。对“安全标签 + 简短归因”的短输出 Guard，文本解码 cache 还未增长到足以成为主瓶颈，因此该论文更支持视觉输入剪枝与文本保护，而不是支持输入端的双模态共同删除。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。

