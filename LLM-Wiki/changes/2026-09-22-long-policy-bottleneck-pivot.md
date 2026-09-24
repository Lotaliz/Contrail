---
id: change-2026-09-22-long-policy-bottleneck-pivot
type: change
title: "路线二从纯视觉剪枝转向长政策视觉—条款协同压缩"
tags: [change, research, visual-token-pruning, multimodal-safety]
date: 2026-09-22
change_type: Changed
status: active
---

# 变更说明

根据用户报告的目标 workload 成本结构，重新评估路线二。政策文本 token 通常超过视觉 token 四倍；Dyna-ViT 式 90% pre-ViT 剪枝只有 1.14× 端到端加速且精度明显下降。Amdahl 推导仅用于说明净可利用视觉路径很小；原始 profiler 尚未归档，因此未登记为 reproduced 实验。

## 研究决策

- pure visual pruning 不再作为完整加速论文主线，保留为视觉证据选择模块和强基线。
- 推荐主线改为长政策离线编译、图像条件条款检索、政策条款与 pre-ViT patch 协同预算，以及风险约束回退。
- “视觉剪枝提高精度”保留为次要 hypothesis，必须先排除阈值校准、类别不平衡、训练损失和普通 dropout 的解释。
- 只筛短政策数据不作为主线，只进入政策长度分层实验。

## 新证据

- MADTP（CVPR 2024）：联合视觉/语言 token 剪枝的正式先例，反证“首次联合剪枝”，但其双分支短文本成本结构不同。
- SafeEditBench/SafeGuard-VL（CVPR 2026）：政策自适应图像 Guard 与五政策近邻图像对评测。
- PolicyShiftGuard/PolicyShiftBench（arXiv 2026）：公开 2,000 个评测实例、265 张图、28 个政策变体和同图 pass/block 翻转。
- Gist Tokens（NeurIPS 2023）：政策编译/缓存机制先例，也显示 FLOPs 与墙钟收益可能显著不一致。

新增四篇论文笔记与 [[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md|历史方案清理记录]]，覆盖更新路线二 plan、overview、motivation、gaps、reading-log、双路线总计划、联合图文压缩综述、研究索引和标签统计。未删除原始来源、实验输出或历史阅读记录。
