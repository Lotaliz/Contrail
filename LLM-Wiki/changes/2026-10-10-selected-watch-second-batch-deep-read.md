---
id: change-2026-10-10-selected-watch-second-batch-deep-read
type: change
title: "完成用户第二批七篇已选论文精读"
tags: [change, research, visual-token-pruning, source]
date: 2026-10-10
change_type: Changed
status: active
---

# 本次范围与实际改动

用户已完成全部 pending 筛选，明确要求精读当前 selected。本轮启动时实际表格为 pending 0、selected 7、skipped 78、deferred 1、ingested 20；旧页首快照仍写 pending 40。本轮只执行所选七篇的 paper-ingestion，不执行新检索，不改查询、每批十篇上限或自动任务。

## 笔记与来源

新建六篇笔记，升级既有 SAP 笔记并保留仓库略读历史。七项达到 deep-read / source-checked，方法、实验条件、消融、关键定位及迁移假设分开；未运行代码或实验，不标 reproduced，不创建新 concept，不改正式 motivation 或 Cx 主方案。

- 2610.11251v1 / `paper-arxiv-2610-11251`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-jiang-vcola.md|V-CoLA]]；新建笔记。
- 2610.09703v1 / `paper-wang-2026-sap`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md|SAP]]；升级既有笔记。
- 2610.09313v1 / `paper-arxiv-2610-09313`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-shi-small-objects-safe-zoom.md|小目标与安全放大]]；新建笔记。
- 2610.09252v1 / `paper-arxiv-2610-09252`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-jeong-refit.md|ReFIT]]；新建笔记。
- 2610.07987v1 / `paper-arxiv-2610-07987`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-feng-visionweave.md|VisionWeave]]；新建笔记。
- 2610.07729v1 / `paper-arxiv-2610-07729`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-han-foveated-compression.md|Foveated Compression]]；新建笔记。
- 2610.04225v1 / `paper-arxiv-2610-04225`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-zhu-flashgaze.md|FlashGaze]]；新建笔记。

复用全部来源 ID，登记实际获取日期、许可、本地 HTML 和 SHA256；完整 PDF 用同一来源的 local_artifacts 保存。SAP 的原仓库 URL、作者仓库会议说明和历史题录依据保留，论文许可与代码许可分开。所有原件保持下载字节，不改写；不以 HTTP 200 代替完整传输成功。

## 原件覆盖

