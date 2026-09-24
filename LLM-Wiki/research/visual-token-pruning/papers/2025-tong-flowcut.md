---
id: note-2025-tong-flowcut
type: paper-note
title: "FlowCut: Rethinking Redundancy via Information Flow for Efficient Vision-Language Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-tong-2025-flowcut
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-16
---

来源：[arXiv v3](https://arxiv.org/html/2505.19536v3)；[NeurIPS 官方题录](https://proceedings.nips.cc/paper_files/paper/2025/hash/88441fee0c0dacceb95e4ad77ece5d0a-Abstract-Conference.html)。本轮核 §2–4、Tables 1/5、附录 A.4–A.5；未复现或下载原件。

## 原文方法与执行位置

每两层执行剪枝（§3.3），在视觉 encoder 内真实缩短序列。注意力熵控制预算；token 评分综合 class/global attention、与全局 Value 的语义相似性和 Value 的 L1 范数，并累计历史重要性，避免单层噪声。LLaVA-1.5 在视觉倒数第二层完成；LLaVA-NeXT/Qwen2-VL 在 encoder 先剪到最终目标的两倍，再在 LLM 第 2 层完成（§4）。这是纯剪枝，不是平均融合。

## 生成式证据与数据

评测 LLaVA-1.5-7B、LLaVA-NeXT-7B、Qwen2-VL 和 Video-LLaVA 的图像/视频问答。LLaVA-1.5 576→64 后 12 项相对性能平均 96.0%（Table 1），并非绝对准确率。单 A800/POPE：prefill 102→62.6 ms；整套总运行 17:05→11:17，作者记 1.6×/1.5×（Table 5）。NeXT 的 3.2× prefill 与 3.0× total 包含 LLM 第 2 层剪枝，不能视为视觉单阶段收益。

## 判断与边界

信息流、entropy、累计分数和频率消融提供机制解释，但是 attention/Value 代理，不是所选 token 对答案因果充分性的证明。Appendix A.5 称仅需 class/global 单行 attention，与 FlashAttention 可兼容；实机实现收益未核。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。

