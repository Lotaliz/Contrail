---
id: change-2026-09-24-selected-watch-deep-read-and-exclusion-policy
type: change
title: "精读近期追踪选定论文并简化排除索引"
tags: [change, research, visual-token-pruning, source]
date: 2026-09-24
change_type: Changed
status: active
---

# 变更说明

用户更新近期候选索引并选择 SLICEChat、ME-VLM、VPRune、CounterCredit 与 QCPruner 精读；同时明确 out-of-scope 排除项由 agent 判定后只保留用于查重，不再进入人工 `pending` 队列。

## 新增

- 五份 `research/visual-token-pruning/papers/` 精读笔记。
- 五份官方 arXiv PDF 原件及 SHA256；ME-VLM、VPRune 使用当前 v2，其余为 v1。

## 修改

- 复用五条已有 source_id，将 `raw/sources.yaml` 从 discovered / unverified 升级为 deep-read / source-checked，并登记版本、许可、本地路径、哈希与笔记。
- 将候选表五项从 `selected` 改为 `ingested`；相关候选当前为 0 pending、19 skipped、1 deferred、11 ingested。
- 从 31 条 out-of-scope 排除行中删除“决定”列及 `pending` 值；保留基础 ID、题录、排除理由、命中日期和 source_id 作为永久查重记录。
- 更新 arXiv Watch workflow、仓库 skill 和项目配置：只有 direct / adjacent / uncertain 新候选默认 pending；out-of-scope 没有人工决定状态，用户要求重审时才移回相关候选表。
- 更新阅读日志与 CHANGELOG；当前正式动机、研究计划和实验结果未因论文作者报告而改写。

## 证据边界

五篇论文均按 PDF 完成 source-checked 深读，但未运行代码、模型、RL 或硬件实验，不标 reproduced。SLICEChat 的时延表与“最低时延”文字结论不一致；ME-VLM 的 prefill 改善来自压缩、量化和硬件—软件协同，无法单独归因；其余论文的跨模型、selector 成本或因果指标边界均保留在对应笔记中。
