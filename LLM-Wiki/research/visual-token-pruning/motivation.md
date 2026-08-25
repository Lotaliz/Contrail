---
id: visual-token-pruning-motivation
type: synthesis
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-zhan-2024-token-pruning-vssm, paper-cao-2023-pumer, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco]
status: active
created: 2026-08-24
updated: 2026-08-24
title: 面向精度保持与低时延的研究动机
synthesis_kind: motivation
---

# 研究动机

现有方法已经证明视觉 token 可大幅压缩，但“精度—FLOPs 最优”不能保证“精度—端到端时延最优”。至少两组独立证据支持这一动机：AS-ViT 显式比较吞吐与单图 latency，HeatViT 用实测 latency 表驱动训练；另一方面，STViT 和视觉 SSM 工作共同表明，简单删除会损失空间或序列结构信息，且这种损失在非标准主干或密集任务上更严重。

因此，一个有证据支持的研究方向是：在固定判别质量约束下，联合优化信息保真的 token 压缩策略与目标硬件的真实执行成本。目标函数应直接包含端到端 latency（最好含 P95）、选择器开销与能耗，并以精度下降上限而非单一 FLOPs budget 作为约束。

## 建议研究问题

能否用“轻量重要性 + 多样性聚合 + 架构位置约束”的统一选择器，在不同 ViT/视觉 SSM 主干上保持判别精度，并借助少量硬件 profiling 自动选择层位置和 token budget，使 batch=1 的 P95 推理时延稳定下降？

## 最小验证闭环

1. 主干：DeiT-S、一个较大 ViT/CLIP、一个视觉 SSM。
2. 基线：无压缩、ToMe、Zero-TPrune、AS-ViT/DiffRate；SSM 加 ToP-ViM。
3. 任务：ImageNet-1K + ImageNet-C/A（分类），可选 COCO 小目标子集。
4. 指标：Top-1/mAP、ECE、P50/P95 latency、throughput、peak memory、energy/image；分别报告 selector 与 backbone 时间。
5. 设备：至少一张服务器 GPU 与一类边缘 GPU/NPU；batch=1 为主，batch=8 作为吞吐对照。

## 图文多模态扩展动机

多模态证据表明，纯视觉“重要性 + 信息聚合 + 硬件成本”还不够：PuMer/SparseVLM 支持当前 query 相关性，VisionZip 揭示 multi-turn 中 query-conditioned cache 会失效；Wen et al. 与 DivPrune 又表明 attention importance 需要空间覆盖和多样性约束。另一方面，VisionZip、DivPrune、Wen et al. 共同显示 prefill/FLOPs 与端到端生成时延不同步。

因此，一个达到证据门槛的扩展方向是：**在 query relevance、task-agnostic coverage 与可恢复视觉摘要之间联合分配 token，并以 TTFT + decode + KV + P95 作为生成部署目标。**

### 多模态研究问题

能否构建“coverage core + query-conditioned delta”的两级视觉 token 集合：core 在多轮对话中稳定缓存，delta 根据当前问题和已生成前缀增量选择；同时用目标硬件 cost model 决定在 projector 前或 LLM 哪些层压缩？

### 多模态最小验证闭环

1. 模型：LLaVA-1.5/NeXT 与 Qwen2.5VL；可选一个 encoder-style VLM。
2. 基线：Random、Pooling、FastV、VisionZip、DivPrune、SparseVLM，以及固定/grid-search layer schedule。
3. 任务：VQAv2/MMBench、TextVQA、RefCOCO、POPE、Visual Haystack、multi-turn 与一个视频 QA。
4. 质量：accuracy/EM/CIDEr、grounding IoU、幻觉、输出长度与按类别失败率。
5. 系统：vision encode、TTFT、decode tokens/s、E2E P50/P95、KV/peak memory、selector 时间；固定 prompt/output length 对照。
