---
id: paper-note-chen-2024-fastv
type: paper-note
title: "An Image is Worth 1/2 Tokens After Layer 2: Plug-and-Play Inference Acceleration for Large Vision-Language Models"
authors: ["Liang Chen", "Haozhe Zhao", "Tianyu Liu", "Shuai Bai", "Junyang Lin", "Chang Zhou", "Baobao Chang"]
year: 2024
venue: "ECCV 2024"
source_id: paper-chen-2024-fastv
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, training-free, efficient-inference]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-31
---

# An Image is Worth 1/2 Tokens After Layer 2

## 问题与观察

FastV 观察到 decoder-only LVLM 深层对视觉 token 的平均注意力远低于系统/文本 token，并据此提出：先让浅层吸收视觉信息，再在某一 LLM 层之后删除低分视觉 token（§3–§4）。

## 问题场景与系统边界

- **用户输入：** 一幅图或多帧视频、system prompt、用户问题/指令；模型随后自回归生成 caption、短答案或开放式回答。
- **任务特点：** LLaVA-1.5 的 336 分辨率图像产生 576 个视觉 token，672 分辨率可到 2304；Video-LLaVA 使用 2048 个视频 token。视觉前缀占输入大头，但输出长度与任务跨度很大（§1，pp. 1–2）。
- **系统特点：** CLIP/投影器先生成视觉 token，再与文本前缀拼接进入因果 LLM。FastV 在 LLM 浅层后才删 token，因此视觉塔和前 K 个 LLM block 的成本已经发生；收益集中在后续 MHA、MLP 与 KV cache（§4，pp. 7–9）。
- **观察依据：** 论文从 Flickr30K、PCA-Bench、A-OKVQA、MMMU 各抽样图文对，发现视觉 token 占输入约 64%，但深层 attention efficiency 显著低于 system prompt；作者据此提出浅层已将视觉信息汇入少量 anchor token 的假设（§3，pp. 4–7）。

## 方法

在过滤层 $K$，按 token 接收到的平均 attention score 排序，删除末尾 $R\%$ 视觉 token，后续 MHA 与 FFN 均不再处理它们；无需训练，可配置过滤层与比例（§4.1）。

## 任务与证据

- 模型：LLaVA-1.5-7B/13B、QwenVL-Chat、Video-LLaVA。
- 任务覆盖 captioning（NoCaps、Flickr30K）、A-OKVQA/MMMU、OCR-VQA、MME/MMVet/SEED、视频 QA。
- Table 1：LLaVA-1.5-13B 在 layer 2 后删 50% 视觉 token，FLOPs 约为基线 55%，四任务平均分 73.6，与基线相同；删 75% 或 90% 时，生成式 captioning 指标更早下降。
- Table 4 报告真实推理预算，说明理论 FLOPs 可转化为部分 latency 收益，但测量范围有限。
- Table 1 的代表点：LLaVA-1.5-7B 为 99.3→54.6B FLOPs、综合相对质量 69.8→69.7；13B 为 154.6→84.6B、73.6→73.6；Qwen-VL-Chat 为 71.9→39.5B、69.7→69.2（过滤层 2，删除 50%）。
- Table 4 在单张 A40、A-OKVQA、batch=1 上使用 layer 0 随机删 50% 的计时：7B 延迟 0.344→0.230s、显存 19→16GB、得分 76.7→75.3；13B 为 0.539→0.341s、38→30GB、82.0→80.5。这里不是 FastV attention selector 的标准 K=2 配置，不能把时间点与 Table 1 的质量点直接拼接（pp. 11–12）。
- Table 7 显示专门用 50% 视觉 token 训练的模型并未优于推理时 FastV；剪 system/instruction token 会严重损伤性能。InstructBLIP 因 Q-Former 已经压缩视觉表示而更敏感，需要把过滤层推迟到 layer 5（§5，pp. 12–14）。

## 边界与后续反证

FastV 的 attention-based 排名后来被 [[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-token-pruning-right-problem.md|Wen et al.]] 发现存在明显空间位置偏置，在高压缩和 RefCOCO 定位上可弱于随机/池化。FastV 仍是重要的 training-free 基线，但不能把平均 benchmark 保持解释为视觉证据完整保留。

它还不适合直接处理“下一轮用户问题改变”的 cache 复用：保留集由当前浅层注意力决定。对安全判别，平均分稳定不能替代危险类别召回、短暂事件覆盖、OCR/小目标以及 fixed-FPR 下的漏报率。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
