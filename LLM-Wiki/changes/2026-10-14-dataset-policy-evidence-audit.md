---
id: change-2026-10-14-dataset-policy-evidence-audit
type: change
title: "局部视觉证据与条件短政策的数据审计"
tags: [metadata, research, data]
date: 2026-10-14
change_type: Added
---

# 局部视觉证据与条件短政策的数据审计

新增综合 [[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]]，以用户2026-10-13阶段总结为当前证据，修正full全局档位与Global100含义、局部使用率和政策长度口径。新增四篇skimmed/source-checked笔记：

- [[LLM-Wiki/research/visual-token-pruning/papers/2024-helff-llavaguard.md]]。
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-qu-unsafebench.md]]。
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-bao-vmoda.md]]。
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-hang-malicious-image-localization.md]]。

新增九个来源ID（报告、四论文、三数据、tokenizer），复用SafeEditBench/PolicyShiftBench来源和精读笔记。原始汇总保存逐字节txt快照；原文和旧实验未修改。`raw/dataset-audit-20261014/`保存公开例图、四张Open Images图、数据规则/manifest、官方tokenizer与哈希；`output/research/20261014-dataset-audit/`保存采样/计数脚本、作者/对象标注、下载状态、三份新政策全文和候选图文审阅样本。

修改：raw/sources.yaml、项目overview、reading-log、comparison、landscape、index/tags.md、CHANGELOG.md。标签复用既有词表，只重核本轮四种受影响技术标签计数与论文总数，不修改其他标签统计或schema。

数据观察仅来自展示图和定向四图抽样；不统计原工作集难度比例。新政策168/164/172-token（政策＋任务文本，无chat wrapper）；新样本A/G为待独立人审的候选判定，不是原数据gold。新政策改变语义边界，标签必须重算；未修改训练/测试集、Guard、Router、配置或正式motivation，未执行模型实验或Git操作。

剩余决定：明确条件/例外/多类优先级；审定候选图标签；确认可用gated数据；先用部署Guard分离局部收益，再扩规模。校验结果与既有警告在任务交付记录中报告。
