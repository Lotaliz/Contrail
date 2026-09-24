---
id: paper-note-chen-2025-safeptr
type: paper-note
title: "SafePTR: Token-Level Jailbreak Defense in Multimodal LLMs via Prune-then-Restore Mechanism"
tags: [paper-note, research, multimodal-safety, vision-language-model, visual-token-pruning]
source_id: paper-chen-2025-safeptr
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# SafePTR

来源：[NeurIPS 2025 官方论文](https://papers.neurips.cc/paper_files/paper/2025/hash/53f1c3ec5df814b5aabe9ae88a29bb49-Paper-Conference.pdf)。本轮阅读摘要、方法与主要结果，未运行代码。

## 方法与直接证据

SafePTR 在 MLLM 的 early-middle vulnerable layers 中，将视觉 token 和用户指令 token 分别与安全对齐指令表示比较，删除偏离安全空间最大的 token；后续 Benign Feature Restoration 再恢复良性特征。论文以降低 jailbreak attack success rate 并保持通用 utility 为目标，覆盖三种 MLLM 与文本/视觉驱动攻击。

## 对安全判别压缩的边界

这是“安全目标同时作用于视觉与文本 token”的直接正式先例，但不是独立 Guard 的输入压缩：它主动删除诱发不安全生成的证据，而安全分类器必须保留同一危害证据才能检出 unsafe；恢复/旁路还会改变净计算收益。因此只能作为安全相关 token interaction 与分模态归一化的邻接证据，不能作为低时延 Guard 的直接基线。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。
