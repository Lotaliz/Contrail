---
id: ai-safety-systems-security-venues-gaps
type: synthesis
title: AI 安全系统顶会调研：研究缺口
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# 研究缺口

1. **统一验收不足**：多数模型工作仍以 accuracy、ASR 或 unsafe rate 为主；固定 FPR 召回、P50/P95 time-to-verdict、batch throughput、显存/成本和超时降级缺少统一协议。
2. **生命周期闭环不足**：对齐恢复、activation approximation 与 EnchTable共同说明微调/部署变化可能损害安全；剪枝、蒸馏、量化、路由与版本更新后的统一回归和回滚门槛仍不明确。不能据此断言所有压缩必然降低安全。
3. **guard 与控制面联合评测不足**：模型内部检测与 ACE/SAGA 的信息流、授权研究彼此分离；误判如何传播到回退、人工复核和审计日志，仍少端到端证据。
4. **多模态长尾不足**：modality gap、复杂构图和宣传技巧已有证据，但 OCR、小目标、隐式图文组合、文化语境与稀有类别在压缩后是否保持召回，缺少统一验证。
5. **产品补救接口不足**：政策常缺少实现与申诉细节，persona也会改变安全表现；模型标签如何映射到产品动作、解释和申诉仍无通用接口。
