---
id: model-compression-privacy-reading-log
type: synthesis
title: MIA 前沿定位：检索与阅读日志
tags: [research, membership-inference]
project_id: model-compression-privacy
sources: [paper-li-2026-compleak, paper-du-2026-cmia-pmia, paper-lu-2026-icp-mia, paper-chen-2026-window-mia, paper-tong-2026-tokenizer-mia, paper-nguyen-2026-menta, paper-wang-2026-vidleaks, paper-zhang-2025-soft, paper-shang-2025-wemem, paper-li-2025-dhattack, paper-tan-2026-neural-activation-mia]
status: active
created: 2026-09-15
updated: 2026-09-15
---

# MIA 前沿定位：检索与阅读日志

## 研究问题

1. 截至 2026-09-15，MIA 是否仍是 AI 系统隐私研究的主流方向之一？
2. CompLeak 能否代表 MIA 攻击或防御的总体最前沿？

## 范围与检索

- 时间：重点覆盖 2025—2026。
- 来源：USENIX Security、NDSS 官方 program、accepted-paper 与 paper page；用会议正式页面核对题名、场景和摘要主张。
- 查询：`membership inference` 与 `LLM`、`RAG`、`tokenizer`、`video`、`compression`、`pruning`、`label-only`、`defense` 的组合。
- 纳入：MIA 是主要研究问题、主要攻击、主要防御或核心隐私审计工具的安全顶会论文。
- 排除：只在 related work 提到 MIA、非正式博客、workshop、无法从官方页面核对的候选。

## 阅读层级

- deep-read：[[LLM-Wiki/research/model-compression-privacy/papers/2026-li-compleak.md|CompLeak]]。
- source-checked skimmed：CMIA/PMIA、ICP-MIA、WBC、Tokenizer MIA、MEntA、VidLeaks、SOFT、WeMem、DHAttack、Neural-Activation MIA；本轮依据官方摘要/正文开头确认问题、机制和主要结论，没有创建独立 paper-note。

## 覆盖边界

- 本轮目的为前沿定位，而非穷尽统计；没有对 IEEE S&P、CCS、ML 顶会和预印本做等强度全量检索。
- “主流”依据持续顶会接收、专门 session、跨系统迁移和作为隐私审计工具的使用判断，不等于 MIA 占 AI 隐私论文的多数。
- 不以单篇论文自称 SOTA 作为跨任务排名依据；不同访问权限、查询预算、数据集与指标不可直接比较。
