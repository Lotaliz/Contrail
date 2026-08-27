---
id: visual-token-pruning-landscape
type: synthesis
title: 视觉 Token 剪枝技术路线图
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding]
status: active
created: 2026-08-24
updated: 2026-08-26
---

# 技术路线图

## 1. 重要性驱动的直接剪枝

AS-ViT 使用多头重要性加权的 class attention 和可学习阈值，按样本决定保留量；Zero-TPrune 用注意力图上的 Weighted PageRank 结合相似性，避免额外微调；V-Pruner 进一步把跨层选择作为全局序列决策。路线演化是“固定 Top-K → 动态阈值 → 全局长期收益”。

## 2. 剪枝与信息聚合协同

ToMe 合并相似 token 而不是丢弃；STViT 把大量 patch 聚合为少量语义 token；DiffRate 同时学习每层剪枝率和合并率。共同出发点是：高压缩率下，完全删除会产生不可逆信息损失，聚合可保留背景或细粒度线索。

## 3. 预算可变与部署后适配

DiffRate 在离线优化时学习层级预算；ToCom 用小型补偿插件缓解训练压缩率与推理压缩率不一致；TCA 将 token 凝聚与域锚点、logit correction 结合，使压缩兼具测试时适应作用。这条路线面向负载变化、多个端侧预算和分布偏移。

## 4. 架构感知剪枝

视觉 SSM 的 token 顺序进入扫描状态递推，不能照搬 ViT 的删除与重新编号。NeurIPS 2024 工作通过 pruning-aware hidden-state alignment 保持位置间隔，说明 token 选择必须尊重主干的信息流拓扑。

## 5. 硬件/系统感知剪枝

HeatViT 在目标 FPGA 上建立 token keep ratio 到 block latency 的查找表，再以 latency-sparsity loss 选择插入层和保留率，并用选择器复用原有 GEMM 数据通路。它说明动态稀疏只有在算子、内存访问与控制流共同支持时才稳定转化为时延收益。

## 6. 文本条件化的跨模态选择

TRIPS 在视觉编码器内用文本指导 patch selection；PuMer 在 cross-modal layers 进行文本指导视觉 pruning，并分别合并图像/文本 token；FastV、SparseVLM 则复用 decoder 内图文 attention。新约束是同一图像的最优保留集随 prompt 改变。

## 7. LLM 前的覆盖/多样性压缩

VisionZip 选择视觉编码器的 dominant tokens 并合并上下文，DivPrune 最大化保留集合多样性。两者不依赖当前文本，适合 prefill 前一次压缩与 multi-turn 复用；代价是可能不够贴合单一 query。

## 8. 生成阶段与 KV 生命周期

decoder-only VLM 的收益分为视觉编码、prefill/TTFT、decode 与 KV cache。LLM 前压缩可缩短整段生成；LLM 中层压缩先支付浅层成本但可利用跨模态相关性。现有工作尚未统一解决“未来生成相关性未知”和新一轮问题到来后的视觉证据取回。

## 9. 配置搜索与评测反思

VisPCO 把层位置/保留率建模为 Pareto configuration；Wen et al. 则显示 random/pooling、空间均匀性和真实 latency 是不可省略的基线。路线已从“谁的 attention score 更好”转向“重要性 + 冗余/覆盖 + 层预算 + 系统成本”。

## 10. 输入相关的主干稀疏与深度路由

Deja Vu 在线预测 attention head/MLP contextual sparsity；PowerInfer 将热/冷神经元分布落实为 CPU-GPU 放置与稀疏算子；PuDDing 则按 prompt 从 Transformer block omission sets 中选择路径。三者说明“按任务剪 LLM 主干”已有算法和系统先例。对 Guard 而言，需要重新定义选择信号为风险难度、策略类别和多模态证据充分性，并验证这些信号是否真能预测安全判别所需深度。

## 11. 动态网络执行抽象

OSDI'23 Brainstorm 用 Cell 与 Router 表达 sub-tensor 粒度的动态分发，并按运行时动态分布专门化执行。双自适应 Guard 同时改变序列维和模型路径维，属于它覆盖的广义动态网络问题。新的系统必须在 Guard 场景中提出更具体的 execution signature、算子或批处理机制，而不能把 Python 层 mask 与 padding 当作完成的 runtime。

## 12. SLO 感知的可变模型 Serving

SOSP'24 Apparate 已支持请求级 early exit、持续质量反馈与在线阈值调整；NSDI'25 SuperServe 已支持权重共享子网的快速激活和基于 slack 的调度；SafeRoute 则在小/大 Guard 间路由。它们把当前课题的竞争焦点推向：Token 与主干预算的耦合、安全风险约束、二维异构批次，以及无法继续完整执行所有请求时的低成本审计与回退。

## 13. 连续批处理与异构工作量整形

Orca 的 iteration-level scheduling、Sarathi-Serve 的 chunked-prefill 与 uniform batch 表明，批内工作量差异会直接转化为排队、stall 与尾延迟。双自适应 Guard 需要将 `(token bucket, layer/subnet profile)` 作为执行签名：同签名请求形成高效 dense batch，临近 deadline 的请求可升级、降级或单独发射；但任何降级都必须先满足风险下限。

## 综合判断

精度保持需要“重要性 + 多样性/聚合 + 架构约束”；多模态还需加入“当前查询 + 未来生成/多轮可复用性”。时延缩短需要“规则张量形状或高效动态执行 + 目标硬件测量”，生成任务必须拆分 TTFT、decode 与 KV。对双自适应 Guard，系统核心进一步变为“风险约束下的二维 profile 选择 + execution-signature-aware batching + 安全回退”。单独优化任何一侧都可能出现 FLOPs 降低但时延不降，或平均精度稳定但高风险请求漏检。
