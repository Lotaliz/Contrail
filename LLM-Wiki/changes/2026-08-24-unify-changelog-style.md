---
id: change-2026-08-24-unify-changelog-style
type: change
title: 统一 CHANGELOG 风格
tags: [metadata, workflow]
date: 2026-08-24
change_type: changed
---

# 统一 CHANGELOG 风格

## 变更

- 取消 Unreleased 分区，改为按日期倒序记录。
- 每条记录统一为类型、范围和一句结果。
- 明确普通更新只写 CHANGELOG，复杂变更才创建 changes 详情。
- 从 Wiki 校验器、收尾流程、AGENTS.md 和技能中移除 Git 状态与 commit 依赖。
- 明确所有 Git 操作由用户手动完成。

## 新格式

    ## YYYY-MM-DD

    - [Changed] [metadata/changelog] 统一 CHANGELOG 风格（详情链接）。

## 影响

LLM 根据当前任务实际产生的语义和结构变化更新日志，不读取 Git 状态来推断变更。
