---
id: visual-token-pruning-gaps
type: synthesis
title: 视觉 Token 剪枝证据缺口
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-zhan-2024-token-pruning-vssm, paper-yao-2026-v-pruner]
status: active
created: 2026-08-24
updated: 2026-08-24
---

# 证据缺口

## G1：缺少统一、端到端、低 batch 的时延评测（满足 Motivation 门槛）

- 支持：AS-ViT 同时给出 batch=64 吞吐与 batch=1 单图时延，已显示不同动态方法的排序可能变化；HeatViT 直接用目标硬件 latency LUT 优化，并将剪枝加速与量化加速拆分。
- 反证：Zero-TPrune、DiffRate 等确实报告 GPU throughput，因此并非完全没有真实速度证据。
- 边界：只针对“落地时延”结论；算法层精度—FLOPs 比较仍有价值。
- 待验证：相同实现、相同 kernel、batch=1/8、不同 GPU/CPU/NPU 上，选择器、排序、padding 和数据搬运各占多少？

## G2：精度保持仍偏重平均分类指标（满足 Motivation 门槛）

- 支持：STViT 需要恢复空间细节才能服务检测/分割；视觉 SSM 论文显示不保留结构位置会出现灾难性下降；TCA 表明分布偏移下 token 选择会改变分类表现。
- 反证：部分论文已覆盖检测、分割、视频和细粒度分类，不是只测 ImageNet。
- 边界：不能据此断言所有剪枝都会伤害长尾或局部小目标。
- 待验证：在 ImageNet-A/R/C、细粒度数据、小目标检测和置信度校准上，平均精度相同的模型是否具有相同失败分布？

## G3：预算搜索尚未与跨硬件性能模型统一（候选缺口）

- 支持：DiffRate 学习的是可微计算率，HeatViT 学习的是特定 FPGA latency，V-Pruner 引入全局序列决策；三者优化目标不统一。
- 反证：目标设备固定时，硬件专用 LUT 已能有效工作。
- 边界：跨设备通用预算未必必要，生产系统也可每设备校准。
- 待验证：少量 profile 能否建立可迁移 cost model，同时预测 P50/P95 latency、能耗和显存？

## G4：动态选择器的收益阈值不明确（候选缺口）

- 支持：Zero-TPrune 的图排序、V-Pruner 的策略、动态阈值都引入固定成本；HeatViT 通过复用硬件组件减少该成本。
- 反证：在大模型或高分辨率下，后续 block 的节省可以显著超过选择开销。
- 边界：阈值强依赖 token 数、batch、编译器和设备。
- 待验证：在哪个序列长度/层深/分辨率交点，动态剪枝开始优于静态合并或直接换更小主干？
