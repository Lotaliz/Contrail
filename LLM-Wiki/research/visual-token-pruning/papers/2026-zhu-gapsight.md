---
id: note-2026-zhu-gapsight
type: paper-note
title: "Learning to Look Again: Loss-Gap Supervision for Free-form Crop Routing in Vision-Language Models"
authors: [Jinchang Zhu, Rong Fu, Yi Ding, Chenghao Wu, Ying Liu, Menglin Yang]
year: 2026
venue: arXiv
source_id: paper-zhu-2026-gapsight
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, visual-token-pruning, adaptive-routing, visual-evidence]
status: active
created: 2026-10-08
updated: 2026-10-08
---

# GapSight

来源：[arXiv 2608.21762v1](https://arxiv.org/html/2608.21762v1)。快读摘要、引言、方法、图注、主表和结论，未复现或核验代码，未保存 PDF。

**作者方法：** 离线比较全局预览与候选 crop 加入后的答案 NLL / 正确选项 margin，以收益训练 gate、utility 和连续单框预测。Router 读取全局路径 hidden state，骨干冻结；在线先处理预览，决定是否注入一个 crop。Table 1 的 Qwen2-VL-2B 六任务均分从 44.65 到 56.02；Table 3 同骨干、候选库和训练安排的监督消融中，loss-gap 优于 CLIP relevance。

**证据边界：** §Method、Table 1/3/4/5 支持模型特定的裁剪收益及救回/新增错误分析；没有证明其空间解释的因果忠实性，也没有当前政策 Guard、固定 5% 总预算或 selector-inclusive wall-clock 证据。

**项目判断：** 是 C5 的近邻，限制了“全局＋单框＋teacher 收益路由”的新颖性。可迁移相对收益、模糊标签降权、按目标 Guard 建 teacher；不需采用连续框或在线二次 Guard。建议迁移仅是待验证设计，见 [[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md]]。
