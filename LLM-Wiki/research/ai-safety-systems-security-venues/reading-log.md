---
id: ai-safety-systems-security-venues-reading-log
type: synthesis
title: AI 安全系统顶会调研：检索与阅读日志
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# 检索与阅读日志

检索四会官方 accepted papers、program、technical sessions、paper pages 与 proceedings。查询覆盖 LLM、generative AI、multimodal、text-to-image、agent 与 safety、alignment、moderation、toxic、harmful、guard、detection、governance。先记录 discovered 候选，再按“直接安全目标、主会、非攻击主导”筛选。

## 核心集合（20篇）

| 年份 | 会议 | 论文 | 角色 | 级别 |
|---|---|---|---|---|
| 2023 | CCS | Unsafe Diffusion | 文生图风险测量/检测 | skimmed |
| 2024 | S&P | You Only Prompt Once | 毒性分类、span、detox | skimmed |
| 2024 | CCS | Legilimens / SafeGen / Moderator | LLM 与 T2I 内容审核 | deep/skimmed |
| 2025 | S&P | Alignment Recovery | 微调后参数恢复 | deep-read |
| 2025 | USENIX | SelfDefend / JBShield | 运行时与隐状态 guard | deep/skimmed |
| 2025 | USENIX | VLM Unsafe Concepts | 跨模态安全对齐 | deep-read |
| 2025 | USENIX | Activation Approximations | 近似后的安全退化 | deep-read |
| 2025 | USENIX | I Cannot Write This | 产品政策/体验 | deep-read |
| 2025 | NDSS | HMGUARD | 有害 meme 检测 | deep-read |
| 2025 | CCS | SafeGuider | T2I 安全控制 | discovered |
| 2026 | S&P | EnchTable | 安全迁移/合并 | skimmed |
| 2026 | NDSS | ACE / SAGA | app 与 agent 架构 | deep-read |
| 2026 | NDSS | Rennervate / DEEPALIGN | token/生成中干预 | skimmed |
| 2026 | NDSS | AI Character Platforms | 平台安全审核 | deep-read |
| 2026 | USENIX | Sentinel | 小于5M隐藏状态检测器 | deep-read |

## 覆盖计数

| 会议 | 2023 | 2024 | 2025 | 2026 | 合计 |
|---|---:|---:|---:|---:|---:|
| IEEE S&P | 0 | 1 | 1 | 1 | 3 |
| USENIX Security | 0 | 0 | 5 | 1 | 6 |
| ACM CCS | 1 | 3 | 1 | 0 | 5 |
| NDSS | 0 | 0 | 1 | 5 | 6 |

“0”表示严格口径未找到，不表示没有 AI/ML security 论文。CCS 2026 的两个仅官方接收候选未计入核心集合。
