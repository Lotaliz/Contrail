---
id: model-compression-privacy
type: research-overview
title: 模型压缩与隐私泄露
aliases: [模型压缩隐私]
tags: [research, membership-inference, model-compression]
status: active
related: []
sources: [paper-li-2026-compleak, paper-du-2026-cmia-pmia, paper-lu-2026-icp-mia, paper-chen-2026-window-mia, paper-tong-2026-tokenizer-mia, paper-nguyen-2026-menta, paper-wang-2026-vidleaks, paper-zhang-2025-soft, paper-shang-2025-wemem, paper-li-2025-dhattack, paper-tan-2026-neural-activation-mia]
created: 2026-09-15
updated: 2026-09-15
---

# 模型压缩与隐私泄露

## 一句话概述

研究剪枝、量化、权重聚类等压缩操作，以及同一模型多个压缩版本的联合发布，如何改变训练数据隐私泄露面。

## 当前范围

### 包含

- 模型压缩前后及多版本发布条件下的成员推断攻击与隐私审计。
- 压缩后的再训练、模型容量变化和输出差异所引入的隐私信号。
- 面向压缩流水线的隐私缓解与部署策略。

### 暂不包含

- 与压缩无关的一般成员推断综述。
- 只讨论任务精度、时延或模型大小而不评估隐私的压缩工作。
- 尚无直接证据的属性推断、模型反演和大规模生成式 LLM 外推。

## 当前证据地图

| 问题 | 当前证据 | 边界 |
|---|---|---|
| 单个压缩模型是否必然更泄露 | [[LLM-Wiki/research/model-compression-privacy/papers/2026-li-compleak.md\|CompLeak]] 的 CompLeakNR 显示多数轻度压缩版本与原模型相当，高度压缩版本反而常更不易受攻击 | 不支持“任意单模型压缩都会增加泄露” |
| 原模型与一个压缩版本同时发布 | CompLeakSR 以两者输出差异构造成员信号，显著强于只看单模型 | 依赖同分布影子数据、模型/压缩配置知识、真实标签和完整 posterior |
| 多个压缩版本同时发布 | CompLeakMR 聚合跨版本 posterior 与损失轨迹；版本越多，攻击通常越强 | 原模型不可访问时攻击仍增强，但低 FPR 下强度明显下降 |
| 压缩后再训练的作用 | 训练集子集微调实验显示被再次使用的样本更易泄露；无再训练的动态 PTQ 泄露较弱 | 仍需更严格区分容量改变、再训练和版本关联三个因素 |

## 论文笔记

- [[LLM-Wiki/research/model-compression-privacy/papers/2026-li-compleak.md|CompLeak：模型压缩、多版本发布与成员推断泄露]]（deep-read，source-checked）

## 专题综合

- [[LLM-Wiki/research/model-compression-privacy/landscape.md|2025—2026 MIA 研究版图]]
- [[LLM-Wiki/research/model-compression-privacy/comparison.md|CompLeak 的 MIA 前沿定位]]
- [[LLM-Wiki/research/model-compression-privacy/reading-log.md|本轮检索与证据边界]]

## 开放问题

1. 在匹配查询预算、输出粒度和可访问模型数量后，压缩版本是否仍比独立重复训练模型泄露更多？
2. 不使用原训练数据恢复精度、只用公开辅助数据或完全后训练压缩时，风险如何变化？
3. 结论能否迁移到蒸馏、结构剪枝、生成式模型和仅返回 hard label 的真实 API？
4. 能否为“可同时发布多少版本、允许何种输出、允许哪些压缩后再训练数据”建立可操作的隐私发布策略？

## 证据边界

当前项目以 CompLeak 为唯一 deep-read 核心证据，并以 2025—2026 安全顶会十篇代表工作做 source-checked skimmed 定位。它支持判断活跃路线与论文位置，但不是跨数据库计量综述，也不据此更新其他研究项目的正式 motivation。
