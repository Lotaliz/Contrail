---
id: change-2026-09-16-generative-intra-vit-pruning
type: change
title: "严格筛选生成式多模态模型的 ViT 内 token 剪枝与合并"
tags: [metadata, research, visual-token-pruning]
date: 2026-09-16
change_type: Changed
---

# 实际变化

按用户要求，将范围限定为视觉 Transformer 出口之前真实减少序列，并在生成式图像/视频多模态模型上评测。现有浅层剪枝综合增加严格子集，不改主研究方案、正式 motivation、实验或原始 PDF。记录剪枝、剪枝加聚合、信息回灌与合并的差异；纠正 SOTA 表中 VScan 输出端选择和 EvoPrune 的合并机制。

## 文件清单

新增 7 篇 skimmed / source-checked 笔记：

- [[LLM-Wiki/research/visual-token-pruning/papers/2025-tong-flowcut.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-liu-meteor.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-han-ficoco.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-hu-illava.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-liu-mustdrop.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-islam-adaptmerge.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-evoprune.md]]

另新增本变更记录；修改 `raw/sources.yaml`（新增 5 条唯一来源、更新既有 AdaptMerge/VScan/EvoPrune 的阅读与机制说明）、`research/visual-token-pruning/early-encoder-pruning-and-interpretability.md`、`autoregressive-vlm-pruning-sota-baselines.md`、`reading-log.md`、`overview.md` 和 `CHANGELOG.md`。

## 覆盖与未决项

核原文方法、执行位置、代表工作点与正式题录，不是完整精读或代码复现。QuietPrune 复用 2026-09-14 深读；本轮 CVF 链接直接打开失败，未借二手摘要替代既有官方 PDF 证据。新原件只登记 URL，未下载或复制。FiCoCo 采用 arXiv v3 数据、AAAI 正式 venue，注册作者只登记第一作者。METEOR、iLLaVA、MustDrop 的联合速度收益不归因给视觉单阶段。DeSAP 依赖最后层信号但执行切点尚未确证，未入严格表；Skip-Vision 不依据摘要确认 intra-ViT drop。

人工下一步为按纯剪枝或合并选定要复现的路线；不将此判断写成已验证的研究空白。无 Git 操作。

## 收尾校验

Wiki validator PASS：0 错误、2 条既存警告。原始 XGuard 探索笔记指向缺失的 20260902 recovery README；2026-08-25 的旧详细变更未链接到 CHANGELOG。两项均与本任务无关，未改写。来源 ID、7 篇阅读层级、原文层位置、代表数据归因与索引回链完成核对。
