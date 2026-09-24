---
id: note-2026-han-ficoco
type: paper-note
title: "Filter, Correlate, Compress: Training-Free Token Reduction for MLLM Acceleration"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-han-2026-ficoco
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-16
---

来源：[arXiv v3](https://arxiv.org/html/2411.17686v3)；[AAAI 2026 正式 PDF](https://ojs.aaai.org/index.php/AAAI/article/download/42460/46421)。2024-11 首发，当前标题与正式 venue 已核；正文机制及数字采用 arXiv v3，注册作者仅第一作者，完整名单见正式稿。本轮核 §3、§7、Table 1，未复现或下载原件。

## 原文方法与执行位置

FiCoCo-V 作用于视觉 encoder；FiCoCo-L 作用于 LLM，必须分别介绍。V 版从视觉第 12 层开始压缩，以视觉可替代性与 CLS 语义重要性综合冗余评分，局部窗口 penalty 避免集中丢失，筛除冗余 token。随后按 attention 关联到保留 token，阈值控制 token-adaptive、多对多信息回灌，并维持保留 token 的主导表示。真实减少视觉 encoder 后续计算，属于剪枝—合并混合，免训练。

## 生成式证据与数字

LLaVA-1.5-7B/13B、LLaVA-NeXT-7B 和 Video-LLaVA 等生成式图像/视频问答。Table 1 的 FiCoCo-V：LLaVA-1.5-7B 基线 8.5 TFLOPs、平均 70.3；3.3 TFLOPs 时平均 66.9，六项相对性能平均 95.2%；1.5 TFLOPs 时平均 65.2，相对 92.7%。GPU 为 A800 80GB（§7）。正文对 FiCoCo 系列最高 5.7×/14.7× FLOPs 和 92.8%/93.6% 保持率不能无条件归给 encoder-only 的 V 版；FLOPs 也不是实测 latency。

## 边界

不依赖文本 query 的视觉 V 版并不自动保证问题相关小区域保留；信息回灌可能产生语义污染，作者用保留 token 主导和关联阈值约束。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。
