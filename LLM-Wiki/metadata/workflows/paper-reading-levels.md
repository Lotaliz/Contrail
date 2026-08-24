---
id: workflow-paper-reading-levels
type: metadata
title: 三级论文阅读
tags: [metadata, workflow, source]
status: active
---

# 三级论文阅读

阅读深度与证据核验程度是两个独立字段。

## Level 1: discovered

适用于检索结果、候选论文和尚未筛选的资料。

必需内容：

- 在 raw/sources.yaml 登记题录、URL、获取日期和本地路径（如有）。
- source note 可选；创建时只写研究相关性和待筛选原因。
- 不根据摘要生成概念或 motivation。

## Level 2: skimmed

适用于快速筛选和研究地图构建。

至少阅读摘要、引言、方法总览图、主要实验表和结论，并记录：

- 研究问题、方法家族和主要贡献。
- 关键结果及其评测条件。
- 与当前项目的相关性。
- 是否升级为 deep-read 以及原因。

不得把 skimmed 笔记当成完整方法复现依据。

## Level 3: deep-read

适用于经典论文、代表性方法、强相关论文和准备复现的论文。

必须完成：

- 问题、假设、方法、训练或推理流程。
- 数据集、基线、指标、消融和主要结果。
- 局限、失败条件、作者主张与实际证据的差异。
- 关键陈述的页码、章节、表格或图号定位。
- 与已有概念和其他论文的具体关系。
- 是否提升或更新可复用 concept。
- 对 comparison、gap 或 experiment 的影响。

## verification 字段

取值：

- unverified：尚未逐项回看原文定位。
- source-checked：关键陈述已回到论文正文、表格或附录。
- reproduced：至少一个关键结论经过本地复现实验。

阅读层级提升不自动改变 verification。
