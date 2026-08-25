---
id: paper-note-yang-2025-visionzip
type: paper-note
title: "VisionZip: Longer is Better but Not Necessary in Vision Language Models"
authors: ["Senqiao Yang", "Yukang Chen", "Zhuotao Tian", "Chengyao Wang", "Jingyao Li", "Bei Yu", "Jiaya Jia"]
year: 2025
venue: "CVPR 2025"
source_id: paper-yang-2025-visionzip
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, method]
status: active
related: [multimodal-token-pruning, visual-token-pruning]
created: 2026-08-24
updated: 2026-08-24
---

# VisionZip: Longer is Better but Not Necessary in Vision Language Models

## 研究问题与方法

论文针对 CLIP/SigLIP 输出的大量冗余视觉 token，在进入 LLM **之前**进行压缩：按视觉编码器内部 attention 选择 dominant tokens，再把剩余 token 依据 key 相似性合并成 contextual tokens（§2.2–§2.3）。方法不依赖当前文本，可完全免训练；可选地用少量数据仅微调 projector 30 分钟以适配更短视觉序列（§2.4）。

## 训练/推理与任务

推理时视觉编码器仍处理原分辨率，压缩发生在 projector/LLM 接口，因此主要减少 LLM prefill、KV cache 与后续生成成本，不减少视觉编码器前向。评估覆盖 LLaVA-1.5、LLaVA-NeXT、Mini-Gemini 的 11 个图像 benchmark、视频理解和多轮对话。

## 主要证据

- LLaVA-1.5 原有 576 视觉 token；论文报告约 10% token 时仍接近 95% 综合性能（Fig. 1；Table 1）。
- LLaVA-NeXT 7B 从 2880 减到 160 token：POPE 总时间 2293s→756s（约 3×），prefill 218ms→27.8ms（7.8×）（Table 4）。
- 对 TextVQA，先去掉视觉编码器高 attention token 再让 SparseVLM 选 64 token，得分 51.1→46.4；先用 VisionZip 保留 128 再压到 64，升至 52.5（Table 5）。这支持“LLM 文本相关性未必与视觉编码器的信息聚合位置一致”。

## 关键挑战与失败条件

论文明确指出：文本条件化方法把与上一轮问题相关的视觉 token 缓存在 KV 中，后续问题改变时可能缺少新证据；VisionZip 用 text-agnostic 选择缓解 multi-turn 相关性漂移（§4.3）。反过来，完全 task-agnostic 的选择也可能在需要特定局部证据时保留不足；论文平均 benchmark 不能排除这一风险。

## 作者主张与本文判断

- 作者主张：视觉编码器已把信息集中到少量代理 token，dominant selection + merging 可高压缩且适用于多轮。
- 本文判断：它揭示了“视觉侧信息密度”与“问题条件化相关性”是两个不同目标；多模态剪枝不能只最大化其中一个。
- 未复现：8× prefill 与 3×总时间依赖 A800、POPE、具体 token 配置，需在统一硬件验证。

## 安全分类边界

核心任务是通用 VLM 理解而非安全分类；对 OCR、小目标、隐蔽符号和组合危害的召回没有直接证据。text-agnostic coverage 可能利于多轮复用，但不保证保留稀有安全证据。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|图文多模态调研]]
