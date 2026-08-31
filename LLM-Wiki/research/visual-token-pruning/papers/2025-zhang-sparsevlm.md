---
id: paper-note-zhang-2025-sparsevlm
type: paper-note
title: "SparseVLM: Visual Token Sparsification for Efficient Vision-Language Model Inference"
authors: ["Yuan Zhang", "Chun-Kai Fan", "Junpeng Ma", "Wenzhao Zheng", "Tao Huang", "Kuan Cheng", "Denis A. Gudovskiy", "Tomoyuki Okuno", "Yohei Nakata", "Kurt Keutzer", "Shanghang Zhang"]
year: 2025
venue: "ICML 2025"
source_id: paper-zhang-2025-sparsevlm
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

# SparseVLM: Visual Token Sparsification for Efficient Vision-Language Model Inference

## 问题场景与系统边界

- **用户输入：** 单图或视频加自然语言问题；问题可能要求识别地标、读取药品/冰箱文字、计数、常识推理或视频时序理解（Figure 3，p. 5）。
- **任务特点：** 同一图像面对“标牌写什么”“有几辆车”“屋顶颜色”等问题时，相关视觉区域不同；但问题里介词、代词和模板词又不应拥有同等评分权（§3.2，pp. 3–5）。
- **系统特点：** 视觉塔与 projector 输出长视觉前缀，因果 LLM 在 prefill 中处理视觉与文本 token。SparseVLM 在多个 decoder layer 内渐进删除并回收 token，因此会节省后层 MHA/FFN/KV，但已经支付视觉塔和更浅层成本；还需兼容不显式返回注意力矩阵的 FlashAttention（§3.1、Appendix B）。

## 核心方法

SparseVLM 是 decoder 内部的 training-free 渐进压缩：先选出与视觉信号相关的文本 token 作为 raters，再复用视觉—文本 self-attention 为视觉 token 打分；以 attention matrix rank 自适应决定各层保留率，并把部分被删 token 聚类回收成紧凑表示（§3.1–§3.3）。

具体流程是：在进入 LLM 前，以视觉 embedding 与文本 embedding 的相似性高于均值者作为 raters；每层抽取 rater-query 到 visual-key 的子矩阵 $P$，用 $P$ 的行均值为视觉 token 排序，以 $N=\lambda(L_v-\operatorname{rank}(P))$ 决定本层删除量。删除池中得分较高的一部分再用 kNN density-peak 聚类，簇内求和重构为少量回收 token（Equations 2–10，pp. 3–5）。

## 实验与证据

- LLaVA、Qwen2-VL、Mini-Gemini、Video-LLaVA；八个图像 benchmark 与四个视频 QA benchmark。
- LLaVA 保留 192/576 token 时，综合相对性能 99.1%，FLOPs 4.62→2.14T，latency 57.82→36.50ms；保留 128 时为 96.7%、1.72T、33.28ms（Table 1）。
- Video-LLaVA 从 2048 减至 194 token：SparseVLM 平均 accuracy 相对值 95.0%，FastV 为 80.3%（Table 3）。
- 论文报告 37% CUDA latency 下降、仅 0.9% accuracy drop 的配置（摘要/§1）。
- 图像任务覆盖 GQA、MMBench、MME、POPE、ScienceQA、SEED-Bench、TextVQA、MM-Vet；LLaVA-1.5、Mini-Gemini 和动态分辨率 Qwen2-VL 验证架构泛化（§4.1，pp. 5–6）。
- LLaVA 保留 64/576 token 时 SparseVLM 综合相对性能仍为 89.3%，而 FastV 为 72.0%；但此时绝对指标差异很大，例如 POPE 77.5、MM-Vet 24.9，说明“综合相对值”会掩盖任务敏感性（Table 1，p. 6）。
- 回收消融在 GQA/POPE 的多个 token 预算上均改善；保留 64 token 时 POPE 从 72.8 提升到 77.5。文本 rater 相比使用全部 token 或全部文本，在 TextVQA/POPE 上分别显示小幅至 2.7 点的收益（Table 4、Figure 5，pp. 7–8）。
- 效率在单张 A100-80GB、相同文本长度和单图输入上测得；576→128 时 CUDA latency 57.82→33.28ms、FLOPs 4.62→1.72T、综合相对性能 96.7%，同时 KV cache 302.4→100.8MB（§5.3，p. 8）。

## 局限与反证

方法需访问或重构 decoder attention；论文为兼容 FlashAttention 设计了额外实现，实际 kernel 开销不可由 FLOPs直接推断。[[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-token-pruning-right-problem.md|Wen et al.]] 在统一复核中发现 SparseVLM 在部分普通 benchmark 与 RefCOCO 上弱于随机/池化，说明 text-guided attention 不是稳定的通用重要性估计器；但在 Visual Haystack 等强文本条件任务中，语言指导又确实必要。

其“自适应”是由注意力矩阵秩决定每层 token 数，不等价于风险校准或安全召回约束。多轮中 prompt 变化后，先前已删除并写入 cache 的视觉证据无法自然恢复；视频实验也仅用四个 QA benchmark，没有专门覆盖短暂危险事件。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
