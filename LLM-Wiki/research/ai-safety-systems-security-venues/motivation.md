---
id: ai-safety-systems-security-venues-motivation
type: synthesis
title: AI 安全系统顶会调研：后续研究动机
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel]
status: active
related: [ai-safety-systems-security-venues, safety-classifier-compression]
created: 2026-08-25
updated: 2026-08-25
---

# 后续研究动机

- 压缩 Guard 应作为系统组件验收：同时测召回、误拒、time-to-verdict、级联率、控制面动作和失败降级。
- 将安全恢复纳入发布生命周期：设置压缩前后安全回归、恢复训练和回滚门槛。
- 多模态 Guard 压缩必须保护跨模态危险证据：按危险类别与证据类型报告 recall，而非只看平均 accuracy。

上述动机分别由 SelfDefend/ACE/SAGA/Sentinel、对齐恢复/EnchTable/activation approximation、VLM Unsafe Concepts/HMGUARD 的独立证据支持；它们是文献综合，不是实验结论。
