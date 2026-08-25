---
id: ai-safety-systems-security-venues
type: research-overview
title: 安全四大顶会中的 AI 安全系统工作（2023—2026）
aliases: [AI 安全系统顶会调研, 安全顶会 AI Safety]
tags: [research]
status: active
related: [safety-classifier-compression]
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel]
created: 2026-08-25
updated: 2026-08-25
---

# 安全四大顶会中的 AI 安全系统工作（2023—2026）

## 结论

在 IEEE S&P、USENIX Security、ACM CCS 与 NDSS 的 2023—2026 主会中，直接面向内容安全、安全对齐、安全检测和 AI 应用治理的工作数量不大，但已从纯模型演进到独立 guard、生成中干预、并发 sidecar、策略化审核和可验证系统架构。真正同时报告安全召回、误拒、端到端时延、吞吐与部署成本的工作仍少。

## 范围

- 纳入：内容安全、有害内容检测、安全对齐及保持、输入/输出 guard、运行时干预、产品审核、LLM app 与 agent 治理；允许纯模型或纯检测器。
- 排除：主要贡献为 jailbreak、提示注入、投毒、后门、对抗样本或规避的新攻击；隐私、模型窃取、水印、深伪溯源、AI for cybersecurity、workshop/poster。
- 混合论文：攻击方法若是主要创新，即使附带防御也不进入核心集合；防御论文可以用既有攻击评测，但不复述攻击构造。
- 检索截止：2026-08-25。采用官方 accepted/program/proceedings 和论文页面，属于可复核的保守集合，不宣称绝对穷尽。

## 核心判断

1. 2023 不强行补齐：仅保留 CCS 的 Unsafe Diffusion 作为生成图像安全测量/检测基线；USENIX Security 与 NDSS 未找到符合严格定义且非攻击主导的主会论文。
2. 2024 出现内容安全工具化：YOPO覆盖毒性分类、span 与 detoxification；Legilimens、SafeGen、Moderator分别面向 LLM 服务与文生图审核。
3. 2025 出现可部署 guard 与生命周期安全：SelfDefend使用 shadow LLM 和 checkpoint；JBShield做内部概念检测/操控；对齐恢复与 activation approximation 表明微调和推理近似都可能损害安全。
4. 2026 系统边界更清晰：ACE解耦 app、计划与执行；SAGA以 Provider、策略和密码学 token 管理 agent；Rennervate、DEEPALIGN、Sentinel把检测下沉到 token、隐藏状态或生成轨迹。
5. 与安全判别压缩直接相交的证据稀疏但存在：SelfDefend蒸馏防御模型，Sentinel小于5M参数，activation approximation说明压缩/近似后必须重新做安全验收。

## 系统层级

| 层级 | 代表工作 | 动作 |
|---|---|---|
| 纯模型/训练 | YOPO、SafeGen、对齐恢复、EnchTable | 提示学习、参数恢复、安全迁移 |
| 检测器/guard | Legilimens、HMGUARD、Sentinel | 输入/输出或多模态判别 |
| 生成时干预 | JBShield、Rennervate、DEEPALIGN | 隐状态操控、token 清洗、steering |
| 运行时组合 | SelfDefend、Moderator、SafeGuider | sidecar、checkpoint、改写/过滤 |
| app/agent 架构 | ACE、SAGA | 信任边界、访问控制、信息流 |
| 产品审核 | Gao 等、AI Character Platforms | 政策与真实平台测量 |

## 项目文档

- [[LLM-Wiki/research/ai-safety-systems-security-venues/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/ai-safety-systems-security-venues/landscape.md|技术路线图]]
- [[LLM-Wiki/research/ai-safety-systems-security-venues/comparison.md|统一比较]]
- [[LLM-Wiki/research/ai-safety-systems-security-venues/gaps.md|研究缺口]]
- [[LLM-Wiki/research/ai-safety-systems-security-venues/motivation.md|后续动机]]
