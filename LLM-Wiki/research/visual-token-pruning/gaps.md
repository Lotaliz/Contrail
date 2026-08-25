---
id: visual-token-pruning-gaps
type: synthesis
title: 视觉 Token 剪枝证据缺口
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-zhan-2024-token-pruning-vssm, paper-yao-2026-v-pruner, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco]
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

## G5：当前 query 相关性与 multi-turn/未来生成可复用性冲突（满足 Motivation 门槛）

- 支持：PuMer、SparseVLM 显示文本指导有利于当前问题；VisionZip 明确展示上一轮 query-conditioned tokens 写入 KV 后不适合新问题。
- 反证：Visual Haystack 等强文本指导任务中，完全 task-agnostic 的视觉选择会下降，不能简单统一改成无文本选择。
- 边界：单轮短回答可为每个 query 重新编码时，冲突较弱；多轮、长答案、代理任务更突出。
- 待验证：能否保留一个小型 task-agnostic coverage core，再按 query 增量加载/回收视觉 token？

## G6：attention importance 缺少空间覆盖与简单基线约束（满足 Motivation 门槛）

- 支持：Wen et al. 显示 random/pooling 在约三分之二普通 benchmark 上优于部分 attention 方法，并发现序列位置偏置；VisionZip 发现视觉编码器信息聚合位置与 LLM 文本相关位置可能错位；DivPrune 显示 diversity 优于随机和冗余选择。
- 反证：SparseVLM 在 Visual Haystack 与部分视频 QA 上证明 text-guided attention 确有价值。
- 边界：结论不是“attention 无用”，而是“attention 不能单独作为普适选择真值”。
- 待验证：importance、coverage、diversity 的权重能否按任务/样本自适应，而非固定超参数？

## G7：多模态生成的效率目标仍以 FLOPs/prefill 为主（满足 Motivation 门槛）

- 支持：VisionZip 的 prefill 约 7.8× 对应总时间约 3×；DivPrune 的 prefill 约快 55%而 E2E 约快 22%；Wen et al. 显示相似 token 数/FLOPs/KV 的方法总时长仍不同。
- 反证：这些工作已开始报告真实 TTFT、CUDA time 或端到端时间，因此并非完全缺失系统证据。
- 边界：短回答、固定 batch 的结论不可直接外推到长生成、高并发或边缘设备。
- 待验证：把 vision encode、TTFT、decode tokens/s、输出长度、KV、P95 和能耗直接纳入 budget search 后，配置是否不同于 VisPCO 的 FLOPs Pareto 解？

## G8：平均 VQA/生成指标掩盖定位、OCR 与幻觉失败（满足 Motivation 门槛）

- 支持：Wen et al. 的 RefCOCO 高压缩结果全面崩溃；VisionZip 的 TextVQA 分析显示 proxy-token misalignment；不同方法在 POPE 上差异显著。
- 反证：现有方法已经覆盖 OCR-VQA、TextVQA、POPE、captioning 与视频，不是完全没有细粒度评测。
- 边界：不能据此断言所有剪枝都会增加幻觉；需要相同输出解码与统计显著性实验。
- 待验证：在相同平均 benchmark 分数下，剪枝是否系统性增加小目标遗漏、数值错误和无视觉证据的语言先验回答？

## G9：联合视觉—文本 token 剪枝与生成期动态策略较少（候选缺口）

- 支持：PuMer 明确同时压缩图像与文本 token；本轮纳入的多数 MLLM 方法只压视觉 token。生成期按已生成前缀更新/取回视觉证据也未形成代表性正式路线。
- 反证：视觉 token 通常远多于 prompt token，优先压视觉侧可能已覆盖主要成本；文本压缩还有独立 LLM/KV 文献。
- 边界：该判断来自代表性样本而非穷举，尚不进入正式 Motivation。
- 待验证：扩大到 ACL/EMNLP/NeurIPS/ICLR 的 joint multimodal cache/pruning 文献后，是否仍成立？
