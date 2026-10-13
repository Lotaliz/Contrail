---
id: raw-sources-readme
type: metadata
tags: [source, metadata]
title: "原始资料库说明"
status: active
updated: 2026-10-13
---

# 原始资料库

这里保存未经概念化改写的本地论文和网页资料，以便追溯；仓库发布来源登记与阅读笔记。

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
2. 自 2026-10-13 起，raw 下的 PDF、HTML、HTM 原文只作为本地阅读副本，由根目录 .gitignore 忽略；当前远程版本与后续提交均不包含这些文件。来源表的 local_path、local_artifacts 和 sha256 保留用于本地定位与版本核对，克隆仓库后需按来源 URL 重新取得副本。
3. 论文笔记及变更记录使用官方来源 URL 链接原文；WikiLink 用于仓库中发布的笔记和概念页。
4. 不修改原文件；清洗或转换后的版本使用新文件名。
5. 每个来源必须在 `sources.yaml` 中有唯一 `id`。
6. 概念页的 `sources` 字段引用该 `id`。
7. 尊重版权、许可协议和敏感数据要求。
