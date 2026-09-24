---
id: arxiv-watch-run-<project>-<run-id>
type: metadata
title: "<project> arXiv 检索 <run-id>"
tags: [metadata, workflow, research]
status: active
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
---

# 本次检索

- project / 模式：<project> / collect 或显式补检。
- 启动时刻：<UTC ISO 时间>；本地时刻：<Asia/Shanghai 时间>。
- 冻结窗口：<UTC-start> 至 <UTC-end>；按首次提交 published 过滤。
- 配置：<项目 watch/overview.md 完整 WikiLink>；本次实际查询见下表，不依赖以后可能改变的配置。
- 批次覆盖：<complete / partial / failed>。
- Wiki 写入与校验：<完成 / 中断 / 失败及位置>。
- 补检所针对的原批次：<链接；普通运行填不适用>。

## 实际请求与覆盖

| query-id | 实际完整表达式与 URL | 访问时刻 UTC | totalResults | 已读取 start / max_results | 原始返回数 / 窗口内数 | 下一页与错误 |
|---|---|---|---|---|---|---|

不得用预设查询代替实际发出的请求；回退网页记录 URL、筛选条件与可见数量，无法确定 totalResults 时写 unknown。

## 去重与结果

- 原始命中总数：<含跨查询重复>；窗口内唯一 ID：<数量或 unknown>。
- 全库新来源：<数量>；首次加入本项目索引的历史来源：<数量>；已有候选重复：<数量>。
- 新来源按关系计数：direct <n> / adjacent <n> / uncertain <n> / out-of-scope <n>。
- 新候选与关系：<基础 arXiv ID、source_id；相关性只是摘要筛查判断>。
- 已知重复：<基础 arXiv ID 与复用来源/笔记；同一论文跨查询命中只算一次>。
- 版本变化：<实际观测版本、既有记录位置；无则写无>。

## 未完成与重试

- 未筛查的已取得 ID / 待核验身份：<列表与原因；无则写无>。
- 未取完的查询：<query-id、下一页 start、剩余量或 unknown>。
- 失败或限流：<具体错误、已尝试次数、回退与下一步>。
- 停跑造成的窗口外缺口：<时间区间；未出现则写无>。
- 查询覆盖边界：只覆盖本次关键词，不能证明领域无其他新论文。

## 收尾

- <候选表基础 ID 唯一、来源已登记、用户决定保留、ingested 链接与阅读层级核对结果>。
- <wiki-finalize 校验结果；错误修复与既有警告分别说明>。
- <本次创建和修改文件；CHANGELOG 是否需要更新及依据>。
