---
id: paper-note-jiang-2022-trips
type: paper-note
title: "TRIPS: Efficient Vision-and-Language Pre-training with Text-Relevant Image Patch Selection"
authors: ["Chaoya Jiang", "Haiyang Xu", "Chenliang Li", "Ming Yan", "Wei Ye", "Shikun Zhang", "Bin Bi", "Songfang Huang"]
year: 2022
venue: "EMNLP 2022"
source_id: paper-jiang-2022-trips
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, multimodal-pretraining]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-31
---

# TRIPS: Efficient Vision-and-Language Pre-training with Text-Relevant Image Patch Selection

## 收录与问题

早期“文本条件化视觉剪枝”代表：同一图像面对不同问题时，重要 patch 不同，纯视觉重要性不足以决定视觉语言任务的保留集合（§1，pp. 4084–4085）。

## 问题场景与系统边界

- **用户输入：** 图像—文本对。VQA 是图像加自然语言问题并生成答案；NLVR2 是一句陈述加两幅图像并做二分类；检索是图像—caption 双向匹配。
- **任务特点：** 输入文本在视觉编码前已经给定，且同一图像会因问题不同而需要不同区域。论文用“背景中的树/雪”等例子说明仅凭视觉 CLS 选择 patch 会忽略问题条件（§1，pp. 4084–4085）。
- **系统特点：** ALBEF 式双流 VLP：ViT 视觉编码器、BERT 文本编码器和 6 层跨模态融合器。成本同时来自长视觉序列在视觉塔中的自注意力，以及之后的跨模态融合；这不是 decoder-only、自回归或多轮系统（§3.1，pp. 4086–4087）。

## 核心方法与训练流程

在视觉编码器内部插入 text-guided patch-selection layers，以文本上下文计算 patch 相关性；保留高相关 token，并把低相关 token 融合成一个 token，而非全部硬删除。默认在 ViT 的第 5、10 层选择，每次 keep rate 70%。模型以 CLIP ViT-B/16 初始化，在 4M image-text pairs 上预训练 30 epochs，再按下游任务微调（§3–§4）。

具体地，文本 `[CLS]` 经与视觉自注意力共享的 query 投影后，对视觉 token 输出计算相关性；Top-k token 原样保留，其余 token 按注意力加权融合为一个 inattentive token。该选择器不增加参数，但依赖文本提前参与视觉主干，因此不是可随意外挂到所有视觉塔的后处理器（§3.2，pp. 4087–4088）。

## 任务、指标与结果

- VQA 被建模为答案生成；NLVR2 是二分类；另含 Flickr30K/MSCOCO 图文检索。
- Table 3 报告 TRIPS 为 20.89G FLOPs、343.05 image-text pairs/s、11ms；表内 ALBEF-C 为 36.63G、197.52/s、21ms。输入长度统一为 197 image patches + 40 text tokens。
- Table 4 显示剪枝越早/越强，吞吐越高但 VQA/NLVR2 下降；[5,10] 两层各保留 70% 是论文选择的折中。
- 同为 384 分辨率时，未剪模型为 76.03G FLOPs、79.32 pairs/s、VQA 76.12、NLVR2 82.35；TRIPS 为 55.60G、115.01 pairs/s、VQA 76.23、NLVR2 82.35。把省下的预算用于 456 分辨率后，在相近 74.83G 下 VQA/NLVR2 提升到 76.54/83.02（Tables 5–6，pp. 4090–4091）。
- 消融中，完整方法 VQA 为 76.23；去掉低相关 token 融合降至 75.92，去掉文本相关注意力降至 75.23，说明“按文本选”比“是否保留摘要”贡献更大，但两者均有价值（Table 7，p. 4091）。

## 局限与项目意义

作者明确指出仅用 4M 对预训练数据，扩展到更大数据规模的行为未知（§7）。TRIPS 说明多模态剪枝的选择信号应由文本条件化，但它需要在视觉骨干中提前获得文本指导，架构耦合度高，且不覆盖 decoder-only MLLM 的 KV cache 与多轮生成问题。

固定 keep rate 也不随样本风险或问题难度变化。对安全判别而言，它适合“本轮政策/问题在视觉编码前固定”的单轮审核，却没有验证短暂视频事件、OCR、小目标、低频危害或漏报不对称约束。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