| arXiv v1 | 完整 HTML | 完整 PDF |
|---|---|---|
| 2610.11251 | [完整原件](https://arxiv.org/html/2610.11251v1) | [完整原件](https://arxiv.org/pdf/2610.11251v1) |
| 2610.09703 | [完整原件](https://arxiv.org/html/2610.09703v1) | 本次未取得完整 PDF；HTML 全文已读取 |
| 2610.09313 | [完整原件](https://arxiv.org/html/2610.09313v1) | [完整原件](https://arxiv.org/pdf/2610.09313v1) |
| 2610.09252 | [完整原件](https://arxiv.org/html/2610.09252v1) | [完整原件](https://arxiv.org/pdf/2610.09252v1) |
| 2610.07987 | [完整原件](https://arxiv.org/html/2610.07987v1) | 本次未取得完整 PDF；HTML 全文已读取 |
| 2610.07729 | [完整原件](https://arxiv.org/html/2610.07729v1) | 本次未取得完整 PDF；HTML 全文已读取 |
| 2610.04225 | [完整原件](https://arxiv.org/html/2610.04225v1) | 本次未取得完整 PDF；HTML 全文已读取 |

七份 HTML 均含完整 article.ltx_document，方法、表格与相关附录可访问。完整 PDF 须同时通过下载退出码、PDF 文件头/EOF 与全页解析；关键页另行视觉核查。PDF 传输超时不会使已读完整 HTML 变成摘要阅读。SAP PDF 三次120秒传输超时；VisionWeave PDF 大小约36 MB，多次超时后停止可选补充下载；未完成缓存不收入 raw。Foveated/FlashGaze 的 PDF 补充各限定一次60秒请求。具体实际结果如下，不伪造未获得的页码。

## 获取请求记录

| UTC 请求结束/取消时刻 | 官方请求 | HTTP | 进程结果 | 缓存字节数 |
|---|---|---|---|---|
| 2026-10-10T07:37:04Z | [html/2610.11251v1](https://arxiv.org/html/2610.11251v1) | 200 | 0 | 444987 |
| 2026-10-10T07:37:32Z | [html/2610.09703v1](https://arxiv.org/html/2610.09703v1) | 200 | 0 | 372597 |
| 2026-10-10T07:38:38Z | [html/2610.09313v1](https://arxiv.org/html/2610.09313v1) | 200 | 0 | 1130995 |
| 2026-10-10T07:38:44Z | [html/2610.09252v1](https://arxiv.org/html/2610.09252v1) | 200 | 0 | 115074 |
| 2026-10-10T07:39:06Z | [html/2610.07987v1](https://arxiv.org/html/2610.07987v1) | 200 | 0 | 341343 |
| 2026-10-10T07:39:21Z | [html/2610.07729v1](https://arxiv.org/html/2610.07729v1) | 200 | 0 | 255593 |
| 2026-10-10T07:39:42Z | [html/2610.04225v1](https://arxiv.org/html/2610.04225v1) | 200 | 0 | 292751 |
| 2026-10-10T07:41:46Z | [pdf/2610.11251v1](https://arxiv.org/pdf/2610.11251v1) | 200 | 28 | 1652721 |
| 2026-10-10T07:43:22Z | [pdf/2610.11251v1](https://arxiv.org/pdf/2610.11251v1) | 206 | 0 | 3160737 |
| 2026-10-10T07:45:25Z | [pdf/2610.09703v1](https://arxiv.org/pdf/2610.09703v1) | 200 | 28 | 1867490 |
| 2026-10-10T07:47:29Z | [pdf/2610.09703v1](https://arxiv.org/pdf/2610.09703v1) | 206 | 28 | 3749298 |
| 2026-10-10T07:49:32Z | [pdf/2610.09703v1](https://arxiv.org/pdf/2610.09703v1) | 206 | 28 | 4896178 |
| 2026-10-10T07:50:25Z | [pdf/2610.09313v1](https://arxiv.org/pdf/2610.09313v1) | 200 | 0 | 802814 |
| 2026-10-10T07:52:29Z | [pdf/2610.09252v1](https://arxiv.org/pdf/2610.09252v1) | 200 | 28 | 1718700 |
| 2026-10-10T07:52:55Z | [pdf/2610.09252v1](https://arxiv.org/pdf/2610.09252v1) | 206 | 0 | 1823443 |
| 2026-10-10T07:54:58Z | [pdf/2610.07987v1](https://arxiv.org/pdf/2610.07987v1) | 200 | 28 | 1405861 |
| 2026-10-10T07:57:01Z | [pdf/2610.07987v1](https://arxiv.org/pdf/2610.07987v1) | 206 | 28 | 3456854 |
| 2026-10-10T07:58:18Z | [pdf/2610.07987v1](https://arxiv.org/pdf/2610.07987v1) | unrecorded | cancelled | 3981142 |
| 2026-10-10T07:59:28Z | [pdf/2610.07729v1](https://arxiv.org/pdf/2610.07729v1) | 200 | 28 | 914859 |
| 2026-10-10T08:00:31Z | [pdf/2610.04225v1](https://arxiv.org/pdf/2610.04225v1) | 200 | 28 | 941572 |

进程结果0表示完整请求成功，28为curl传输超时；206为断点续传响应。cancelled表示本次停止的在途PDF补充，HTTP未记录，不虚构状态。错误诊断：

- 2610.11251v1（2026-10-10T07:41:46Z）：curl: (28) Operation timed out after 120009 milliseconds with 1652721 out of 3160737 bytes received 
- 2610.09703v1（2026-10-10T07:45:25Z）：curl: (28) Operation timed out after 120013 milliseconds with 1867490 out of 11168367 bytes received 
- 2610.09703v1（2026-10-10T07:47:29Z）：curl: (28) Operation timed out after 120014 milliseconds with 1881808 out of 9300877 bytes received 
- 2610.09703v1（2026-10-10T07:49:32Z）：curl: (28) Operation timed out after 120000 milliseconds with 1146880 out of 7419069 bytes received 
- 2610.09252v1（2026-10-10T07:52:29Z）：curl: (28) Operation timed out after 120002 milliseconds with 1718700 out of 1823443 bytes received 
- 2610.07987v1（2026-10-10T07:54:58Z）：curl: (28) Operation timed out after 120010 milliseconds with 1405861 out of 36001939 bytes received 
- 2610.07987v1（2026-10-10T07:57:01Z）：curl: (28) Operation timed out after 120003 milliseconds with 2050993 out of 34596078 bytes received 
- 2610.07987v1（2026-10-10T07:58:18Z）：停止可选 PDF 补充传输：36,001,939 字节文件多次120秒超时，完整 HTML 已取得；该在途请求未返回完整诊断。
- 2610.07729v1（2026-10-10T07:59:28Z）：curl: (28) Operation timed out after 60011 milliseconds with 914859 out of 2171340 bytes received 
- 2610.04225v1（2026-10-10T08:00:31Z）：curl: (28) Operation timed out after 60015 milliseconds with 941572 out of 20504488 bytes received 

## 导航、状态与保留边界

更新 reading-log 与 comparison 的独立第二批七篇小节及来源列表，项目 overview 的入口合并展示当日六篇＋七篇；旧六篇精读和 C5 历史结果保留。候选索引只在笔记通过首次校验后将本次 selected 晋升 ingested；逐行写入前重新读取，不覆盖其他 skipped/deferred/ingested 决定、命中日期、候选中文摘要筛查理由或排除表。watch/overview 将旧队列统计明确为当时快照，并增加当前状态。

当前晋升/校验：已将本批七项晋升 ingested；pending 0、selected 0、skipped 78、deferred 1、ingested 27，基础ID合计223且唯一。

## 主要判断与证据缺口

- Foveated 的学得单区选择弱于强整图缩放，question输入消融不支持文本价值；用于 Cx 的近邻反证，不改为本地结果。
- VisionWeave 为新粒度机制，主训练off-policy，保留用户选择；并发长视频SGLang吞吐不能外推小图Guard。
- SAP 更正“62%”口径；生成拒答、attention entropy与独立Guard安全分开，理论无条件安全推论未得到证明。
- V-CoLA 的跨层平均率与early exit预算重分配、prefill/E2E分开；ReFIT缺训练阈值和实测时延；FlashGaze保留第一帧豁免和长视频计时范围。
- 小目标论文的R/M召回单调性假设、FP与覆盖条件不提供政策Guard保证；其多调用成本不能写成加速。

不需要用户重新确认选择。方法复现、模型权重/代码发布状态、政策Guard收益与服务实现是后续可选研究，本次不自动执行。

## Wiki 收尾

wiki-finalize 校验 PASS：0 errors、2 warnings。历史警告为旧实验 raw/20260907-token-prune.md 指向缺失的 20260902-xguard-ghosted-layer-recovery/README.md，以及 2026-08-25-design-safety-compression-experiments.md 未从 CHANGELOG 链接；未改写不相关历史记录。

人工业务核验：223个候选基础ID唯一、全部来源引用存在，27个ingested均有deep-read且source-checked/reproduced笔记。本批7项来源及10个完整原件SHA256核对通过，216个其他候选行逐字保持（不计换行编码）。未执行Git。

完整PDF页数/视觉核查：V-CoLA16页（第16页表8–10）、小目标论文44页（第20页表3/图6）、ReFIT5页（第3页表1）；七份HTML完整。共20条获取/取消记录：10次完整传输、9次超时、1次取消，未遇HTTP429。

首次校验曾因UTF-8无BOM的sources.yaml被Windows PowerShell按本地编码读取而漏识别VisionWeave来源；恢复UTF-8 BOM后通过。登记字段本身存在且合法，没有修改校验器或重建来源ID。
