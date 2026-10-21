---
id: visual-token-pruning-watch-overview
type: index
title: "视觉 Token 剪枝：近期论文追踪"
tags: [index, research, visual-token-pruning]
status: active
created: 2026-09-16
updated: 2026-10-21
---

# 近期论文入口

- [[LLM-Wiki/research/visual-token-pruning/watch/candidates.md|浏览候选与选择精读]]
- [[LLM-Wiki/research/visual-token-pruning/watch/runs.md|检索批次与覆盖情况]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|研究项目与当前主线]]
- [[LLM-Wiki/metadata/workflows/arxiv-watch.md|去重、人工筛选和晋升规则]]

## 2026-10-21：用户选定三篇的精读

用户已完成10篇推荐的筛选，实际为三篇selected、另外七篇skipped。本轮完成[[LLM-Wiki/research/visual-token-pruning/papers/2026-balaji-qart.md|QART]] / [[LLM-Wiki/research/visual-token-pruning/papers/2026-li-paa-bench.md|PAA-Bench]] / [[LLM-Wiki/research/visual-token-pruning/papers/2026-li-visual-sufficiency-landscapes.md|Visual Sufficiency Landscapes]]的公开正文及附录精读，复用来源ID并登记完整本地原件。理由与笔记使用通俗中文，方法证据、计时条件与当前整图分辨率方案的迁移假设分开；未执行新检索或自动推荐。

首次Wiki校验PASS后，三篇已晋升ingested。当前pending0、selected0、skipped91、deferred1、ingested33；全部294个基础ID、28篇备查和141条排除保持。最近收集仍为2026-10-20的complete批次。

## 2026-10-20：最近运行

冻结窗口2026-10-10T02:05:17Z至2026-10-20T02:05:17Z。四组API均HTTP200，各一页全部取完；100条命中合并61个窗口内唯一ID，4篇既有候选保留人工决定。新题录57篇，其中20篇direct、18篇adjacent、19条排除；符合主题38篇，按标题摘要的潜在价值与方法设计推荐10篇pending，其余28篇放相关备查，不设人工决定、不会自动回流pending。理由均为中文，在线策略蒸馏排除规则与每批十篇上限保持。

仅标题摘要筛查，均discovered / unverified，不执行精读。查询覆盖与批次状态complete，Wiki校验PASS（0错误、2项既有警告）；见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-20-020517Z.md|本批日志与推荐顺序]]。当前pending10、selected0、skipped84、deferred1、ingested30；294个基础ID保留，备查28。无超过十天的窗口外缺口，历史partial日志不覆盖。

## 2026-10-16：用户选定两篇的精读

收集后用户只选SAVER与TwinPrune，另外两篇skipped。两篇公开正文已完成精读，见 [[LLM-Wiki/research/visual-token-pruning/papers/2026-huang-saver.md|SAVER]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-liu-twinprune.md|TwinPrune]]；TwinPrune官方源包确认附录被作者省略，相关证明与补充实验未核验。来源ID复用，完整原件仅本地保留。本次不重启检索，最近收集仍为partial。

首次Wiki校验PASS后已将两篇晋升ingested。当前pending 0、selected 0、skipped 84、deferred 1、ingested 30；237个基础ID和其他人工决定保留。

## 2026-10-16：最近运行

冻结窗口为2026-10-06T02:01:21Z至2026-10-16T02:01:21Z。q1首个API请求返回HTTP429，正文为Rate exceeded.且未给Retry-After，已停止API请求。八条网页回退查询合并取得7个可见唯一ID，官方abs页核验后6篇在窗内，其中4篇新direct候选已加入pending、2篇为既有候选；另1篇首次提交在窗外，不改最近命中日期。新增来源4条、备查0，不执行精读。符合主题仅4篇，未触及每批10篇上限；理由均为中文，并保留既有人工决定。

覆盖仍为partial，不能据此判断该窗口已查全。最近完整批次仍截止2026-10-13T02:01:29Z；本次窗口与其重叠，无停跑超过10天的窗口外缺口。详情见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-16-020121Z.md|本批次日志]]。

## 2026-10-13：前次完整检索与精读

已沿用2026-10-03T02:01:29Z至2026-10-13T02:01:29Z的冻结窗口重试。四组API均首次请求成功（HTTP200），每组唯一结果页已完整读取；92条命中合并为55个唯一ID，其中45篇既有候选保留人工决定，新增4篇direct、1篇adjacent进入pending，另5篇范围外命中仅作查重记录。全库新增10条来源；既有排除记录2610.11205实际观测版本更新为v2，不改筛查决定。符合主题共5篇，未触及每批10篇上限，相关备查0。覆盖complete，补足此前partial批次；未精读、未下载PDF。见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-13-020129Z-retry1.md|成功重试日志]]；[[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-13-020129Z.md|原限流与回退日志]]保留。

