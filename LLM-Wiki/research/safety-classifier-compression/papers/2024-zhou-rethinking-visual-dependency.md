---
id: paper-note-zhou-2024-rethinking-visual-dependency
type: paper-note
title: "Rethinking Visual Dependency in Long-Context Reasoning for Large Vision-Language Models"
tags: [paper-note, research, vision-language-model, context-pruning, long-context]
source_id: paper-zhou-2024-rethinking-visual-dependency
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# Rethinking Visual Dependency in Long-Context Reasoning

来源：[arXiv 预印本](https://arxiv.org/abs/2410.19732)。本轮阅读摘要和方法概要，未运行代码。

## 方法与证据边界

该工作观察到长文本上下文会使 LVLM 过度依赖语言并弱化视觉依赖，因此用 training-free context pruning 删除较不关键的文本信息，以降低文本噪声并恢复视觉依赖。它说明 decoder-only LVLM 中确有可剪的文本上下文，但成立条件是长上下文与文本噪声；不能据此外推短政策、短用户指令或否定/例外条件也可安全删除。

对当前安全 Guard，它只应作为“若实测文本前缀很长，再研究 span/context compression”的条件性证据，而不是默认 baseline。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。
