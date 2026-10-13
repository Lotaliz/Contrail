---
id: change-2026-10-13-untrack-paper-originals
type: change
title: "原文文件改为本地副本，仓库发布来源与笔记"
tags: [change, source, metadata]
date: 2026-10-13
change_type: Removed
status: active
---

# 原文文件发布范围调整

按用户要求，当前版本取消下列 54 份论文原文的 Git 跟踪：40 个 PDF、14 个 HTML，共 185,304,061 字节。本地原件保留且内容不改写。远程当前版本移除这些文件；后续 raw 下的 PDF、HTML、HTM 由根目录 .gitignore 忽略。旧提交历史不在本次范围内。

来源登记的稳定 ID、URL、版本、local_path、local_artifacts 与哈希保留。本地路径用于当前机器的阅读副本，不表示远程包含原件。37 份现有文档中的 56 处原文 WikiLink 改为官方来源地址；阅读深度、来源结论及实验结果保持原有记录。

## 取消跟踪的原文

- `LLM-Wiki/raw/papers/1803.09797v4.pdf`
- `LLM-Wiki/raw/papers/2023-cao-pumer.pdf`
- `LLM-Wiki/raw/papers/2024-agarwal-gkd.pdf`
- `LLM-Wiki/raw/papers/2025-chen-safewatch.pdf`
- `LLM-Wiki/raw/papers/2025-qu-vlm-unsafe-concepts.pdf`
- `LLM-Wiki/raw/papers/2025-shen-numerical-pruning.pdf`
- `LLM-Wiki/raw/papers/2025-yang-visionzip.pdf`
- `LLM-Wiki/raw/papers/2025-zhang-cdpruner-neurips.pdf`
- `LLM-Wiki/raw/papers/2025-zhuang-hmguard.pdf`
- `LLM-Wiki/raw/papers/2026-fu-opsa-safety.pdf`
- `LLM-Wiki/raw/papers/2026-gao-quietprune.pdf`
- `LLM-Wiki/raw/papers/2026-ji-vispco.pdf`
- `LLM-Wiki/raw/papers/2026-li-compleak.pdf`
- `LLM-Wiki/raw/papers/2026-liu-quantifying-llm-attacks-model-cognition.pdf`
- `LLM-Wiki/raw/papers/2026-yun-ghosted-layers.pdf`
- `LLM-Wiki/raw/papers/2608.07193v2.pdf`
- `LLM-Wiki/raw/papers/2609.10346v1.pdf`
- `LLM-Wiki/raw/papers/2609.13745v1.pdf`
- `LLM-Wiki/raw/papers/2609.13804v1.pdf`
- `LLM-Wiki/raw/papers/2609.15131v1.pdf`
- `LLM-Wiki/raw/papers/2609.16841v1.pdf`
- `LLM-Wiki/raw/papers/2609.18279v1.pdf`
- `LLM-Wiki/raw/papers/2609.19990v1.pdf`
- `LLM-Wiki/raw/papers/2609.22910v1.pdf`
- `LLM-Wiki/raw/papers/2609.24485v2.pdf`
- `LLM-Wiki/raw/papers/2609.24526v2.pdf`
- `LLM-Wiki/raw/papers/2609.24894v1.pdf`
- `LLM-Wiki/raw/papers/2609.25635v1.pdf`
- `LLM-Wiki/raw/papers/2609.26484v1.pdf`
- `LLM-Wiki/raw/papers/2609.27988v1.pdf`
- `LLM-Wiki/raw/papers/2609.34861v1.html`
- `LLM-Wiki/raw/papers/2609.34861v1.pdf`
- `LLM-Wiki/raw/papers/2609.37123v1.html`
- `LLM-Wiki/raw/papers/2609.37123v1.pdf`
- `LLM-Wiki/raw/papers/2609.37581v1.html`
- `LLM-Wiki/raw/papers/2609.37581v1.pdf`
- `LLM-Wiki/raw/papers/2609.39134v1.html`
- `LLM-Wiki/raw/papers/2609.39134v1.pdf`
- `LLM-Wiki/raw/papers/2610.00757v1.html`
- `LLM-Wiki/raw/papers/2610.00757v1.pdf`
- `LLM-Wiki/raw/papers/2610.01640v1.html`
- `LLM-Wiki/raw/papers/2610.01640v1.pdf`
- `LLM-Wiki/raw/papers/2610.04225v1.html`
- `LLM-Wiki/raw/papers/2610.07729v1.html`
- `LLM-Wiki/raw/papers/2610.07987v1.html`
- `LLM-Wiki/raw/papers/2610.09252v1.html`
- `LLM-Wiki/raw/papers/2610.09252v1.pdf`
- `LLM-Wiki/raw/papers/2610.09313v1.html`
- `LLM-Wiki/raw/papers/2610.09313v1.pdf`
- `LLM-Wiki/raw/papers/2610.09703v1.html`
- `LLM-Wiki/raw/papers/2610.11251v1.html`
- `LLM-Wiki/raw/papers/2610.11251v1.pdf`
- `LLM-Wiki/raw/papers/2610.13263v1.html`
- `LLM-Wiki/raw/papers/2610.13263v1.pdf`

## 同步修改

- `.gitignore`
- `LLM-Wiki/CHANGELOG.md`
- `LLM-Wiki/changes/2026-10-10-selected-watch-second-batch-deep-read.md`
- `LLM-Wiki/metadata/workflows/common-contract.md`
- `LLM-Wiki/metadata/workflows/paper-ingestion.md`
- `LLM-Wiki/raw/README.md`
- `LLM-Wiki/raw/sources.yaml`
- `LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-qu-vlm-unsafe-concepts.md`
- `LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhuang-hmguard.md`
- `LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-liu-sentinel.md`
- `LLM-Wiki/research/model-compression-privacy/papers/2026-li-compleak.md`
- `LLM-Wiki/research/safety-classifier-compression/papers/2026-yun-ghosted-layers.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2023-cao-pumer.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-bercy-g2tm.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-bond-task-induced-metrics.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-bozkurt-slicechat.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-feng-visionweave.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-foundation-me-vlm.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-guan-video-evidence-indexing.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-han-foveated-compression.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-he-coreprune.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-jeong-refit.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-jiang-vcola.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-kang-when-text-matters.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-liu-autoprune-ai4ai.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-lv-vprune.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-ma-sheafprune.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-niu-chart-reading.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-niu-evivit.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-peng-countercredit.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-shi-small-objects-safe-zoom.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-sun-adavskip.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-wang-trevs.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-yan-fata.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-std.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-stepprune.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-zhao-scaling-stops.md`
- `LLM-Wiki/research/visual-token-pruning/papers/2026-zhu-flashgaze.md`

## 完成检查

核对所有原文已被忽略且不再位于当前 Git 索引；原件内容哈希与操作前一致，发布文档无原文文件 WikiLink。运行 Wiki 校验器，并核对远程 main 的当前版本。原有两项独立警告保留：XGuard 实验中的既有未解析链接，以及 2026-08-25 详细变更说明未从 CHANGELOG 链接。