同日用户完成本批筛选，仅选SheafPrune，其余四篇skipped；现已按明确请求完成[[LLM-Wiki/research/visual-token-pruning/papers/2026-ma-sheafprune.md|SheafPrune精读笔记]]，核验正文与附录、登记原件并在校验后晋升ingested。当前pending 0、selected 0、skipped 82、deferred 1、ingested 28；所有233个候选ID和原始批次日志保留，本轮不检索新论文。

首轮论文收集已于 2026-09-16 执行，窗口为 2026-09-06 08:47:38 至 2026-09-16 08:47:38 UTC：10 篇直接相关、7 篇相邻、1 篇待核验、14 篇排除命中，收集时均为 discovered 候选。用户同日指定的 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|StackTok]] 已完成精读晋升；后续人工决定与精读晋升以候选索引为准。首轮结果见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-16-084738Z.md|日志]]。已有论文、笔记和专题综合保持原结构，继续按全库来源去重，不批量迁移历史论文。

最近运行：2026-09-22 定时批次 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-22-052619Z|2026-09-22-052619Z]]；四组 API 均完整读取首个也是唯一一个结果页，60 条原始命中合并为 39 个唯一 ID，新增 6 篇 direct、6 篇 adjacent 与 12 篇 out-of-scope 候选，15 个既有候选复用来源并保留人工决定。覆盖 complete；与 2026-09-16 完整批次的重叠也补足了 2026-09-18 partial 批次的时间区间，该批次后共有 31 篇相关、相邻或待核验候选供浏览。

2026-09-24 完成用户选定的 [[LLM-Wiki/research/visual-token-pruning/papers/2026-bozkurt-slicechat.md|SLICEChat]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-foundation-me-vlm.md|ME-VLM]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-lv-vprune.md|VPRune]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-peng-countercredit.md|CounterCredit]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 精读，候选状态已改为 ingested。当时相关表没有 pending；31 条 out-of-scope 排除命中继续永久保留，但不再占用人工决定队列。

2026-09-25 定时批次 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-25-115723Z.md|2026-09-25-115723Z]] 完整读取四组 arXiv API 的唯一结果页：62 条原始命中合并为 41 个唯一 ID，26 个既有候选复用来源并保留人工决定；新增 4 篇 direct、1 篇 adjacent 的 pending 候选及 10 条仅用于去重的 out-of-scope 记录。覆盖 complete，无超出 10 天的历史缺口；该批次收集后相关候选为 36 篇、其中 5 篇当时待用户选择。

同日用户从本次候选中选定并完成 [[LLM-Wiki/research/visual-token-pruning/papers/2026-bond-task-induced-metrics.md|Riemannian Metrics]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-he-coreprune.md|CoRePrune]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-std.md|STD]] 精读；三项已标记 ingested。用户将另外两篇新候选标记为 skipped，当前没有 pending；精读结论见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md|阅读日志]]。

2026-10-03 收集批次 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-03-074539Z.md|2026-10-03-074539Z]] 完整覆盖十天窗口：177 条原始命中合并为 102 个唯一 ID，其中 9 个既有候选、93 个新来源。当次初筛新增 21 篇 direct、26 篇 adjacent、46 篇 out-of-scope；批次结束时相关候选为 83 篇，其中 47 篇 pending。原有用户决定未被覆盖，也未自动精读。此后用户完成部分筛选，并要求将以在线策略蒸馏为主要贡献的论文排除；当时相关候选为 78 篇（其中 3 篇 selected、30 篇 pending），另有 92 篇排除命中仅用于查重。批次日志保留当时的筛查快照，不追改历史结果。

2026-10-08 原定时窗口第一次检索遇到 HTTP 429，见[[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-08-020043Z.md|失败日志]]；随后按同一冻结窗口[[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-08-020043Z-retry1.md|重试]]并完成五页覆盖。186 条原始命中合并为 104 个唯一 ID，65 个既有候选保留决定；新增 11 篇 direct、12 篇 adjacent、16 篇 out-of-scope，其中 SAP 复用既有来源，另新增 38 条全库来源。当时相关候选 101 篇，其中 35 篇 pending、6 篇 selected；108 篇排除命中仅用于查重。本次只完成标题和摘要筛查，未自动精读。

