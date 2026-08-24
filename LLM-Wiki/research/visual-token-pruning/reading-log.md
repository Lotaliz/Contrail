---
id: visual-token-pruning-reading-log
type: synthesis
title: 视觉 Token 剪枝检索与阅读日志
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner]
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
| STViT | CVPR 2023 | skimmed | source-checked | 语义凝聚与下游可恢复性 |
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
