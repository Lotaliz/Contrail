---
id: adaalloc-project-screening
type: source-note
title: "AdaAlloc 官方项目页：全局与局部预算分配的相邻工作"
tags: [research, visual-token-pruning, adaptive-budget]
source_id: webpage-an-2026-adaalloc
status: active
created: 2026-10-10
updated: 2026-10-20
---

# AdaAlloc 项目页筛查

来源：[UT Austin 官方项目页](https://vision.cs.utexas.edu/projects/adaalloc/)，访问 2026-10-10。作者 Joungbin An、Kristen Grauman；网页题录年份 2026。仅完成项目页筛查，不登记为已读论文；页面 BibTeX 的 arXiv 字段只有 `2605`，没有可核验完整论文编号。

**网页作者主张：** 将固定视觉 Token 预算在低分辨率全局视频和高分辨率局部时间证据之间分配；从概览规划，再做时间定位和紧凑记忆，用于长视频 QA。网页称 training-free，并列 LVBench、MLVU、VideoMME、LongVideoBench。

**边界：** 未获得完整论文/主表/代码核验，不采用性能数字，不推断内部成本或模型实现。它是全局覆盖与局部细节取舍的相邻机制，不能支持 C5 自适应总预算或安全图像效果。

**项目判断：** 可引用其问题形式作近邻筛查，第一版不迁移多段视频证据和规划链。TODO：完整论文可访问后确认稳定 ID、阅读层级和部署代价。

关联：[[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|c5-per-sample-visual-allocation（历史方案，已删除）]]。
