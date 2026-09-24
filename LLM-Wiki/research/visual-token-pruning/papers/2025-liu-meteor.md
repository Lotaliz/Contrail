---
id: note-2025-liu-meteor
type: paper-note
title: "METEOR: Multi-Encoder Collaborative Token Pruning for Efficient Vision Language Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-liu-2025-meteor
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-16
---

来源：[arXiv v1](https://arxiv.org/html/2507.20842v1)；[ICCV 官方论文](https://openaccess.thecvf.com/content/ICCV2025/papers/Liu_METEOR_Multi-Encoder_Collaborative_Token_Pruning_for_Efficient_Vision_Language_Models_ICCV_2025_paper.pdf)。本轮核 §3.2、§4.1、Tables 2/3；未复现或下载原件。

## 原文方法与执行位置

Stage 1 在每个视觉编码器多个 block 输出后渐进 gather/top-k，序列随后缩短。均分三个深度阶段，浅阶段按与平均 token 的相似性识别冗余，后两阶段按 class attention 保留重要 token（§3.2）。以 feature-map rank 衡量信息丰富度，离线小批量估计 rank，分配各编码器 token 预算。Stage 2 在独立 projector 之后消除跨 encoder 互冗余；Stage 3 在 LLM 中按文本注意力与实例复杂度继续剪枝。不要混淆各阶段的文本条件性。

## 生成式模型与训练

EAGLE 设置，Vicuna-v1.5-7B 或 Llama3-8B；CLIP、ConvNeXt、Pix2Struct、EVA-02 多塔。558K 预训练中使用编码阶段剪枝、仅更新 projector；随后 1M/1.8M SFT 微调整体模型。仅 Stage 3 的实例自适应剪枝宣称免训练（§4.1），整体方法不是不改权重的外挂。

## 代表结果与边界

Table 2 同数据的 EAGLE 复现于 Ascend 910B：tokens 1024→平均 242，TFLOPs 26.21→13.42，throughput 0.81→1.18（46% 提升），11 项平均 69.3→69.0，绝对下降 0.3 点。是三阶段整体结果，不能归因给 encoder-only，也不能与 A100 数据直接排名。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。

