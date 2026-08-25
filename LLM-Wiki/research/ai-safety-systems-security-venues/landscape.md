---
id: ai-safety-systems-security-venues-landscape
type: synthesis
title: AI 安全系统顶会调研：技术路线图
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# 技术路线图

## 训练期安全
YOPO、SafeGen、对齐恢复和 EnchTable 分别代表提示学习、生成抑制、参数恢复与安全迁移。后续微调、域迁移或压缩后都需要重新验收。

## 外挂检测器
Legilimens统一审核 LLM 输入/输出；HMGUARD检测有害 meme；Sentinel融合多层隐藏状态 probe。该路线适合单独压缩、校准和级联。

## 生成中干预
JBShield、Rennervate 与 DEEPALIGN 分别做概念检测/操控、token 级清洗和中段 hidden-state steering。优势是处理随上下文出现的意图；代价是依赖白盒访问。

## 运行时系统
SelfDefend并发运行目标 LLM 和 shadow LLM，以 checkpoint 控制输出；Moderator 与 SafeGuider把策略判断、改写和生成控制组成管线。统一 P95、batch throughput、故障降级与误拒成本仍缺失。

## app 与 agent 架构
ACE拆分可信抽象计划与 app 绑定计划，并验证信息流；SAGA用 Provider、用户策略和密码学 token 治理 agent。两者用确定性机制包围概率模型。

## 产品审核
Gao 等研究14个生成式 AI 工具；AI Character Platforms评估16个平台。产品安全还受 persona、政策、申诉和实现透明度影响。
