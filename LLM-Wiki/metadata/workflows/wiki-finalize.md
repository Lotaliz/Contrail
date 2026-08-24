---
id: workflow-wiki-finalize
type: metadata
title: Wiki 收尾与校验流程
tags: [metadata, workflow]
status: active
---

# Wiki 收尾与校验流程

## 触发

任何新增、删除、移动或修改 LLM-Wiki 内容的任务结束前。

## 收尾

1. 根据当前任务的操作记录列出实际新增、修改、移动或删除的文件；不通过 Git 推断。
2. 检查 frontmatter、稳定 ID、文档类型、状态和日期。
3. 新来源更新 raw/sources.yaml；论文笔记引用存在的 source_id。
4. 新概念更新必要索引、标签与双向链接。
5. 更新受影响文件的 updated 日期。
6. 对知识、结构或流程变化，在 CHANGELOG.md 当天日期下追加或合并一条统一记录。
7. 只有结构调整、Schema 迁移、批量研究导入、删除或复杂决策需要详细 changes 记录。
8. 运行仓库校验器：
   powershell -NoProfile -ExecutionPolicy Bypass -File .agents/skills/wiki-finalize/scripts/validate-wiki.ps1
9. 修复任务范围内的错误；需要学术判断的警告交给用户。
10. 报告新增、修改、未完成和待人工确认项。

## CHANGELOG 统一格式

日期标题：

    ## YYYY-MM-DD

记录条目：

    - [类型] [范围] 一句话结果（可选：详情链接）。

允许类型：

- Added：新增来源、论文笔记、实体、实验、综合、索引或流程。
- Changed：定义、结构、关系、Schema 或工作方式改变。
- Fixed：错误事实、断链、错误元数据或影响使用的格式问题修复。
- Deprecated：内容仍保留但不再推荐。
- Removed：完成归档或删除。

## 记录边界

- 一个逻辑任务优先写一条记录；涉及不同类型或明显独立范围时才拆分。
- 单篇论文、小范围知识更新和普通实验只写 CHANGELOG，不强制创建 changes 文档。
- 不改变含义的错别字、空白和纯排版调整通常不记录。
- 不使用 Unreleased，不引用 Git commit，不检查 Git 状态。
- 所有 Git 操作由用户手动执行，Wiki 收尾流程不得调用 Git。
