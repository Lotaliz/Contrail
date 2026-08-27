---
id: visual-token-pruning-motivation
type: synthesis
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-zhan-2024-token-pruning-vssm, paper-cao-2023-pumer, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding]
status: active
created: 2026-08-24
updated: 2026-08-26
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

## 面向 OSDI 的双自适应安全判别 Serving

### 场景约束

多模态 AI 服务常在目标模型调用前后执行安全判别。Guard 位于关键路径，既需要在突发、并发到达下满足 time-to-verdict SLO，又不能用普通平均 accuracy 换取高风险漏报。请求的图像分辨率、视频帧数、文本长度、政策数量和风险难度具有显著异质性，统一使用最大 Token 预算和完整主干会浪费计算。

### 已有方法的假设

SafeWatch 假设可按 policy relevance 剪视频 Token；PuDDing、Deja Vu 与 PowerInfer 分别证明可按输入改变主干深度或激活；Apparate、SuperServe 证明可在 serving 时按请求选择 early exit 或共享子网；Orca、Sarathi-Serve 与 Brainstorm 提供动态组批和动态网络执行机制。因而“增加 Token 剪枝、增加主干剪枝、支持 batch”本身是已有技术组合，不足以构成 OSDI 动机。

### 可测缺口

两个自适应维度共同形成二维 execution signature：序列预算改变 GEMM 形状和 KV/激活规模，主干预算改变 kernel 序列与权重访问。逐请求最优路径可能把一个 dense batch 碎裂为许多小批次，使选择器节省被 padding、分桶等待、kernel launch 和低 occupancy 抵消。同时，Token 删除会改变后续层的安全可分性，使两个预算在质量上也可能非独立。现有代表工作没有同时以 Guard 的 fixed-FPR/worst-risk 约束、二维动态执行和真实并发 SLO 为优化对象。

### 研究问题

能否构建一个 **risk- and SLO-aware elastic Guard serving system**：以少量可执行二维 profile 表达 Token 与主干预算；在请求风险、证据覆盖、deadline slack 和队列状态之间联合决策；通过 execution-signature-aware batching 保持 GPU 利用率；并在风险下界不足或分布漂移时恢复 Token、升级路径或回退完整 Guard？

### OSDI 投稿判断

课题方向合适，但当前三模块表述仍偏算法拼接。达到 OSDI 标准的最小主线应是：

1. **新抽象或机制：** 双维弹性 Guard profile，以及 profile 间可恢复/升级的执行语义。
2. **核心系统难题：** 在动态 shape 与动态 path 并存时维持高效 batch、kernel/graph 复用和低 P99。
3. **在线策略：** 风险约束优先、SLO 次之、资源效率再次之；不能用平均准确率补偿安全漏报。
4. **完整实现：** 接入主流推理引擎，至少在服务器 GPU 上实现真实 kernel/runtime 路径，而非离线模拟调度。
5. **端到端证据：** 真实或公开到达 trace、突发负载、模态/风险混合、分布漂移；比较 dense Guard、静态压缩、独立自适应、SafeRoute/SuperServe-style routing 和动态网络 runtime 基线。

### 贡献边界

- 若主干模块只是离线生成若干剪枝模型，再按置信度路由，更像 SuperServe/SafeRoute 的 Guard 应用。
- 若只报告单请求 latency/FLOPs，不解决批次碎片化和 P99，难以达到 OSDI。
- 若为适配 Guard 发明复杂剪枝训练，但系统机制较弱，更适合 MLSys/ICML。
- 若证明二维质量—成本面非可分，并用新的 runtime/scheduler 在风险约束下显著提高 SLO goodput，则具备较强 OSDI 叙事。
