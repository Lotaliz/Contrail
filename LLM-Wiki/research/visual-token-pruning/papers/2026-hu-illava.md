---
id: note-2026-hu-illava
type: paper-note
title: "iLLaVA: An Image is Worth Fewer Than 1/3 Input Tokens in Large Multimodal Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-hu-2026-illava
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-16
---

来源：[arXiv v2](https://arxiv.org/html/2412.06263v2)；[ICLR 官方 proceedings](https://proceedings.iclr.cc/paper_files/paper/2026/hash/77c87a15bbf0aad017c53995b832cf84-Abstract-Conference.html)。2024-12 首发，v2 为 2026-03；本轮核 §3.2、§4、Figure 2，未复现或下载原件。

## 原文方法与执行位置

在若干视觉 block 的 MHA 与 FFN 之间 Token_Merge，使本层 FFN 和后续视觉 blocks 处理更短序列（§3.2.1，Eq.1）。后续另在若干 LLM blocks 之后合并。Attention 衡量重要性，回收被移除 token 的有用信息。训练免费；属于 token merging，不是直接丢弃的 pure pruning。

## 生成式模型与结果

v2 评测 Qwen2.5-VL、InternVL2.5、MiniCPM-V2.6、LLaVA-OneVision 的图像/视频理解与问答，均有自回归文本输出。Qwen2.5-VL-7B 视频压缩约 90%/95% 时，Table 2 平均相对性能 97.8%/96.8%。摘要报告联合方案最高 2× throughput 和 4× prefill 加速；这些最大值不能视为仅在 ViT 合并的收益或绑定到 Table 2 每一工作点。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。

