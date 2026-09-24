---
id: note-2026-singguard-team-singguard
type: paper-note
title: "SingGuard: A Policy-Adaptive Multimodal LLM Guardrail with Dynamic Reasoning"
tags: [paper-note, research, safety-guardrail, multimodal-safety, early-exit, efficient-inference]
source_id: paper-singguard-team-2026-singguard
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-18
updated: 2026-09-24
---

# SingGuard

来源：[arXiv v1 原文](https://arxiv.org/html/2606.22873v1)。定向核验 §2.6、§3–4 和 §7，未全读训练证明/附录、审查代码或复现。

## 来源陈述

§2.6 的 hybrid 先生成 safe/unsafe 标签，将两种标签概率归一化作置信度；达到阈值即结束解码，否则继续政策推理。政策为运行时输入。§4 评测多模态、图像、文本和动态政策，Table 12 同时给性能和平均单样本时延。§7 明确指出 token 置信度在分布漂移下可能失准，以及合成数据与标注偏差。

§2.3.2 还显式构造 cross-modal attacks：把同一个政策相关有害意图拆到图像和文本，使两个模态单独看似无害而联合后违规。SingGuard-Bench 共 56,340 条，其中 13,677 条为多模态样本，但论文没有单列 strict hidden-intent 数量。Table 10 的 cross-modal attack split 上，unsafe F1 分别为 GuardReasoner-VL-7B 0.5071、Llama Guard 4 0.7795、LLaVAShield 0.7348、SingGuard-8B 0.9046、SingGuard-2B 0.9164。

## 本课题判断与边界

“多模态安全 Guard 按难度早退”已有直接先例。所核退出控制 reasoning 解码，不能将其收益解释成少执行 ViT 层。候选增量需要落到视觉计算前移、早出口可靠性和不确定分支的证据保留；仅增加置信阈值不足。论文平均时延没有在本地核验，不与 QuietPrune 的 prefill 数字直接排序。

对组合式安全课题，该文也是目前最直接的定向防御证据，但结果来自 2026 年 arXiv v1 和自建合成 benchmark；strict 子集数量、生成器独立划分与外部复验仍缺失，不应把 0.9164 F1 解释成问题已经解决。

关联：[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]；[[LLM-Wiki/research/multimodal-compositional-safety/overview.md]]。
