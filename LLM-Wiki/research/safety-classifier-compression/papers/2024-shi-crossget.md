---
id: paper-note-shi-2024-crossget
type: paper-note
title: "CrossGET: Cross-Guided Ensemble of Tokens for Accelerating Vision-Language Transformers"
tags: [paper-note, research, vision-language-model, token-merging, efficient-inference]
source_id: paper-shi-2024-crossget
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# CrossGET

来源：[ICML 2024 / PMLR 官方页](https://proceedings.mlr.press/v235/shi24e.html)。本轮阅读摘要、方法图、方法正文和官方实验概览，未运行代码。

## 方法与直接证据

CrossGET 在视觉和语言分支中都加入 cross token，令它们在另一模态尚未完整执行时充当跨模态代理；随后以 cross-token importance 与模态内 token 相似度共同决定匹配和加权合并。该设计既适用于 CLIP 式并行双塔，也适用于 BLIP2/LLaVA 式有计算顺序依赖的架构。作者在检索、视觉推理、caption 和 VQA 上报告加速且性能下降较小。

## 对安全判别的边界

它证明双向跨模态指导和两支 token reduction 已有正式先例，但核心操作是 token ensemble，不是安全损失下的视觉/文本预算联合分配。实验未覆盖政策文本、混淆提示、固定 FPR、危害长尾或压缩诱发漏报；cross token 也会增加训练与结构依赖。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。
