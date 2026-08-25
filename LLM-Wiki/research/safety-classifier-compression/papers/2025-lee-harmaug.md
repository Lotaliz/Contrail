---
id: paper-note-lee-2025-harmaug
type: paper-note
title: "HarmAug: Effective Data Augmentation for Knowledge Distillation of Safety Guard Models"
authors: ["Seanie Lee", "Haebin Seong", "Dong Bok Lee", "Minki Kang", "Xiaoyin Chen", "Dominik Wagner", "Yoshua Bengio", "Juho Lee", "Sung Ju Hwang"]
year: 2025
venue: "ICLR 2025"
source_id: paper-lee-2025-harmaug
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# HarmAug

## 研究问题与方法

朴素教师标签蒸馏因有害指令覆盖不足而使小 Guard 失效。方法通过 affirmative prefix 诱导生成多样有害指令，再生成拒绝/有害/空响应，由 Llama-Guard-3 标注，训练 DeBERTa 学生。

## 实验与主要证据

训练使用 WildGuardMix 加 100k 合成有害指令；测试 OAI、ToxicChat、HarmBench、WildGuardMix。435M 学生平均 F1 0.7357、AUPRC 0.8362。WildGuardMix 的 A100 实测中，相对 Llama-Guard-3，FLOPs/token 0.6%、latency/token 25%、峰值显存 12%、成本 26%。

## 证据定位与局限

方法式 (1)–(2)；第 4.1 节表 1–2；red-teaming 表 3；新 jailbreak 第 4.3 节。教师与生成器成本没有被在线指标覆盖；主要是二分类安全标签，策略更新仍需再训练。
