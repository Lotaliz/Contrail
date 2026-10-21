---
id: ai-safety-systems-security-venues-landscape
type: synthesis
title: AI 安全系统顶会调研：技术路线图
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel, paper-paudel-2024-contextual-soft-moderation, paper-paudel-2024-pixelmod, paper-guo-2024-ugcg-guard, paper-kireev-2025-telegram-propaganda, paper-luo-2025-unsafe-search, paper-pang-2026-dualsentinel, paper-he-2026-attriguard, paper-shen-2025-hatebench, paper-lipphardt-2026-global-moderation, paper-qu-2024-unsafebench]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-10-21
---

# 技术路线图

## 训练期安全
YOPO、SafeGen、对齐恢复和 EnchTable 分别代表提示学习、生成抑制、参数恢复与安全迁移。后续微调、域迁移或压缩后都需要重新验收。

## 政策驱动模型管理
Moderator让管理员指定内容、语境和干预理由，将政策转换为自生成样本、task vector和生成模型权重编辑；不是普通的在线输入改写。它与部署时传入任意政策即可执行的分类Guard不同。

## 外挂检测器
Legilimens统一审核 LLM 输入/输出；HMGUARD检测有害 meme；Sentinel融合多层隐藏状态 probe。该路线适合单独压缩、校准和级联。

## 生成中干预
JBShield、Rennervate 与 DEEPALIGN 分别做概念检测/操控、token 级清洗和中段 hidden-state steering。优势是处理随上下文出现的意图；代价是依赖白盒访问。

## 运行时系统
SelfDefend并发运行目标LLM和shadow LLM，以checkpoint控制输出；SafeGuider把embedding级风险判断与安全特征处理组成生成前管线。不同论文的时延、吞吐与误拒数字不能无条件合并比较。

## app 与 agent 架构
ACE拆分可信抽象计划与 app 绑定计划，并验证信息流；SAGA用 Provider、用户策略和密码学 token 治理 agent。两者用确定性机制包围概率模型。

## 产品审核
Gao 等研究14个生成式 AI 工具；AI Character Platforms评估16个平台。产品安全还受 persona、政策、申诉和实现透明度影响。

## 2026-10-21扩展检索入口

[[LLM-Wiki/research/ai-safety-systems-security-venues/moderation-reading-list-2024-2026.md|新阅读清单]]按审核对象增加社交帖子/误导图片（CTD、PIXELMOD）、游戏推广（UGCG-Guard）、宣传账号、AI搜索回答/URL，以及Agent工具调用（AttriGuard）。DualSentinel属于生成过程中的定向攻击监测，ACE/SAGA属于权限和执行控制；后者不替代语义审核。新增条目目前仅摘要级发现，不据此生成新概念、性能排序或正式研究缺口。
