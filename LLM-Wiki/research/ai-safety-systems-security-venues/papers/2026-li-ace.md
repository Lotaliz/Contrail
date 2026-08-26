---
id: paper-note-li-2026-ace
type: paper-note
title: "ACE: A Security Architecture for LLM-Integrated App Systems"
authors: ["Evan Li", "Tushin Mallick", "Evan Rose", "William Robertson", "Alina Oprea", "Cristina Nita-Rotaru"]
year: 2026
venue: "NDSS 2026"
source_id: paper-li-2026-ace
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, ai-agent-security, prompt-injection-defense, policy-enforcement, access-control, information-flow-control]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-26
---

# ACE: A Security Architecture for LLM-Integrated App Systems

## 研究问题与收录理由

论文针对接入第三方应用的 LLM 系统中，恶意应用描述、模式或输出破坏规划与执行的问题。它展示如何用系统安全边界约束概率式模型，而不是把安全完全交给内容分类器。

## 方法概览

ACE 将处理拆为可信信息上的抽象计划生成、绑定已安装应用的具体计划实例化，以及隔离执行三阶段。结构化计划在执行前接受静态信息流检查，执行期再以数据屏障、能力屏障和受控接口落实策略。

## 主要实验与结论

作者提出并验证三类针对 IsolateGPT 的新攻击，并在 INJECAGENT、Agent Security Bench 及新增攻击上测试 ACE；论文称这些攻击均被阻断。在 LangChain Tool Usage 套件上，系统效用高于 80%。

## 局限与项目关联

效用结果依赖论文的任务和安全策略，不能等价为一般代理性能保证。对轻量 Guard 架构的启示是：风险信号应接入静态验证和强制执行点，分类准确率本身不足以建立端到端安全保证。

## 泛读结论

是系统级安全边界的重要参照；若后续设计工具调用控制平面，应升级精读其策略格和威胁模型。
