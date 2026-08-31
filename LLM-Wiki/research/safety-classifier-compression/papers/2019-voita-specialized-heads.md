---
id: paper-note-voita-2019-specialized-heads
type: paper-note
title: "Analyzing Multi-Head Self-Attention: Specialized Heads Do the Heavy Lifting, the Rest Can Be Pruned"
authors: ["Elena Voita", "David Talbot", "Fedor Moiseev", "Rico Sennrich", "Ivan Titov"]
year: 2019
venue: "ACL 2019"
source_id: paper-voita-2019-specialized-heads
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, structured-pruning, model-compression]
status: active
related: []
created: 2026-08-31
updated: 2026-08-31
---

# Specialized Heads Do the Heavy Lifting

## 核心发现

重要且置信度高的头呈现稳定、可解释的语言学功能；基于随机门和可微 L0 正则的剪枝会最后删除这些专门化头。在 WMT 英俄翻译中删除 48 个 encoder heads 中的 38 个，只造成 0.15 BLEU 下降。

## 对本课题的边界

证据表明 MHA 的冗余高度集中而非均匀：多数头可替代，少数专门化头承担关键功能。安全剪枝应按任务切片保护关键头，尤其不能用平均激活或固定比例逐层裁剪替代任务消融。

## 证据位置

- 摘要；head role 分析；L0 head-pruning 实验。
