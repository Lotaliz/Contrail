---
id: workflow-paper-ingestion
type: metadata
tags: [metadata, workflow, source]
title: "论文阅读与收录流程"
status: active
---

# 论文阅读与收录流程

## 触发

处理一篇具体论文的发现、快速筛选、阅读、总结、分析、比较或收录。

## 输入

论文文件或稳定 URL；所属研究项目（如已知）；期望阅读层级（如已知）。

默认层级：

- “发现、收录、加入候选”使用 discovered。
- “快速看、筛选、判断相关性”使用 skimmed。
- “阅读、分析、总结、精读”使用 deep-read。

## 流程

1. 检查 sources.yaml 和已有 source-note，按 DOI、arXiv ID、标题和文件哈希去重。
2. 合法获得原件时放入 raw/papers；否则只登记稳定 URL。
3. 登记来源，保留正式标题、作者、年份、URL、获取日期、本地路径、许可和哈希。
4. 从 templates/source.md 创建或更新 source-note。
5. 按三级阅读规范完成相应内容，明确作者主张、直接证据、个人批注和待验证项。
6. 链接已有概念。只有内容能跨论文复用且边界清楚时，才创建或更新 concept。
7. 更新项目 reading-log、论文比较或研究地图；discovered 论文不得直接改变正式 motivation。
8. 执行 Wiki 收尾流程。

## 完成条件

- 来源无重复且可定位。
- source-note 的 reading_level 与实际阅读深度一致。
- deep-read 的关键结果含页码、章节、图或表定位。
- 论文结论与 LLM 推断已分开。
- 所有新增 concept 都有至少一个来源和一个语义链接。
