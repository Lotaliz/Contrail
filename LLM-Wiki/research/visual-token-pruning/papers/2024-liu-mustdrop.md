---
id: note-2024-liu-mustdrop
type: paper-note
title: "Multi-Stage Vision Token Dropping: Towards Efficient Multimodal Large Language Model"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-liu-2024-mustdrop
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-16
---

来源：[arXiv v1](https://arxiv.org/html/2411.10803v1)，2024-11-16；本轮核 Local Spatial Merging、§4、Table 3，未复现或下载原件；未独立确认正式发表 venue。

## 原文方法与执行位置

Local Spatial Merging（LSM）在 ViT 第 1 层执行，划分局部窗口，对高相似邻近 tokens 取加权平均合并；关键视觉 token 集在后续阶段受保护。之后 prefill 以双注意力估计文本相关性，decode 以 output-aware cache policy 压缩 KV。视觉早阶段是合并，后续才有纯剪枝，不宜称 ViT 第 1 层直接 drop。

## 生成式证据与数据

LLaVA-1.5-7B、LLaVA-NeXT-7B、Video-LLaVA；图像/视频问答。Table 3 的 TextVQA encoder-only 消融：576→平均 440，准确率 58.2→58.3，KV cache 302.4→231.0 MB。摘要的 88.5% FLOPs 下降及 92.2% compression 属于完整三阶段方案，不是 ViT 单阶段。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。

