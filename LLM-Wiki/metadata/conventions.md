---
id: wiki-conventions
type: metadata
tags: [metadata]
title: "文件与内容规范"
status: active
---

# 文件与内容规范

## 文件

- 文本统一为 UTF-8；换行符可由版本控制统一。
- 概念文件和普通目录使用小写 `kebab-case`，概念中文名写在 `title` 中；约定俗成的 `README.md` 与 `CHANGELOG.md` 例外。
- 一个概念页只设置一个主要实体，别名写入 `aliases`；当前 `concepts/` 仅作为空目录预留。
- 每个研究方向使用 `research/<project>/` 独立分区，并包含 `overview.md` 与 `papers/`。
- 二进制原始资料只放在 `raw/`；实验产物只放在 `experiments/`。

## Frontmatter

概念页至少包含：

```yaml
id: stable-kebab-case-id
type: concept
category: technology
title: 中文标题
aliases: []
tags: []
status: seed
related: []
sources: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
```

- `id` 创建后保持稳定，即使标题改变也不修改。
- `category` 取值见 `metadata/schema.yaml`。
- `related` 写目标实体的 `id`；正文中再使用可点击 WikiLink。
- `sources` 只引用 `raw/sources.yaml` 内的来源 `id`。

## 链接与标签

- 内部链接使用完整 Vault 路径，例如 `[[LLM-Wiki/research/_template/overview.md|研究模板]]`。
- WikiLink 出现在 Markdown 表格中时，将别名分隔符写成 `\|`；例如 `[[path/note.md\|显示名]]`。也可省略别名，使用 `[[path/note.md]]`。
- 标签表示集合关系，WikiLink 表示实体间的语义关系。
- 避免无控制地创建近义标签；先检查 [[LLM-Wiki/index/tags.md|标签索引]]。
- 标签使用受控词表。功能标签描述文档角色，技术标签描述论文或实体的研究任务、模型/模态、核心机制及系统属性；不要用标签重复标题中的模型名、论文名、数据集名或会议名。
- 一篇论文可以对应多个技术标签。通常保留 `paper-note`、`research` 等功能标签，并选择 2–5 个最有区分度的技术标签；跨多个技术层次的论文可以适当增加，但不枚举所有正文关键词。
- 技术标签应能跨论文复用，优先采用稳定的研究族名称。当前仅有一篇论文使用、但属于公认技术族的标签可以保留；单篇方法缩写和一次性实现细节不创建标签。
- frontmatter 中标签顺序依次为：功能标签、任务/领域、模型/模态、机制、系统或评测属性。
- 新概念页至少添加一个出链，并尽量让相关页面产生回链。

## 内容边界

- 原始事实与个人推断应明确区分。
- 数据结论必须指向实验记录或来源。
- 不确定内容使用“待验证”小节，不把猜测写成定论。
