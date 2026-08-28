---
id: change-2026-08-27-survey-task-aligned-pruning-importance
type: change
title: 调研多模态安全判别的任务对齐剪枝指标
tags: [metadata, research, structured-pruning, multimodal-safety]
date: 2026-08-27
change_type: Added
---

# 调研多模态安全判别的任务对齐剪枝指标

- 登记并核验 BlockPruner、ShortGPT、LLM-Pruner、FLAP、UPop 与 Movement Pruning。
- 新增五份论文笔记与一份专题综合，比较真实任务消融、激活、`weight × activation`、raw gradient、Taylor/Fisher 和 learnable mask。
- 将首选方案收敛为 `forward proxy → task Taylor/Fisher → iterative true ablation`，并为视觉、文本、跨模态连接器和安全输出分别定义校准与验收切片。
- 明确三级方案属于跨论文综合建议，尚无多模态安全 Guard 的直接全指标对照证据。
