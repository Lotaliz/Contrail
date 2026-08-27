---
id: visual-token-pruning-reading-log
type: synthesis
title: 视觉 Token 剪枝检索与阅读日志
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding]
status: active
created: 2026-08-24
updated: 2026-08-26
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
| VisPCO | ACL 2026 | deep-read | source-checked | Qwen2.5-VL 实验、逐层 Pareto 配置、数据预处理与官方实现核对 |

详细结果见 [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|图文多模态 Token 剪枝调研]]。

## 基础阅读

- [[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|视觉 Transformer 与 Token 剪枝基础]]：从 patch token、ViT/Swin 结构、任务类型、训练/推理流程到剪枝/合并/凝聚/恢复的区别。
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]：图文 token、prefill/decode/KV cache 与分类—生成差异。

## OSDI 双自适应 Guard Serving 补充检索

- 检索日期与时间截点：2026-08-26。
- 站点：USENIX OSDI/NSDI 正式 proceedings、ACM SOSP DOI 页面、PMLR/ICML；Guard 直接证据复用 Wiki 已登记的 SafeWatch、SafeRoute。
- 关键词族：`dynamic neural network serving`, `adaptive subnet serving SLO`, `early exit serving batching`, `LLM contextual sparsity`, `prompt depth pruning`, `continuous batching`, `chunked prefill`, `multimodal guard latency`。
- 纳入：OSDI/SOSP/NSDI/MLSys/ICML 中直接处理请求级动态计算、主干稀疏、连续批处理或 SLO 调度的正式论文；以及与多模态 Guard 自适应直接相关的正式论文。
- 排除：仅静态量化/权重压缩、没有真实系统执行的纯剪枝精度论文、未录用预印本、与 Guard/动态组批关系较弱的通用集群资源管理。
- 覆盖限制：本轮目标是判断 OSDI 定位而非穷举全部 LLM serving；八篇新增论文均为 `skimmed/source-checked`，结论限于官方摘要、正文公开页和论文元数据，未做本地复现。

| 论文 | 会议 | 层级 | 核验 | 纳入角色 |
|---|---|---|---|---|
| Orca | OSDI 2022 | skimmed | source-checked | iteration-level scheduling 与 selective batching 基础 |
| Brainstorm | OSDI 2023 | skimmed | source-checked | 动态网络 Cell/Router 抽象与运行时优化核心先例 |
| Deja Vu | ICML 2023 | skimmed | source-checked | 输入相关 head/MLP contextual sparsity |
| Sarathi-Serve | OSDI 2024 | skimmed | source-checked | chunked-prefill、uniform batch 与尾时延 |
| Apparate | SOSP 2024 | skimmed | source-checked | early-exit serving、在线反馈与准确率约束 |
| PowerInfer | SOSP 2024 | skimmed | source-checked | 激活稀疏的权重放置、预测器和 sparse operator |
| SuperServe | NSDI 2025 | skimmed | source-checked | 权重共享子网激活与 SLO-aware routing |
| PuDDing | ICML 2025 | skimmed | source-checked | prompt/task-dependent Transformer depth pruning |

### 检索结论

“任务自适应 Token 剪枝 + 任务自适应主干剪枝 + batch serving”中的每个单项均已有强先例。当前可辩护缺口是三者交叉处的 Guard 特有问题：Token 与主干预算质量上非可分、执行上产生二维异构，以及平均 accuracy 不能替代 fixed-FPR/worst-risk 安全约束。
