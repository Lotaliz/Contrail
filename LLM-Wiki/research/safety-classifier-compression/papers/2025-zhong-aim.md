---
id: paper-note-zhong-2025-aim
type: paper-note
title: "AIM: Adaptive Inference of Multi-Modal LLMs via Token Merging and Pruning"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-zhong-2025-aim
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# AIM

来源：[ICCV 2025 官方页面](https://openaccess.thecvf.com/content/ICCV2025/html/Zhong_AIM_Adaptive_Inference_of_Multi-Modal_LLMs_via_Token_Merging_and_ICCV_2025_paper.html)。本轮阅读摘要、方法、层行为分析与文本 token 消融，未运行代码。

## 方法与直接证据

AIM 面向视觉 token 与文本 token 拼接后送入同一 LLM 的图像/视频 MLLM。它先在 LLM 前按视觉 embedding 相似度迭代合并视觉 token，再在 LLM 层间根据多模态 attention/PageRank importance 渐进删除视觉 token。方法 training-free；作者在 LLaVA-OneVision 与 LLaVA-1.5 上报告约 7 倍 FLOPs 降低并维持接近原模型的性能。

## 文本 token 反证

AIM 明确保留全部文本 token。论文的文本 token 剪枝消融使 VideoMME 从 58.2 降至 45.7；作者据此判断，中后层的文本中心推理对这些 token 依赖较强。这个结果不是安全 Guard 专属证明，但它来自与当前目标同构的 decoder-only MLLM，是反对“图文统一 Top-k”的强直接证据。

## 对当前场景的边界

AIM 没有测安全分类、固定 FPR 或归因忠实度，也没有覆盖 Qwen3-VL；其视觉剪枝仍可作为同构基线，文本消融则应被复现为负对照，而非默认组件。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。

