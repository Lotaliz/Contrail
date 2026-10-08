---
id: visual-token-pruning-watch-runs
type: index
title: "视觉 Token 剪枝：近期检索批次"
tags: [index, research, visual-token-pruning]
status: active
created: 2026-09-16
updated: 2026-10-08
---

# 批次导航

首轮检索已执行。每次实际运行新增一条导航和独立日志，零新增、失败和局部覆盖也保留。下表状态是查询覆盖状态，不替代 Wiki frontmatter status。

| 批次日志 | UTC 窗口 | 覆盖状态 | 新相关 / 相邻 / 待判 / 不相关 | 已知重复 | 待补检与失败 |
|---|---|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-08-020043Z.md\|2026-10-08-020043Z]] | 09-28 02:00:43 至 10-08 02:00:43 UTC | failed | 未确认 / 未确认 / 未确认 / 未确认 | unknown | arXiv API HTTP 429；q1–q4 均无完整覆盖 |
| [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-03-074539Z.md\|2026-10-03-074539Z]] | 09-23 07:45:39 to 10-03 07:45:39 UTC | complete | 21 / 26 / 0 / 46 | 9 project candidates; 75 cross-query repeats | None; five pages complete |
| [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-25-115723Z.md\|2026-09-25-115723Z]] | 09-15 11:57:23 至 09-25 11:57:23 UTC | complete | 4 / 1 / 0 / 10 | 26（另合并跨查询重复 21 条） | 无；四组均在一页内完成 |
| [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-22-052619Z.md\|2026-09-22-052619Z]] | 09-12 05:26:19 至 09-22 05:26:19 UTC | complete | 6 / 6 / 0 / 12 | 15（另合并跨查询重复 21 条） | 无；四组均在一页内完成 |
| [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-18-020206Z.md\|2026-09-18-020206Z]] | 09-08 02:02:06 至 09-18 02:02:06 UTC | partial | 1 / 0 / 0 / 5 | 4（另合并回退查询重复 2 条） | q1–q4 API 均 HTTP 406；网页回退覆盖不完整 |
| [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-16-084738Z.md\|2026-09-16-084738Z]] | 09-06 08:47:38 至 09-16 08:47:38 UTC | complete | 10 / 7 / 1 / 14 | 0（另合并跨查询重复 17 条） | 1 篇相关性待核验；无分页缺口 |

新候选计数仅包含本次确认的全库新来源；首次补入本项目的历史来源另外说明。查询命中数、窗口内唯一数和新增来源数在日志分开，避免重复计数。

日志使用 [[LLM-Wiki/templates/arxiv-search-run.md]]；执行规则见 [[LLM-Wiki/metadata/workflows/arxiv-watch.md]]；返回 [[LLM-Wiki/research/visual-token-pruning/watch/overview.md]]。
