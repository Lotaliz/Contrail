---
id: change-2026-09-08-training-aware-visual-safety-pruning
type: change
title: "视觉 Token 剪枝主线转向训练参与与安全证据可见性"
tags: [metadata, research, visual-token-pruning]
date: 2026-09-08
change_type: Changed
---

# 本次语义与结构变化

- 覆盖更新既有综合主文的主线、背景、实验顺序、新颖性与投稿判断；保留旧证据选择设计为候选，新增 §20 的训练流程、T0–T8 对照和统计要求。
- 在原 visual-token-pruning 目录补齐 overview、reading-log、landscape、comparison、gaps、motivation。延续原主文路径与稳定 ID，不再删除逐篇证据；此结构符合当前维护流程的项目入口与 papers 要求。
- 新登记 14 条来源，新增 12 篇 paper-note：2 deep-read、8 skimmed、2 discovered；LOREAL/CoViPAL 只登记 discovered。两篇核心分别为 EPIC 和 TBD；已区分 EPIC 与其 ICD 变体、ViCO 与 VisCo。
- 候选主线为学生证据可观察性、图文—政策关系训练与 Guard 压缩状态安全；不把已有蒸馏、证据监督和动态预算再称为确定空白。
- 更新多模态 Token 剪枝概念的训练分类轴、研究/首页/标签导航、来源登记表和日期；不改变标签词表或 schema。
- 保留所有 raw PDF、原始实验、旧负结果、用户笔记和插件设置；未执行模型训练或任何 Git 操作。

# 实际文件范围

新增：本记录；research/visual-token-pruning 下 6 个入口/综合文件与 12 个论文笔记。修改：原综合主文、raw/sources.yaml、concepts/methods/multimodal-token-pruning.md、research/README.md、index/home.md、index/tags.md、CHANGELOG.md。临时编辑脚本已删除，不是研究产物。

# 证据与未决事项

- G1–G6 为候选假设；本地数据尚不足以确认固定 FPR 的困难召回提升。
- LOREAL 原文访问失败，CoViPAL 仅发现待读；投稿前必须完成相邻工作排重。TBD/OOD-VTP 的会议状态未独立确认，不使用页眉占位元数据作为录用证据。
- 待实验前明确：41 类政策映射、误报率/延迟操作点、困难组标注和训练资源；本轮调研无需这些选择即可完成。
- 收尾检查：来源/链接/阅读层级、动机证据门槛、日期/索引与训练方案语义一致性；Wiki validator 的最终结果由任务完成报告给出。
