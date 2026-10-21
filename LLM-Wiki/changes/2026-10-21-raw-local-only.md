---
id: change-2026-10-21-raw-local-only
type: change
title: "整个 raw 资料库改为仅本地保存"
tags: [change, source, metadata]
date: 2026-10-21
change_type: Changed
status: active
---

# 本地资料库范围

按用户要求，将根目录忽略规则统一为 `/LLM-Wiki/raw/`，覆盖所有文件类型和未来子目录，取代此前仅忽略 PDF、HTML、HTM 的规则。本地论文、图片、数据快照和来源登记均保留；仅更新本地 raw/README.md 的资料库说明。

本次范围包括此前仍发布的四个文件：

- `LLM-Wiki/raw/README.md`
- `LLM-Wiki/raw/sources.yaml`
- `LLM-Wiki/raw/papers/.gitkeep`
- `LLM-Wiki/raw/web/.gitkeep`

`raw/dataset-audit-20261014/` 的 18 个图片文件是此前数据审阅保存的论文例图、Open Images 样本及页面图标，继续保留在本地，不作为本次新增研究证据。

来源登记表仍位于本地 `raw/sources.yaml`，未迁移或删除。新克隆不会取得该表，需另行恢复本地副本才能执行依赖来源 ID 的工作流和完整校验。公开笔记中的官方来源链接继续作为读者的原文入口。本次不改写历史提交，远程当前目录的变化在用户提交并推送后生效。
