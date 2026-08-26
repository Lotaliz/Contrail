---
id: paper-note-syros-2026-saga
type: paper-note
title: "SAGA: A Security Architecture for Governing AI Agentic Systems"
authors: ["Georgios Syros", "Anshuman Suri", "Jacob Ginesin", "Cristina Nita-Rotaru", "Alina Oprea"]
year: 2026
venue: "NDSS 2026"
source_id: paper-syros-2026-saga
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, ai-agent-security, policy-enforcement, access-control, information-flow-control]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-26
---

# SAGA: A Security Architecture for Governing AI Agentic Systems

## 研究问题与收录理由

论文解决自主代理之间通信时的身份、授权、用户控制和滥用扩散问题。它为“判别结果如何转化为可执行访问控制”提供了系统层参照。

## 方法概览

SAGA 设置中心 Provider，负责代理注册、元数据发现和用户策略执行，并使用证书、一次性密钥和带额度或生命周期的加密访问令牌控制代理间通信。协议给出形式化安全目标，并兼容 A2A、MCP 等现有交互协议。

## 主要实验与结论

论文在本地与云端模型、不同设备和地理位置上实现原型。核心密码操作通常为毫秒级；当交互达到约 4—5 次时，摊销协议开销低于 25 毫秒。在最快的日历任务中，协议开销低于端到端成本的 0.6%，示例代理均能完成任务。

## 局限与项目关联

中心 Provider 引入信任、可用性和策略配置假设，评估任务也不能覆盖开放世界代理行为。SAGA 是治理控制平面，不是内容检测基线；轻量 Guard 可提供风险信号，但授权应由独立策略和执行机制完成。

## 泛读结论

适合作为安全系统集成依据；若项目转向多代理通信治理，应升级精读协议与证明。
