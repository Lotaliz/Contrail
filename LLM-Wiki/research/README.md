---
id: research-index
type: index
title: 研究方向索引
tags: [index, research]
status: active
---

# 研究方向索引

research 以一个一级子目录对应一个研究方向或项目：

    research/
    ├─ README.md
    ├─ _template/
    │  ├─ overview.md
    │  └─ papers/
    └─ <project>/
       ├─ overview.md
       ├─ papers/
       ├─ reading-log.md
       ├─ landscape.md
       ├─ comparison.md
       ├─ gaps.md
       ├─ motivation.md
       └─ hypotheses.md

只有 overview.md 和 papers/ 是最低要求；其余综合文档按项目复杂度创建，并使用 synthesis 类型。

## 项目列表

| 研究方向 | 状态 | 范围摘要 | 最近更新 |
|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/overview.md\|视觉模型 Token 剪枝]] | active | 截至 2026-08-28；Token 剪枝、弹性子网与风险/SLO 感知执行 | 2026-08-28 |
| [[LLM-Wiki/research/safety-classifier-compression/overview.md\|安全判别系统的剪枝与蒸馏]] | active | 截至 2026-08-27；文本与多模态安全判别的吞吐、任务对齐剪枝和总成本 | 2026-08-27 |
| [[LLM-Wiki/research/variable-length-llm-serving/overview.md\|变长自回归 LLM 的批推理与流水线调度]] | active | 截至 2026-08-27；连续组批、KV 管理、chunked prefill、PP bubble 与 SLO | 2026-08-27 |

> 表格内若使用别名 WikiLink，必须把竖线转义。

## 论文笔记约定

- 每篇论文使用一个 Markdown 文件，存放在所属项目的 papers 子目录。
- 文件名建议为 YYYY-first-author-short-title.md。
- source_id 必须对应 raw/sources.yaml。
- reading_level 使用 discovered、skimmed、deep-read。
- verification 使用 unverified、source-checked、reproduced。
- 一篇论文涉及多个方向时选择主项目存放，其他项目只建立链接，避免复制。

完整流程见 [[LLM-Wiki/metadata/workflows/README.md|研究工作流]]。

| [[LLM-Wiki/research/ai-safety-systems-security-venues/overview.md\|安全四大顶会中的 AI 安全系统工作]] | active | 2023—2026 安全四大顶会；内容安全、对齐、检测、运行时与 agent 架构，排除攻击方法 | 2026-08-25 |
