---
id: note-2026-zheng-visco
type: paper-note
title: "VisCo: Leveraging Large Language Models as Intrinsic Encoders for Visual Token Compression"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation]
source_id: paper-zheng-2026-visco
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# VisCo: Leveraging Large Language Models as Intrinsic Encoders for Visual Token Compression

来源：[原文](https://arxiv.org/abs/2607.12756)；阅读版本：2607.12756v1。

## 原文事实
阅读引言、图 2–3、方法总览、主结果表和结论。复用 VLM 构成共享参数自编码器，加入 memory tokens，并在编码/解码间传递分层 KV；评估三个主干、六个基准。

## 边界与研究判断
“主干不变”不等于“完整执行图不变”：记忆 token、双阶段编码和 KV 注入仍要计费。它与 ViCO（InternVL 一致性学习）是不同工作，不要混用名称。其价值是压缩前先编码语义的反例，但不能据此宣称零成本单 token Guard。待升级：编码阶段是否吞掉短标签加速、与原生多图/DeepStack 对齐；代码未核验和运行。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

