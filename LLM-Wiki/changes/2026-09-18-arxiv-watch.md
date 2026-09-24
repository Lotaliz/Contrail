---
id: change-2026-09-18-arxiv-watch
type: change
title: "视觉 Token 剪枝 arXiv 定时收集：网页回退与覆盖缺口"
tags: [metadata, research, visual-token-pruning]
date: 2026-09-18
change_type: Added
---

# 实际变化

- 本次滚动 10 天窗口为 2026-09-08 02:02:06 至 2026-09-18 02:02:06 UTC。四组 API 各首试加两次重试均 HTTP 406；使用 arXiv 网页发现并核验，覆盖标 partial。
- 网页可见 12 条题录合并为 10 个唯一身份；新增 6 条来源和候选（直接相关 G2TM 1 篇、排除 5 篇），4 个已知候选不重复引入，只更新最近命中日期。
- 原32行候选的人工决定、笔记链接和首次命中日期均保留，包含 StackTok 的 ingested；原来源记录不改写，没有新建 papers 笔记或下载 PDF。
- 实际 URL、表达式、重试时间、网页回退、身份核验、排除理由和未完成覆盖见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-18-020206Z.md|完整批次日志]]。
- watch 配置补充本次实际定时运行事实，替换过时的“尚未启用”描述；未更改调度或查询词。

## 文件清单

新增：`LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-18-020206Z.md`、`LLM-Wiki/changes/2026-09-18-arxiv-watch.md`（本页）。

修改：`LLM-Wiki/research/visual-token-pruning/watch/candidates.md`、`LLM-Wiki/research/visual-token-pruning/watch/runs.md`、`LLM-Wiki/research/visual-token-pruning/watch/overview.md`、`LLM-Wiki/raw/sources.yaml`、`LLM-Wiki/CHANGELOG.md`。

## 边界与人工决定

仅完成题录/摘要的 discovered 筛查；G2TM 供研究者选择精读，其余新增候选按摘要判断超出范围。API 仍不可用，四组 start=0 待补查，网页未知召回不能用于证明没有其他新论文。没有超过10天的停跑缺口。运行未调用 Git。

Wiki validator PASS，0 错误、2 条既存警告，与任务开始前基线一致。语义核对通过：38 个候选基础 ID 唯一、6 条新来源身份与冻结窗口一致、原32条人工决定/笔记链接/首次发现日期保留，StackTok 的 ingested 状态与原始来源字段保留。既存警告为原始实验记录的未解析 WikiLink，以及 2026-08-25-design-safety-compression-experiments.md 未链接至 CHANGELOG；本次未改写无关材料。
