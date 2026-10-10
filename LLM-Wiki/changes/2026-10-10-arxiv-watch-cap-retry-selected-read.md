---
id: change-2026-10-10-arxiv-watch-cap-retry-selected-read
type: change
title: "重试近期检索、精读已选论文并限制每批推荐量"
tags: [change, research, visual-token-pruning, source]
date: 2026-10-10
change_type: Changed
status: active
---

# 本次实际改动

用户要求重试最近失败任务、精读当前 selected，并将每批 pending 新增上限设为十篇。

## 检索与推荐规则

- 重试 [[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-09-020526Z-retry1.md|10-09 原冻结窗口]]，四组五页完整读取：161 条原始命中、95 个唯一 ID、81 个既有候选、14 个新来源。
- 初筛新增 3 篇 direct、2 篇 adjacent 的 pending；9 篇 out-of-scope 仅查重。新相关总数 5，小于十篇，不凑数量、不精读新发现论文。
- 每批上限是新增量，不改变已有 pending；超过上限时按标题摘要中的潜在价值与方法设计选前十，其余相关论文保留在无人工决定的备查表，不冒充 skipped/deferred 或范围外。
- 更新 [[LLM-Wiki/metadata/workflows/arxiv-watch.md]]、项目 [[LLM-Wiki/research/visual-token-pruning/watch/overview.md]]、批次模板和仓库 arxiv-watch skill；新增空备查表，沿用原有文档类型和状态。

## 精读与原件

复用以下六个 source_id；未运行代码、训练或复现实验。保留完整 HTML 原件作为主 local_path，PDF 作为同来源 local_artifacts；六份 HTML 与六份 PDF 均登记 SHA256。
- 2610.01640v1 / `paper-arxiv-2610-01640`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-zhao-scaling-stops.md|Scaling Stops]]；PDF 53 页，deep-read / source-checked。
- 2610.00757v1 / `paper-arxiv-2610-00757`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-guan-video-evidence-indexing.md|Video Evidence Indexing]]；PDF 21 页，deep-read / source-checked。
- 2609.39134v1 / `paper-arxiv-2609-39134`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-yan-fata.md|FATA]]；PDF 29 页，deep-read / source-checked。
- 2609.37581v1 / `paper-arxiv-2609-37581`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-trevs.md|TReVS]]；PDF 9 页，deep-read / source-checked。
- 2609.37123v1 / `paper-arxiv-2609-37123`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-niu-evivit.md|EviViT]]；PDF 23 页，deep-read / source-checked。
- 2609.34861v1 / `paper-arxiv-2609-34861`：[[LLM-Wiki/research/visual-token-pruning/papers/2026-kang-when-text-matters.md|When Text Matters]]；PDF 23 页，deep-read / source-checked。

六项原 selected 晋升为 ingested；全索引 223 个唯一基础 ID，当前 40 pending、0 selected、45 skipped、1 deferred、20 ingested，117 条排除记录与 0 条备查不带人工决定。原索引的其他状态、题录和人工批注保留。

## 导航与证据边界

新增六篇 papers 笔记、本重试日志及本 changes 记录；修改来源、候选、追踪概览/批次导航、阅读日志、比较、项目导航、流程/模板和 CHANGELOG。当前 C5 不锚定 5% 的最新设计及其他同日编辑保留；未新增 concept、motivation 或实验结果。
PDF 初次下载均因超时未完成，未将截断文件作为原件登记；续传完成后逐份解析并核对关键表。下载失败不意味着原文缺失，完整 HTML 已先保存。

## 校验

wiki-finalize：PASS，0 个错误、2 条既有警告（旧实验 WikiLink 未解析；2026-08-25 详细变更记录未从 CHANGELOG 链接）。人工核对三表 223 个唯一基础 ID、来源引用、每批 pending 上限、六份 deep-read / source-checked 笔记及十二份原件 SHA256；其他用户决定保留。skill-creator quick_validate 已通过。
