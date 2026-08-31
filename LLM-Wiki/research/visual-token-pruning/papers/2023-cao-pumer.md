---
id: paper-note-cao-2023-pumer
type: paper-note
title: "PuMer: Pruning and Merging Tokens for Efficient Vision Language Models"
authors: ["Qingqing Cao", "Bhargavi Paranjape", "Hannaneh Hajishirzi"]
year: 2023
venue: "ACL 2023"
source_id: paper-cao-2023-pumer
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, token-merging, vision-language-model]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-31
---

# PuMer: Pruning and Merging Tokens for Efficient Vision Language Models

## 研究问题

如何利用图文相关性减少 cross-modal encoder 中的视觉与文本 token，同时避免纯删除的信息损失和跨模态直接合并造成的表示混淆？

## 问题场景与系统边界

- **用户输入：** 图像加一句 caption、问题或陈述；NLVR2 还使用一条文本和两幅图。输出覆盖图文检索、开放式 VQA、视觉蕴含和二分类推理。
- **任务特点：** 384/16 的图像可产生 576 个 patch，而文本通常只有十几个 token；视觉 token 数量严重不平衡，且“人数/运动类型”等不同问题会关注不同区域（§1，pp. 12889–12890）。
- **系统特点：** ViLT 把两模态 token 拼接进单流 Transformer；METER 先有独立 RoBERTa/CLIP 编码器，再用 12 层 cross-modal encoder。PuMer 只压缩融合阶段，因此收益取决于 cross-modal encoder 是否真是端到端瓶颈（§3、§5.1，pp. 12892–12895）。

## 方法与流程

PuMer 在多个 cross-modal layers 渐进插入无参数 token reducers：用文本指导视觉 token 剪枝，并分别在图像、文本模态内部合并相似 token；训练基本沿用下游微调，并加入知识蒸馏缩小精度差距（§4.1–§4.3）。它同时减少视觉与文本 token，是本调研中少见的联合模态压缩方案。

Token Importance Pruning 复用已有 text-to-image cross-attention，跨文本 token 和注意力头平均后保留视觉 Top-k；Modality-Aware Merging 则把图像和文本各自划为两组，按相似度做二分软匹配并平均合并，避免把不同模态直接混为一类。多个 reducer 分散插入形成渐进压缩（§4.1–§4.2，pp. 12893–12894）。

## 实验与直接证据

- 主干：ViLT-110M 与 METER-330M；任务：Flickr30K 检索、VQAv2、SNLI-VE、NLVR2。
- Table 1：METER 各任务 throughput 1.79–2.07×、峰值显存下降 38%–43%，绝对性能下降 0.5–0.9；ViLT 为 1.74–2.01×、显存下降 45%–51%，下降 0.4–0.7。
- Table 3：ViLT/VQAv2 从 69.5 降到 68.9，throughput 1.76×；移除文本指导或模态内合并会分别降低速度收益，表明两部分作用不同。
- Table 4：更早、更强压缩带来更高吞吐但更大精度损失；分散在多层的渐进策略更稳。
- Table 2 显示压缩与降分辨率可叠加：METER/VQAv2 从 384 输入的 77.5 出发，PuMer-384 为 76.8、1.82×；单纯 320 为 77.0、1.62×，PuMer-320 为 76.3、2.86×。这说明它并非只是在模拟降低输入分辨率（p. 12897）。
- Table 3 中去掉文本指导、合并或蒸馏分别改变性能—吞吐折中；Table 4 中 reducer 放在 2/3/4 层可到 2.03×但损失 1.8 点，放在 7/8/9 层仅 1.31×但损失 0.1 点，跨 2/4/6/8 层渐进配置为 2.01×、损失 0.4 点（pp. 12897–12898）。
- 吞吐协议并不统一：ViLT 在 GTX 1080 Ti、METER 在 A40 上，以 30 秒内最大 batch 测量；因此 1.74–2.07× 只能在各自主干内部解释，不能跨论文直接排名（§5.1，p. 12895）。

## 局限

作者指出：若 cross-modal encoder 本身较轻、主要成本在视觉编码器（如 ALBEF、X-VLM），只在融合层减 token 的端到端收益有限（§8）。方法针对编码式 VLM，不直接解决长自回归输出、multi-turn cache 或生成时相关性漂移。

对安全判别的启示是“政策相关视觉剪枝 + 模态内合并”具有直接可迁移性，但原论文没有视频时序、长政策、多标签漏报或解释生成；知识蒸馏也意味着其质量并非纯 training-free selector 的结果。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