2026-10-10 按[[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-09-020526Z-retry1.md|原失败窗口重试]]取回全部五页：161 条命中、95 个唯一 ID、81 篇既有候选与 14 篇新来源；标题摘要初筛新增 3 篇 direct、2 篇 adjacent 的 pending 和 9 篇排除。符合主题仅 5 篇，未触及每批 10 篇的新增上限。

同日第一轮完成当时六篇 selected 的精读，见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md|阅读日志]]；该轮结束时索引为 40 篇 pending、20 篇 ingested，相关备查 0 篇。这是当时快照，后续决定以候选索引为准。

2026-10-10 第二轮：用户完成全部 pending 筛选后，精读 V-CoLA、SAP、小目标与安全放大、ReFIT、VisionWeave、Foveated Compression、FlashGaze 七项 selected。六篇新建笔记、SAP升级既有略读；七项均 deep-read / source-checked，并在首次校验通过后晋升 ingested。当前 pending 0、selected 0、skipped 78、deferred 1、ingested 27，相关备查 0；223 个基础ID仍完整保留，排除表不设决定状态。本轮不执行新检索或修改推荐规则。见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md|阅读日志]]与[[LLM-Wiki/changes/2026-10-10-selected-watch-second-batch-deep-read.md|原件与校验记录]]。

## 固定配置

| 项目 | 默认值 |
|---|---|
| project | visual-token-pruning |
| 主要来源 | arXiv API；失败时可用 arXiv 页面辅助发现并标 partial |
| 时间窗 | 每次启动 UTC 时刻向前滚动 10 天，按首次提交日期 |
| 定时频率 | 每周二、周五 10:00，Asia/Shanghai；最近完整执行批次 2026-10-20（四组各一页） |
| 阅读深度 | discovered；标题与摘要相关性确认 |
| 分页预算 | 每组 50 条/页，最多 2 页；达到上限且未取完则 partial |
| 筛查预算 | 每次最多 100 篇此前未筛查的唯一命中；不足覆盖时记录剩余 ID |
| pending 新增上限 | 每批最多 10 篇；超过时只用标题与摘要按潜在影响力、方法设计和项目价值排序，未入选相关论文保留在备查表 |
| 索引语言 | 相关候选与排除条目的一句话理由使用中文；论文原标题、方法名和固定分类值保留原文 |
| 通知 | 新 direct / adjacent / uncertain 候选、重要失败或待用户判断时通知；无变化保持安静 |

搜索和筛查预算控制检索成本；pending 新增上限控制每批交给用户筛选的推荐数量。预算内已筛查的命中全部保留查重记录，其中符合主题的前十篇进入 pending，其余相关论文进入无人工决定字段的备查表，范围外论文进入排除表。不得为凑满十篇放宽主题，也不回溯清理原有 pending。

2026-10-10 起执行用户指定的新规：排序只依据标题和摘要中的方法新意、可迁移范围、部署价值、证据具体程度及对当前政策条件视觉选择的启发，不为初筛精读全文，不根据作者名气或最大加速数字决定。日志保存推荐顺序和中文理由；潜在影响力均标为 agent 初筛判断。具体执行与备查条目的查重规则见 [[LLM-Wiki/metadata/workflows/arxiv-watch.md]]。

## 主题边界

direct：视觉 token / patch 的 pruning、sparsification、merging、compression、selection、reduction；包括 ViT/视觉编码器与自回归 VLM/MLLM 的图像和视频理解，不要求方法必须面向安全任务。

adjacent：与视觉预算直接关联且提供可迁移选择机制的训练/蒸馏、浅层视觉前缀、多分辨率压缩、证据保留、压缩引发的安全或鲁棒性失败、视觉剪枝实测时延与评测。安全方向用于提高浏览优先度，不作为漏掉通用剪枝进展的硬门槛。

out-of-scope：仅权重/通道剪枝或量化、仅文本上下文/KV 压缩、无视觉 token 机制的通用 serving、仅扩散生成加速。确有可迁移视觉 token 机制时可判 adjacent，理由说明迁移假设；不根据摘要推导正式研究缺口。

依用户 2026-10-03 的筛选要求，**以在线策略蒸馏或在线自蒸馏为主要贡献**、仅让模型适应既定稀疏帧、固定压缩上下文或预设视觉 token 预算的论文，判为 out-of-scope；即使摘要出现 visual token pruning / reduction / compression 字样，也不进入人工待筛选队列。若摘要明确提出新的推理时视觉 token／patch 选择、剪枝、合并或预算分配机制，则按该机制判断 direct / adjacent，并在理由中说明。此规则在 q1–q4 结果合并后的标题与摘要筛查阶段执行，保留排除命中供以后去重；不靠关键词排除整组检索结果，以免漏掉真正的剪枝方法。

