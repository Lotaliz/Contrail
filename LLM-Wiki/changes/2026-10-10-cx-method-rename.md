---
id: change-2026-10-10-cx-method-rename
type: change
title: "自适应视觉预算方法更名为 Cx"
tags: [change, research, visual-token-pruning]
date: 2026-10-10
change_type: Changed
status: active
---

# Cx 命名与文件调整

依据用户请求，当前不固定保留率的自适应视觉预算方法称为 Cx。C5 继续指原固定 5% 方法及其历史实验结果，原始报告和旧结果名称保持原状。

文件调整：

- 主方案从 `c5-global-local-importance-plan.md` 更名为 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md]]。
- 当前方法记录目录从 `20261010-c5-global-local-importance` 更名为 `20261010-cx-global-local-importance`，内容见 [[LLM-Wiki/experiments/20261010-cx-global-local-importance/README.md]]与 [[LLM-Wiki/experiments/20261010-cx-global-local-importance/defaults.yaml]]。
- 同步项目、对照、阅读日志、实验索引和既有链接。前版逐样本方案改用 Cx 展示标题，其历史文件路径保持稳定。

已有文档 ID 和 experiment_id 保持稳定；配置增加 `method_name: Cx`。`reuse_c5_preview` 明确指复用历史 C5 编码模块。收益公式、档位、模型结构及原始来源保持原有含义。
