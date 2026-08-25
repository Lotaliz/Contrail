---
id: paper-note-zhong-2026-rennervate
type: paper-note
title: "Attention is All You Need to Defend Against Indirect Prompt Injection Attacks in LLMs"
authors: ["Yinan Zhong", "Qianhao Miao", "Yanjiao Chen", "Jiangyi Deng", "Yushi Cheng", "Wenyuan Xu"]
year: 2026
venue: "NDSS 2026"
source_id: paper-zhong-2026-rennervate
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

# Attention is All You Need to Defend Against Indirect Prompt Injection Attacks in LLMs

## 研究问题与收录理由

论文研究如何检测并清除外部数据中的间接提示注入，同时尽量保留原任务所需内容。它提供了 Token 级安全判别与细粒度净化的实例。

## 方法概览

RENNERVATE 对注意力头和响应 Token 两个维度进行两阶段注意力池化，定位注入相关信号，再通过 FIPI 机制实施 Token 级检测与净化。目标是避免因整段拒绝而造成不必要的效用损失。

## 主要实验与结论

作者在 5 个 LLM、6 个数据集上，与 15 种防御比较，并测试未见及自适应攻击。论文结论是该方法在检测精度、迁移性、鲁棒性和参数规模上优于所比较基线，同时可在检测后继续提供净化内容。

## 局限与项目关联

方法需要访问注意力特征；对于纯 API 模型，只能依赖服务方实现或另设本地影子模型。作者指出净化可能无法完全去除与注入任务相关的内容，并在语法纠正等任务上造成效用下降。

## 泛读结论

适合作为 Token 级判别与选择性净化路线；若要比较实际推理时延或实现 FIPI，应升级精读。
