---
id: experiment-20261010-c5-global-local-importance
type: experiment
title: "Cx 双重要性指导的逐样本视觉预算：方法记录"
tags: [experiment, visual-token-pruning, multimodal-safety, adaptive-budget]
status: archived
created: 2026-10-10
updated: 2026-10-20
---

# Cx 全局/局部重要性方法记录

> 历史方法记录（2026-10-20）：全局/局部双重要性方案已退出当前主线，见 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|六份旧方案清理记录]]。本目录配置、用户报告和未核验项保留；不表示新整图方案已经运行，也不据此判定旧实验最终成功或失败。

## 目的与假设

当前自适应预算方法称为 Cx；C5 保留为原固定 5% 方法的历史名称。

用户提出两个轻量网络分别预测全局、局部重要性，以指导逐样本的视觉总预算和两路预算比例。方法使用共同审核代价尺度的全局升级收益与条件局部收益，并以收益曲线及显式成本描述路线规划。

主假设：该结构能够解释预算需求，同时改善政策条件下的质量与计算取舍。2026-10-10 用户报告新的自适应预算实验正在运行；尚未核验实际运行配置是否完全对应本页方法，未获得日志或结果。

## 方法定义

完整方法见 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|cx-global-local-importance-plan（历史方案，已删除）]]，方法配置见 [[LLM-Wiki/experiments/20261010-cx-global-local-importance/defaults.yaml]]。

审核代价仅含 NLL 和标签不一致惩罚。全局和局部各三档，局部三档包含无局部的零档，单框最多九个逻辑配置。Cx 的两个轻量网络共享从原 C5 复用的图文预览，局部网络读取全局语境及预算。

## 数据与配置边界

本记录不指定数据集规模、使用范围、执行顺序、门禁、失败处理或训练日程。原始 C5 记录保持原状。本文件保存方法关系及当前状态，实际实验配置和结果尚未填写。

## 局部收益的含义

主预算指标衡量在给定全局输入上增加局部的价值。局部-only 加位置信息衡量独立充分性；匹配像素替换的代价差衡量像素依赖。三者具有不同解释，局部-only 效用不直接代替条件局部收益。

## 原始结果与结论

2026-10-10方法提出时尚无新增输出或checkpoint核验。2026-10-14已获得用户的2026-10-13阶段总结与非零λ报告；本Wiki仅读取报告并派生描述性差值，未启动/监控训练或复核模型输出。四点dev的时延/质量分布、同Guard控制与证据边界见 [[LLM-Wiki/experiments/20261014-cx-lambda-scan-review/README.md]]。全局/局部的独立收益、政策响应、同成本质量及解释准确性仍待验证。

并行研究假设：以政策条件的中间表征分析视觉判别证据，见 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|cx-policy-safety-representation-pruning（历史方案，已删除）]]；该分支尚未提供实验结果。

关联：[[LLM-Wiki/research/visual-token-pruning/overview.md]]；[[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md]]。
