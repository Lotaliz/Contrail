---
id: paper-note-wang-2025-selfdefend
type: paper-note
title: "SelfDefend: LLMs Can Defend Themselves against Jailbreaking in a Practical Manner"
authors: ["Xunguang Wang", "Daoyuan Wu", "Zhenlan Ji", "Zongjie Li", "Pingchuan Ma", "Shuai Wang", "Yingjiu Li", "Yang Liu", "Ning Liu", "Juergen Rahmel"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-wang-2025-selfdefend
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# SelfDefend: LLMs Can Defend Themselves against Jailbreaking in a Practical Manner

## 研究问题与收录理由

论文尝试在不修改目标 LLM 的条件下，以较低附加开销拦截越狱请求。其并行守卫和发布前强制检查机制，是轻量 Guard 与系统执行点结合的直接案例。

## 方法概览

SelfDefend 借鉴影子栈思想，让目标 LLM 与处于检测状态的影子 LLM 并发运行，并在输出释放前通过检查点实施访问控制。论文还通过调优和蒸馏提升影子模型的防御能力，使其可形成专用防御模型。

## 主要实验与结论

作者在多类越狱与正常输入上和七类基线比较，报告方法能覆盖多种越狱而较少影响正常查询。直接调优版本的平均额外延迟为 0.032 秒；但这是论文特定硬件、模型与计时口径下的附加延迟，不能视为通用部署值。

## 局限与项目关联

防御质量依赖影子模型、检查点调度和发布控制，不能只归因于分类器参数量。其结构适合“小 Guard 先判、必要时回退”的系统方案，但仍需在目标环境中重测端到端尾时延与并发资源占用。

## 泛读结论

与低时延运行时防御高度相关；若要实现并发调度或复现蒸馏配方，应升级精读。
