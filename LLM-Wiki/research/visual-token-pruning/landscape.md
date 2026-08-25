---
id: visual-token-pruning-landscape
type: synthesis
title: 视觉 Token 剪枝技术路线图
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco]
status: active
created: 2026-08-24
updated: 2026-08-24
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

## 综合判断

精度保持需要“重要性 + 多样性/聚合 + 架构约束”；多模态还需加入“当前查询 + 未来生成/多轮可复用性”。时延缩短需要“规则张量形状或高效动态执行 + 目标硬件测量”，生成任务必须拆分 TTFT、decode 与 KV。单独优化任何一侧都可能出现 FLOPs 降低但时延不降，或平均精度稳定但定位/OCR/事实性失效。
