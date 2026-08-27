---
id: visual-token-pruning-hypotheses
type: synthesis
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-zhan-2024-token-pruning-vssm, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding]
status: draft
created: 2026-08-24
updated: 2026-08-26
title: 视觉 Token 剪枝待验证假设
synthesis_kind: hypotheses
---

# 待验证假设

- H1（hypothesis）：在相同平均保留率下，“重要性 Top-K + 被删 token 向最近代表 token 聚合”会比纯删除更好地保持 ImageNet-A/C 与小目标性能。
- H2（hypothesis）：把 selector latency 和动态 shape/kernel 切换成本纳入 budget search 后，得到的层级保留率会显著不同于 FLOPs 约束下的 DiffRate 配置。
- H3（hypothesis）：batch=1 边缘推理中，动态样本级 token 数的方差会增加 P95 latency；分桶或量化到少量固定 budget 可在极小精度代价下降低尾延迟。
- H4（hypothesis）：位置保持是跨 ViT、视觉 SSM 通用化的必要条件，但不是充分条件；还需要匹配各主干的信息传播算子。
- H5（hypothesis）：多轮 VLM 中，“固定 text-agnostic coverage core + 每轮 query-conditioned delta”会比全 task-agnostic 或全 query-conditioned 选择在相同 KV budget 下更稳。
- H6（hypothesis）：把 spatial coverage/diversity 作为下限约束、再用 language relevance 排序，会在普通 VQA、Visual Haystack 与 RefCOCO 间获得更好的 worst-task performance。
- H7（hypothesis）：以 TTFT + 预期输出长度×decode-step cost 优化得到的 layer schedule，会显著不同于只约束 FLOPs 的 VisPCO 配置。
- H8（hypothesis）：高压缩导致的幻觉增量主要来自“关键视觉证据被删后语言先验接管”，而不是一般语言能力下降；通过可恢复 token summary 可部分缓解。
- H9（hypothesis）：多模态 Guard 的最优 Token budget 与主干 omission set 存在显著交互；独立选择两个预算会比联合 oracle 产生更高的 fixed-FPR 漏报或更差的时延。
- H10（hypothesis）：逐请求使用连续预算虽降低平均 FLOPs，却会因 execution signature 数量过多降低 GPU batch 效率；量化到少量二维 profile 能提高 P99 SLO goodput。
- H11（hypothesis）：安全类别、模态证据类型和政策长度比通用分类置信度更能预测 Guard 所需主干深度。
- H12（hypothesis）：以平均 F1 为约束的 SLO scheduler 会系统性牺牲稀有高风险组；加入 fixed-FPR 与 worst-group risk floor 后，资源分配会显著改变。
- H13（hypothesis）：同签名分桶与 deadline-aware profile coalescing 的收益在突发负载下高于静态 batch 或完全逐请求动态执行。
- H14（hypothesis）：风险分层的 shadow audit 可以用明显低于全量完整 Guard 的计算成本检测 profile 失配和分布漂移，同时维持可接受的发现延迟。

这些假设尚无本地实验支持，不进入来源陈述。
