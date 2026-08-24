---
id: change-2026-08-24-standardize-research-workflows
type: change
title: 固化研究工作流
tags: [metadata, workflow]
date: 2026-08-24
change_type: added
---

# 固化研究工作流

## 变更

- 添加论文阅读、文献调研、实验执行、学术写作和 Wiki 收尾 SOP。
- 添加 discovered、skimmed、deep-read 三级论文阅读。
- 添加仓库级 AGENTS.md 与五个自动发现技能。
- 扩展 paper-note 与 synthesis Schema 和模板。
- 添加只读 Wiki 校验器和 Codex Stop Hook。

## 影响

研究任务由 AGENTS.md 路由到相应技能。所有 Wiki 写入任务结束前必须执行 [[LLM-Wiki/metadata/workflows/wiki-finalize.md|Wiki 收尾与校验流程]]。
