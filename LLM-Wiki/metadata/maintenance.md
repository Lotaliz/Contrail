---
id: wiki-maintenance
type: metadata
title: Wiki 维护规则
tags: [metadata]
status: active
---

# Wiki 维护规则

## 每次修改

1. 按 [[LLM-Wiki/metadata/workflows/README.md|研究工作流]] 执行对应任务。
2. 检查 frontmatter 是否符合 schema.yaml。
3. 新增来源时更新 raw/sources.yaml。
4. 新建研究方向时复制 research/_template，并更新研究目录。
5. 新增或重命名实体时更新标签、实体索引及相关双向链接。
6. 更新文档的 updated 日期。
7. 根据本次任务的实际内容或结构变化更新 CHANGELOG.md。
8. 运行 Wiki 校验器。

## CHANGELOG 规则

- 使用日期标题：## YYYY-MM-DD；同一天的记录集中在同一标题下。
- 每条记录使用：- [类型] [范围] 一句话结果。
- 类型限定为 Added、Changed、Fixed、Deprecated、Removed。
- 日期按新到旧排列，同一天内重要或影响较大的变化优先。
- 一个逻辑任务优先合并为一条；只有类型或范围明显不同才拆分。
- 不保留 Unreleased，不记录 Git commit、哈希、暂存状态或分支。
- 判断是否记录只依据任务造成的语义或结构变化，不检查 Git。
- 结构调整、Schema 迁移、批量研究导入、删除或复杂决策可另建 changes/YYYY-MM-DD-short-description.md，并从对应条目链接。
- 单篇论文、小规模概念更新或普通实验通常只需 CHANGELOG 条目，不强制创建详细 change note。
- 不改变含义的错别字、空白和纯排版调整通常不记录。

## 自动化

仓库根目录 AGENTS.md 负责把读论文、做调研、跑实验和写论文路由到 .agents/skills 中的对应技能。所有 Wiki 写入任务最后执行 wiki-finalize。

手动校验命令：

    powershell -NoProfile -ExecutionPolicy Bypass -File .agents/skills/wiki-finalize/scripts/validate-wiki.ps1

.codex/hooks.json 在 Codex 任务停止前再次运行只读校验。校验器不读取 Git 状态，也不执行任何 Git 操作。

## Git 边界

所有 Git 检查、暂存、提交和历史管理均由用户手动完成，不属于 Wiki 工作流。

## 定期维护

- 每月：检查断链、孤立页面、重复实体、未登记来源和长期停留在 discovered 的论文。
- 每季度：复查标签体系、过时结论、draft/seed 页面和 Motivation 的证据链。
- 删除前：先标记 deprecated，添加替代链接；确认无引用后再归档。
