---
id: paper-note-chen-2026-priortr
type: paper-note
title: "Accelerating Multimodal Large Language Models with Prior-Corrected Token Reduction"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-chen-2026-priortr
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# PriorTR

来源：[arXiv 预印本](https://arxiv.org/abs/2606.24156)及[作者仓库](https://github.com/CodeChildCZJ/PriorTR)。本轮阅读摘要、方法概要和 Qwen3-VL 集成说明，未运行代码；结论按预印本证据处理。

PriorTR 认为原始 text-visual attention 混合了任务无关的模型先验和当前指令贡献。它用 null token 在同一次 forward 中估计 instruction-agnostic prior，再与 query-conditioned posterior 比较，以近似衡量每个视觉 token 因当前文本额外提供的可用信息。作者仓库包含 Qwen3-VL 的单次前向实现。

对安全任务，最有价值的是把“模型总会看的区域”与“安全政策使模型额外关注的区域”分开。但 null probe 是否能代表安全无条件先验、差分分数能否保护隐式危害关系，仍需本地验证。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]。
