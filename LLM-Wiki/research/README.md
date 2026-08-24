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
| [[LLM-Wiki/research/visual-token-pruning/overview.md\|视觉模型 Token 剪枝]] | active | 2023–2026 顶会；判别任务精度—真实推理时延权衡 | 2026-08-24 |

> 表格内若使用别名 WikiLink，必须把竖线转义。

## 论文笔记约定

- 每篇论文使用一个 Markdown 文件，存放在所属项目的 papers 子目录。
- 文件名建议为 YYYY-first-author-short-title.md。
- source_id 必须对应 raw/sources.yaml。
- reading_level 使用 discovered、skimmed、deep-read。
- verification 使用 unverified、source-checked、reproduced。
- 一篇论文涉及多个方向时选择主项目存放，其他项目只建立链接，避免复制。

完整流程见 [[LLM-Wiki/metadata/workflows/README.md|研究工作流]]。
