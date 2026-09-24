---
id: change-2026-09-22-arxiv-watch
type: change
title: "视觉 Token 剪枝 arXiv 定时收集：完整 API 覆盖与 24 条新题录"
tags: [metadata, research, visual-token-pruning]
date: 2026-09-22
change_type: Added
---

# 实际变化

- 本次滚动 10 天窗口为 2026-09-12 05:26:19.968 至 2026-09-22 05:26:19.968 UTC；四组 API 均完整读取唯一结果页，覆盖状态为 complete。
- 60 条原始命中合并为 39 个唯一基础 ID；新增 24 条来源与候选，其中 direct 6、adjacent 6、uncertain 0、out-of-scope 12；15 个既有候选不重复引入，只更新最近命中日期。
- 新增候选全部保持 discovered / unverified 与 pending；原 38 行的 selected/deferred/skipped/ingested 决定、首次命中日期、精读链接和来源 ID 均保留。
- 实际 URL、查询式、分页覆盖、跨查询重复、摘要筛查理由、纠正过的 q3 诊断请求和完整新旧 ID 清单见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-22-052619Z|批次日志]]。
- 当前滚动窗口与 2026-09-16 complete 批次重叠，覆盖了 2026-09-18 partial 批次的全部时间区间；没有停跑造成的窗口外缺口。

## 文件清单

新增：`LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-22-052619Z.md`、`LLM-Wiki/changes/2026-09-22-arxiv-watch.md`（本页）。

修改：`LLM-Wiki/research/visual-token-pruning/watch/candidates.md`、`LLM-Wiki/research/visual-token-pruning/watch/runs.md`、`LLM-Wiki/research/visual-token-pruning/watch/overview.md`、`LLM-Wiki/raw/sources.yaml`、`LLM-Wiki/CHANGELOG.md`。

## 边界与人工决定

仅完成题录与摘要筛查，没有下载 PDF、执行精读、创建 papers 笔记或修改研究综合。关键词查询不能证明无漏检。新增的 12 篇 direct/adjacent 候选等待研究者决定是否精读；本次没有替用户更改决定。

Wiki validator：PASS，0 错误、2 条既存警告。警告为既有实验原始记录的未解析 WikiLink，以及 2026-08-25 的详细变化记录未被 CHANGELOG 链接；本次未改写无关材料。
