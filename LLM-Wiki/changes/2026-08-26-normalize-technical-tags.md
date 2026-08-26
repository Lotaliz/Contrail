---
id: change-2026-08-26-normalize-technical-tags
type: change
title: 规范论文技术标签与标签索引
tags: [metadata, workflow]
date: 2026-08-26
change_type: changed
---

# 规范论文技术标签与标签索引

## 范围

- 修复 7 个已有元数据字段但缺少 frontmatter 起始分隔符的 Markdown 文件。
- 为 `research/*/papers/` 下现有 56 篇论文笔记补充跨论文复用的技术标签，并将受影响笔记的 `updated` 统一为 2026-08-26。
- 重构 `index/tags.md`，按文档功能、安全任务、模型/模态、压缩与蒸馏机制、运行时与评测属性分类受控词表。
- 在内容规范中补充多标签、粒度、顺序和新增标签约束。

## 粒度决策

- 保留 `paper-note`、`research`、`method`、`data` 等功能标签。
- 每篇论文选择多个技术标签，通常覆盖任务/对象与核心机制，必要时再增加系统或评测属性。
- 不使用论文名、模型名、数据集名、会议名或单篇方法缩写作为标签。
- 优先保留跨论文共性；对当前仅覆盖一篇但属于稳定技术族的 `model-routing`、`test-time-adaptation` 与 `unstructured-pruning` 暂时保留，等待后续来源扩展。

## 验收

- 56 篇论文均至少具有 2 个技术标签。
- 标签索引记录当前论文覆盖数量并提供代表页面。
- Wiki 校验器用于检查元数据、来源、链接、日期和标签索引一致性。
