---
id: visual-token-pruning-watch-overview
type: index
title: "视觉 Token 剪枝：近期论文追踪"
tags: [index, research, visual-token-pruning]
status: active
created: 2026-09-16
updated: 2026-09-22
---

# 近期论文入口

- [[LLM-Wiki/research/visual-token-pruning/watch/candidates.md|浏览候选与选择精读]]
- [[LLM-Wiki/research/visual-token-pruning/watch/runs.md|检索批次与覆盖情况]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|研究项目与当前主线]]
- [[LLM-Wiki/metadata/workflows/arxiv-watch.md|去重、人工筛选和晋升规则]]

首轮论文收集已于 2026-09-16 执行，窗口为 2026-09-06 08:47:38 至 2026-09-16 08:47:38 UTC：10 篇直接相关、7 篇相邻、1 篇待核验、14 篇排除命中，收集时均为 discovered 候选。用户同日指定的 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|StackTok]] 已完成精读晋升；后续人工决定与精读晋升以候选索引为准。首轮结果见 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-16-084738Z.md|日志]]。已有论文、笔记和专题综合保持原结构，继续按全库来源去重，不批量迁移历史论文。

最近运行：2026-09-22 定时批次 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-09-22-052619Z|2026-09-22-052619Z]]；四组 API 均完整读取首个也是唯一一个结果页，60 条原始命中合并为 39 个唯一 ID，新增 6 篇 direct、6 篇 adjacent 与 12 篇 out-of-scope 候选，15 个既有候选复用来源并保留人工决定。覆盖 complete；与 2026-09-16 完整批次的重叠也补足了 2026-09-18 partial 批次的时间区间，当前共有 31 篇相关、相邻或待核验候选供浏览。

## 固定配置

| 项目 | 默认值 |
|---|---|
| project | visual-token-pruning |
| 主要来源 | arXiv API；失败时可用 arXiv 页面辅助发现并标 partial |
| 时间窗 | 每次启动 UTC 时刻向前滚动 10 天，按首次提交日期 |
| 定时频率 | 每周二、周五 10:00，Asia/Shanghai；最近收到 `token-arxiv` 的 2026-09-22 定时运行 |
| 阅读深度 | discovered；标题与摘要相关性确认 |
| 分页预算 | 每组 50 条/页，最多 2 页；达到上限且未取完则 partial |
| 筛查预算 | 每次最多 100 篇此前未筛查的唯一命中；不足覆盖时记录剩余 ID |
| 通知 | 新 direct / adjacent / uncertain 候选、重要失败或待用户判断时通知；无变化保持安静 |

预算控制的是搜索和筛查成本，不是“最多推荐几篇”。预算内已筛查的相关候选全部列出；不能为了凑数量丢弃或填充结果。

## 主题边界

direct：视觉 token / patch 的 pruning、sparsification、merging、compression、selection、reduction；包括 ViT/视觉编码器与自回归 VLM/MLLM 的图像和视频理解，不要求方法必须面向安全任务。

adjacent：与视觉预算直接关联的训练/蒸馏、浅层视觉前缀、多分辨率压缩、证据保留、压缩引发的安全或鲁棒性失败、视觉剪枝实测时延与评测。安全方向用于提高浏览优先度，不作为漏掉通用剪枝进展的硬门槛。

out-of-scope：仅权重/通道剪枝或量化、仅文本上下文/KV 压缩、无视觉 token 机制的通用 serving、仅扩散生成加速。确有可迁移视觉 token 机制时可判 adjacent，理由说明迁移假设；不根据摘要推导正式研究缺口。

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

选择：浏览 candidates.md，将决定改成 selected / deferred / skipped 并注明日期；或让 agent 按你提供的 ID 更新。例如：`用 $arxiv-watch 把候选索引里我给出的两个 arXiv ID 标为 selected，其余决定保持。`

精读：`用 $arxiv-watch 精读 visual-token-pruning 已选列表。` 此模式转交 paper-ingestion；不与例行收集自动串联。成功收录后候选保留，链接 papers 笔记，便于检索时继续去重。

## 定时维护建议

在当前本地任务上使用每周二、周五 10:00 的定时跟进，让每次运行读取此配置与持久索引。直接使用 Contrail 本地目录，避免去重状态散落到多个临时 worktree；运行前读取最新候选表，写入前重新读取受影响区域，以保留同时发生的人工筛选修改。另一个收集任务正在写入时，本次延期并记录原因。

定时提示保持简短：

> 在 D:/SPPPAAACCCEEE/Contrail 使用 $arxiv-watch 的 collect 模式，为 visual-token-pruning 检索滚动 10 天内首次提交的 arXiv 论文。读取 watch/overview.md 的查询与预算，按 workflow-arxiv-watch 登记 discovered 候选、全库去重并保存批次覆盖日志。保留用户筛选决定；每次最后执行 wiki-finalize。只在有新增相关候选、重要失败或需要人工判断时通知，无变化保持安静。

本地文件任务运行时需要电脑开机、桌面 app 运行且项目可访问，调度不会代替持久日志与补检。[OpenAI 定时任务文档](https://learn.chatgpt.com/docs/automations?surface=app)
