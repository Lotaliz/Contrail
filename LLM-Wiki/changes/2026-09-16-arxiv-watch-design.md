---
id: change-2026-09-16-arxiv-watch-design
type: change
title: "建立视觉 Token 剪枝近期论文追踪方案"
tags: [metadata, research, visual-token-pruning]
date: 2026-09-16
change_type: Added
---

# 实际变化

- 新增 discovered 模式的 arXiv 追踪流程与批次模板，项目增加 watch 配置、空候选索引和空批次导航。
- 设计全库来源去重、10 天滚动首次提交窗口、分页/筛查预算、失败与补检记录，以及用户确认后经 paper-ingestion 精读晋升的规则。
- 仓库 arxiv-watch skill 调用权威流程，提供收集、按用户决定更新筛选和启动已选论文精读三个入口。
- 项目入口、reading-log、工作流索引、研究索引与维护规则增加导航；来源表登记实际查阅的 arXiv / OpenAI 官方文档。
- 没有收集论文、创建论文笔记、迁移历史来源或修改研究证据；每周二、周五 10:00 为可审核的调度建议，尚未启用。
- 复用现有 Schema、标签与文档类型；业务筛选决定和批次覆盖状态只在正文使用。

## 人工选择与覆盖边界

研究者决定具体精读列表与调度是否启用。查询尚待首轮实际运行检验；关键词可能漏检，预算截断必须标 partial，超过 10 天的停跑区间需要显式补检。

配置与日常操作见 [[LLM-Wiki/research/visual-token-pruning/watch/overview.md]]；标准规则见 [[LLM-Wiki/metadata/workflows/arxiv-watch.md]]。

## 文件清单

新增 8 个文件：

- `LLM-Wiki/metadata/workflows/arxiv-watch.md`
- `LLM-Wiki/research/visual-token-pruning/watch/overview.md`
- `LLM-Wiki/research/visual-token-pruning/watch/candidates.md`
- `LLM-Wiki/research/visual-token-pruning/watch/runs.md`
- `LLM-Wiki/templates/arxiv-search-run.md`
- `LLM-Wiki/changes/2026-09-16-arxiv-watch-design.md`（本页）
- `.agents/skills/arxiv-watch/SKILL.md`
- `.agents/skills/arxiv-watch/agents/openai.yaml`

修改 7 个文件：

- `LLM-Wiki/research/visual-token-pruning/overview.md`
- `LLM-Wiki/research/visual-token-pruning/reading-log.md`
- `LLM-Wiki/research/README.md`
- `LLM-Wiki/metadata/workflows/README.md`
- `LLM-Wiki/metadata/maintenance.md`
- `LLM-Wiki/raw/sources.yaml`
- `LLM-Wiki/CHANGELOG.md`

## 验证与保留问题

arxiv-watch skill 通过 quick_validate；Wiki validator 通过，0 错误。保留改动前就存在的两条警告：旧实验原始笔记指向缺失的 `20260902-xguard-ghosted-layer-recovery/README.md`，以及 `2026-08-25-design-safety-compression-experiments.md` 没有 CHANGELOG 导航。两项不属于本次维护方案，不改写原始记录。

当前候选表为空，无虚构论文、检索批次或测量；新增来源仅为实际查阅的两个官方文档。查询表达式尚未做首轮线上检索验证，调度建议卡尚待研究者启用。
