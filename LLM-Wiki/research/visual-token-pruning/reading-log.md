---
id: visual-token-pruning-reading-log
type: synthesis
title: 视觉 Token 剪枝检索与阅读日志
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco]
status: active
created: 2026-08-24
updated: 2026-08-24
---

# 检索与阅读日志

## 检索设置

- 检索日期与时间截点：2026-08-24。
- 站点：CVF Open Access、OpenReview、NeurIPS Proceedings、PMLR、IJCAI Proceedings、AAAI Proceedings、ECVA、IEEE/作者公开版。
- 关键词族：`vision transformer token pruning`, `visual token compression`, `token merging`, `adaptive token sparsification`, `ImageNet latency throughput`, `hardware-aware token pruning`, `vision state space token pruning`。
- 纳入：会议白名单内正式主会论文；视觉判别任务；机制确实减少中间 token 计算；至少报告质量指标。
- 核心证据升级：同时报告真实时延/吞吐，或揭示影响精度保持的明确失败机制。
- 排除：WACV/ICCV workshop、期刊、撤稿、预印本；只报生成任务；只报 FLOPs 且与核心问题弱相关。

## 覆盖结果

| 论文 | 会议 | 层级 | 核验 | 纳入角色 |
|---|---|---|---|---|
| HeatViT | HPCA 2023 | deep-read | source-checked | 系统与真实硬件核心证据 |
| ToMe | ICLR 2023 | skimmed | source-checked | 合并基线与信息保真边界 |
| STViT | CVPR 2023 | deep-read | source-checked | 语义凝聚、下游恢复与入门概念的主要证据 |
| Adaptive Sparse ViT | IJCAI 2023 | deep-read | source-checked | 动态阈值、吞吐与单图时延 |
| DiffRate | ICCV 2023 | deep-read | source-checked | 自动层预算、剪枝与合并协同 |
| Zero-TPrune | CVPR 2024 | skimmed | source-checked | 免训练重要性与相似性联合 |
| ToCom | ECCV 2024 | deep-read | source-checked | 推理预算变化时的精度补偿 |
| Token Pruning in VSSMs | NeurIPS 2024 | deep-read | source-checked | 跨架构失败反例 |
| TCA | ICCV 2025 | skimmed | source-checked | 分布偏移下的凝聚式适应 |
| V-Pruner | AAAI 2026 | skimmed | source-checked | 全局序列决策最新进展 |

## 覆盖限制

- “顶会”采用本项目明示白名单，不声称是唯一学界定义。
- 2026 年仅覆盖截至 8 月 24 日已正式发表内容，后续会议尚不完整。
- 论文的硬件、实现、batch size 和计时协议差异很大，表中速度数字不可直接横向排序。
- 没有本地复现实验，所有结果均为论文来源陈述；`verification` 不使用 `reproduced`。

## 图文多模态补充检索

- 检索日期：2026-08-24；时间截点同日。
- 站点：ACL Anthology、ECVA/ECCV、CVF Open Access、PMLR/ICML。
- 关键词族：`vision language token pruning`, `multimodal LLM visual token pruning`, `text-guided patch selection`, `visual token compression`, `prefill KV cache multimodal`, `multi-turn visual token pruning`。
- 纳入：正式会议论文；确实减少视觉或图文 token；覆盖分类/检索/VQA/captioning/开放式生成/视频；至少报告质量与计算量，核心论文优先含真实 latency/TTFT/KV。
- 排除：仅预印本、纯文本 KV pruning、只改权重/头、只做 DiT 图像生成、没有 token 减少机制的纯 encoder redesign。

| 论文 | 会议 | 层级 | 核验 | 纳入角色 |
|---|---|---|---|---|
| TRIPS | EMNLP 2022 | skimmed | source-checked | 视觉编码器内文本指导选择的早期代表 |
| PuMer | ACL 2023 | skimmed | source-checked | 图文联合 pruning 与模态内 merging |
| FastV | ECCV 2024 | skimmed | source-checked | decoder 内 training-free attention pruning 基线 |
| VisionZip | CVPR 2025 | deep-read | source-checked | LLM 前信息凝聚、TTFT 与 multi-turn 证据 |
| DivPrune | CVPR 2025 | skimmed | source-checked | 多样性/覆盖与 image-video E2E 证据 |
| SparseVLM | ICML 2025 | skimmed | source-checked | text raters、自适应比例与 token recycling |
| Are We Solving the Right Problem? | Findings ACL 2025 | deep-read | source-checked | random/pooling 反例、空间偏置与 latency 复核 |
| VisPCO | ACL 2026 | skimmed | source-checked | layer-wise Pareto configuration optimization |

详细结果见 [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|图文多模态 Token 剪枝调研]]。

## 基础阅读

- [[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|视觉 Transformer 与 Token 剪枝基础]]：从 patch token、ViT/Swin 结构、任务类型、训练/推理流程到剪枝/合并/凝聚/恢复的区别。
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]：图文 token、prefill/decode/KV cache 与分类—生成差异。