out-of-scope 命中进入候选索引的独立排除表，不设 `pending` 等人工决定状态，也不计入待筛选数量。它们只保留基础 ID、题录与排除理由供后续检索去重；如果用户要求重审，再移入相关候选表并设为 `pending`。

## 查询组（q1–q4）

每组表达式加上 `AND submittedDate:[<UTC-start> TO <UTC-end>]`，做 URL 编码，排序 `submittedDate / descending`。词项仅限标题/摘要，不扫描全部 cs.CV 新论文。以下初始查询已在 2026-09-16 首轮 API 运行中成功返回，四组结果均未触及分页上限；术语召回仍需按漏检案例持续检验。

```text
q1 = (ti:"visual token" OR abs:"visual token") AND (ti:pruning OR abs:pruning OR ti:prune OR abs:prune OR ti:sparsification OR abs:sparsification OR ti:compression OR abs:compression OR ti:merging OR abs:merging OR ti:reduction OR abs:reduction OR ti:selection OR abs:selection)

q2 = (ti:"vision transformer" OR abs:"vision transformer" OR ti:"vision encoder" OR abs:"vision encoder") AND (ti:token OR abs:token OR ti:patch OR abs:patch) AND (ti:pruning OR abs:pruning OR ti:merging OR abs:merging OR ti:slimming OR abs:slimming OR ti:reduction OR abs:reduction)

q3 = (ti:"vision-language" OR abs:"vision-language" OR ti:multimodal OR abs:multimodal OR ti:VLM OR abs:VLM OR ti:MLLM OR abs:MLLM OR ti:"video understanding" OR abs:"video understanding") AND (ti:token OR abs:token OR ti:patch OR abs:patch) AND (ti:pruning OR abs:pruning OR ti:compression OR abs:compression OR ti:merging OR abs:merging OR ti:budget OR abs:budget OR ti:reduction OR abs:reduction)

q4 = (ti:visual OR abs:visual OR ti:vision OR abs:vision) AND (ti:token OR abs:token OR ti:patch OR abs:patch OR ti:prefix OR abs:prefix) AND (ti:distillation OR abs:distillation OR ti:safety OR abs:safety OR ti:robustness OR abs:robustness OR ti:evidence OR abs:evidence) AND (ti:pruning OR abs:pruning OR ti:compression OR abs:compression OR ti:budget OR abs:budget OR ti:shallow OR abs:shallow)
```

检索语法依据 [arXiv API 文档](https://info.arxiv.org/help/api/user-manual.html)；若服务拒绝表达式，拆成等价的明确词项查询并在日志记录实际表达式，不默默扩大为全部视觉论文。后续按漏检和不相关命中的案例调整这些查询；本轮未改变表达式。

## 日常操作

收集：`用 $arxiv-watch 收集 visual-token-pruning 近 10 天 arXiv 新论文。`

选择：浏览 candidates.md 的“相关、相邻与待核验候选”表，将决定改成 selected / deferred / skipped 并注明日期；或让 agent 按你提供的 ID 更新。例如：`用 $arxiv-watch 把候选索引里我给出的两个 arXiv ID 标为 selected，其余决定保持。` 排除表不需要人工清理 pending；其行永久保留用于去重。

精读：`用 $arxiv-watch 精读 visual-token-pruning 已选列表。` 此模式转交 paper-ingestion；不与例行收集自动串联。成功收录后候选保留，链接 papers 笔记，便于检索时继续去重。

## 定时维护建议

在当前本地任务上使用每周二、周五 10:00 的定时跟进，让每次运行读取此配置与持久索引。直接使用 Contrail 本地目录，避免去重状态散落到多个临时 worktree；运行前读取最新候选表，写入前重新读取受影响区域，以保留同时发生的人工筛选修改。另一个收集任务正在写入时，本次延期并记录原因。

定时提示保持简短：

> 在 D:/SPPPAAACCCEEE/Contrail 使用 $arxiv-watch 的 collect 模式，为 visual-token-pruning 检索滚动 10 天内首次提交的 arXiv 论文。读取 watch/overview.md 的查询与预算，按 workflow-arxiv-watch 登记 discovered 候选、全库去重并保存批次覆盖日志。保留用户筛选决定；每次最后执行 wiki-finalize。只在有新增相关候选、重要失败或需要人工判断时通知，无变化保持安静。

本地文件任务运行时需要电脑开机、桌面 app 运行且项目可访问，调度不会代替持久日志与补检。[OpenAI 定时任务文档](https://learn.chatgpt.com/docs/automations?surface=app)
