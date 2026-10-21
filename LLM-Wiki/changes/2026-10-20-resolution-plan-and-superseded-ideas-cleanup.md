---
id: change-2026-10-20-resolution-plan-and-superseded-ideas-cleanup
type: change
title: "整图分辨率研究方案与废弃思路清理"
tags: [change, research, visual-token-pruning]
date: 2026-10-20
change_type: Changed
status: active
---

# 整图分辨率研究方案与废弃思路清理

## 授权与范围

用户明确要求将当前三个问题整理为新的独立 Markdown，从原任务场景出发，并删除废弃思路。执行前已在会话列明以下六个方案文件。本次只清理这些方案，不删除实验记录、论文笔记、原件、数据样例、政策草案或配置；未使用 Git。

## 新的研究入口

[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|政策文本指导图像安全审核的自适应分辨率]]从任务、输入输出和真实时延目标开始，独立说明信息读取、表征保留、决策作用三个问题，以及它们与轻量整图分辨率选择的关系。不以历史 C5/Cx、局部框或其他方案作为理解前提。

正文区分已有文献、会话中的用户报告和待验证假设。75/40 Token、插值恢复和 PolicyShiftBench 60 Token 观察未在本次重跑，逐样本产物未复核；没有将方案或内部归因升级为实验事实。没有新增模型运行、训练或精读完成声明。

## 删除的废弃方案：精确清单（6）

以下以普通路径记录已删除文件，不建立指向不存在文件的链接：

1. `LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md`：以模板短政策和首轮视觉基线为主的旧总方案，由新的自包含方案替代。
2. `LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md`：固定低预算与单局部框的条款路由、几何和反事实优化方案。
3. `LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md`：旧 5% 路线与高清升级门及全局/局部联合路线方案。
4. `LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md`：全局与单局部框配置分类及最小充分配置方案。
5. `LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md`：全局收益与条件局部收益双网络方法方案。
6. `LLM-Wiki/research/visual-token-pruning/cx-policy-safety-representation-pruning.md`：以政策条件空间证据接回单框 Cx 的安全表征分支方案。

删除不表示历史实验证据无效，也不撤销论文原有发现。必要的原生视觉塔不读政策、探针可读性不等于决策贡献、离线教师不等于在线免费特征等边界，已在新方案中独立说明。

## 保留与链接处理

- 保留 `experiments/` 的实际结果、负结果、配置和原始资料；涉及旧方案的 README 链接改向本清理记录，并注明历史用途。记录内容不改写成新方案已经运行。
- 保留 `dataset-local-evidence-policy-expansion.md` 的公开样例核查、政策草案和来源证据，标为历史资料，不再作为当前扩数或局部路线执行建议。
- 保留 `region-rationale-guided-safety-token-pruning.md` 及其他论文综述、实现说明，注明区域设计的历史适用范围。
- 保留 FastV、VisionZip、CDPruner 等比较，以及 VisionThink、AdaptVision、ZOO-Prune、FEATHER 四项待补基线；未修改其运行/阅读状态。
- 当前总方案的导航链接转到新方案；旧 C5/Cx 分支链接以及阅读日志、旧变更记录中的旧方案链接转到本页，避免以新方案冒充历史设计。论文笔记只修复关联链接和相应日期，原文事实与阅读等级不变。
- 同步视觉剪枝项目入口、研究方向索引、Wiki 首页/实体/标签导航、双路线入口和比较页的当前状态说明；历史日志保留原日期语境。
- 新方案的四项新增论文来源仅登记题录和有限核对范围，不新建论文笔记，不提高已有阅读等级。其余来源 ID 和所有原件保持原状。

## 校验与未完成项

修改前校验为 PASS，0 错误、2 项既有警告：旧 XGuard 原始记录缺失链接、2026-08-25 详细变更记录未从 CHANGELOG 链接。这两项不属于本次清理范围。

实际新增2份Markdown（研究方案与本清理记录），删除6份旧方案；同步82个既有文件，其中51份论文笔记仅修复关联链接与日期，其余为项目/实验导航、历史引用、比较页和来源登记等。没有修改论文的阅读等级或实验原始结果。来源登记文件恢复UTF-8 BOM，保证现有Windows PowerShell校验器正确读取；未修改校验器。

六个精确删除路径已检查不存在，指向它们的WikiLink已清理，新方案的内部引用仅指向论文笔记，没有依赖旧方案。完成校验为PASS，0错误、2项上述既有警告，无新增警告。

新实验的实际命令、配置、种子和算力预算在执行时记录，本次不虚构。正式实验的数值质量容忍界限仍需依据开发集和审核目标事先确定。
