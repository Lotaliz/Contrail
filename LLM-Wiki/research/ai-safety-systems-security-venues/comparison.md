---
id: ai-safety-systems-security-venues-comparison
type: synthesis
title: AI 安全系统顶会调研：统一比较
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# 统一比较

| 工作 | 信号/位置 | 动作 | 系统边界 | 压缩意义 |
|---|---|---|---|---|
| Legilimens | 概念特征 | 审核 | 服务 guard | 轻量统一检测 |
| SelfDefend | shadow LLM | checkpoint 阻断 | 并发双实例 | 适合蒸馏与级联 |
| JBShield | 激活概念 | 检测+操控 | 白盒 | 内部信号更丰富 |
| VLM Unsafe Concepts | 感知与对齐 | PPO | 模型级 | 保护跨模态一致性 |
| Activation Approximations | 近似误差 | QuadA | 部署链 | 压缩后安全复验 |
| HMGUARD | prompt + CoT | 检测 | MLLM guard | 质量高但生成慢 |
| EnchTable | 安全向量 | 蒸馏+合并 | 发布链 | 安全恢复 |
| Sentinel | 多层 probe | 早期检测 | 白盒外挂 | 小于5M直接证据 |
| Rennervate | token attention | 检测+清洗 | 白盒运行时 | 细粒度干预 |
| DEEPALIGN | 中段隐藏状态 | steering | 白盒生成环 | 测 time-to-verdict |
| ACE / SAGA | 计划、信息流、策略 | 验证与授权 | 控制面 | guard 不替代控制面 |
| 产品审核 | 政策与角色 | 治理 | 社会技术系统 | 覆盖误拒与申诉 |

共同点：分离不可信语言与确定性执行；高风险动作使用 checkpoint、授权或 sanitization；同时测安全、utility 和系统开销。尚未统一：安全 taxonomy、固定 FPR 召回、计时边界、batch/流式吞吐、超时与版本更新降级。
