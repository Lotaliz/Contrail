---
id: paper-note-liu-2026-crisprune
type: paper-note
title: "CrisPrune: Combining Contextual Relevance and Intrinsic Saliency for Efficient Visual Token Pruning in MLLMs"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-liu-2026-crisprune
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# CrisPrune

来源：[ACL 2026 Findings 官方页面](https://aclanthology.org/2026.findings-acl.663/)。本轮阅读摘要与方法概要，未运行代码。

CrisPrune 针对两类相反失败：纯视觉 attention 容易受 attention sink 影响，纯文本指导又容易把视野收得过窄、丢掉背景。其 training-free selector 联合 intrinsic visual saliency、text relevance 与多样性选择，从而同时覆盖任务焦点和全局语境。

这对安全 Guard 很重要：政策相关区域未必包含完成“行为—对象—语境”判断所需的全部证据。CrisPrune 的价值不是某个具体分数，而是把 relevance 与 coverage/diversity 明确设为不同目标。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]。

