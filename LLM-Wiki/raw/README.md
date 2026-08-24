---
id: raw-sources-readme
type: metadata
title: 原始资料库说明
tags: [source, metadata]
status: active
---

# 原始资料库

这里保存未经概念化改写的论文和网页资料，以便追溯。

## 子目录

- `papers/`：PDF、作者版本、补充材料。
- `web/`：HTML、Markdown、MHTML 或网页截图。
- `sources.yaml`：所有来源的统一登记表。

## 命名建议

- 论文：`YYYY-first-author-short-title.pdf`
- 网页：`YYYY-MM-DD-domain-short-title.html`
- 附件：与主文件同名，加 `-supplement`、`-figure-01` 等后缀。

## 规则

1. 尽量保存合法获得的本地副本；无法保存时记录 URL、访问日期和归档地址。
2. 不修改原文件；清洗或转换后的版本使用新文件名。
3. 每个来源必须在 `sources.yaml` 中有唯一 `id`。
4. 概念页的 `sources` 字段引用该 `id`。
5. 尊重版权、许可协议和敏感数据要求。

