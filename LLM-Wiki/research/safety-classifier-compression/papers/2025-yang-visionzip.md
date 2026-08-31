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
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, training-free, efficient-inference]
status: active
related: [multimodal-token-pruning, visual-token-pruning]
created: 2026-08-24
updated: 2026-08-31
---

# VisionZip: Longer is Better but Not Necessary in Vision Language Models

## 问题场景与系统边界

- **用户输入：** 单图、多帧视频或多轮图像对话，加自然语言问题；输出是 VQA、caption、推理或连续多轮回答。
- **任务特点：** LLaVA-1.5 每图 576 token，LLaVA-NeXT 把高分辨率图像拆为四块加全图，达到 2880 token；视频再按帧累积。现实系统还希望上一轮视觉 KV cache 能服务下一轮不同问题（§1、§2.5，pp. 19792–19795）。
- **系统特点：** 压缩发生在视觉编码器输出与 projector/LLM 之间。视觉塔仍以原始分辨率处理全部 patch，但 LLM 从第一层起只看到压缩后的视觉序列，因此可减少完整 prefill、KV cache 和 decode 相关成本；selector 与当前文本完全解耦（Figure 3、§2.3）。

## 研究问题与方法

论文针对 CLIP/SigLIP 输出的大量冗余视觉 token，在进入 LLM **之前**进行压缩：按视觉编码器内部 attention 选择 dominant tokens，再把剩余 token 依据 key 相似性合并成 contextual tokens（§2.2–§2.3）。方法不依赖当前文本，可完全免训练；可选地用少量数据仅微调 projector 30 分钟以适配更短视觉序列（§2.4）。

CLIP 有 `[CLS]` 时，以第二末层 `[CLS]` 对 patch 的注意力挑 dominant tokens；SigLIP 没有 `[CLS]` 时，改用各 token 接收到的平均注意力。对非 dominant token 均匀划分 target/merge 两组，以视觉 key 点积寻找最近 target 并做均值合并，产生 contextual tokens（Algorithms 1–2，pp. 19793–19795）。

## 训练/推理与任务

推理时视觉编码器仍处理原分辨率，压缩发生在 projector/LLM 接口，因此主要减少 LLM prefill、KV cache 与后续生成成本，不减少视觉编码器前向。评估覆盖 LLaVA-1.5、LLaVA-NeXT、Mini-Gemini 的 11 个图像 benchmark、视频理解和多轮对话。

## 主要证据

- LLaVA-1.5 原有 576 视觉 token；论文报告约 10% token 时仍接近 95% 综合性能（Fig. 1；Table 1）。
- 更精确地，免训练 VisionZip 在 192/128/64 token 下为原模型综合相对性能 98.5%/97.6%/94.0%；仅微调 projector 后为 99.1%/98.4%/95.2%。11 项任务含 GQA、MMBench、MME、POPE、ScienceQA、VQAv2、TextVQA、MMMU、SEED、MM-Vet、LLaVA-Bench（Table 1，p. 19796）。
- LLaVA-NeXT 从 2880 压到 640/320/160 token，免训练分别保留 97.6%/95.0%/92.0% 综合相对性能；projector 微调后为 98.9%/97.9%/95.5%（Table 2，p. 19797）。
- Video-LLaVA 将 8 帧、每帧 256 token 的 2048 token 压到 136，在 TGIF/MSVD/MSRVTT/ActivityNet 四项平均保留 93.2%，SparseVLM 为 86.5%、FastV 为 52.1%（Table 3，p. 19797）。
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

此外，作者关于 softmax 使信息集中到少数 proxy token 的解释属于机制假说，论文提供可视化与干预实验，但没有因果证明。高压缩后的综合均值也不能替代逐风险类别最坏情况结果。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|图文多模态调研]]
