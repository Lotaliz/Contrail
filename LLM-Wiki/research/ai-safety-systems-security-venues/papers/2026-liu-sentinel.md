---
id: paper-note-liu-2026-sentinel
type: paper-note
title: "Quantifying Large Language Model Attacks Through the Lens of Model Cognition"
authors: ["Xiuming Liu", "Chaoxiang He", "Xuanran Yu", "Jichen Chai", "Feiyue Xu", "Sheng Hang", "Hanqing Hu", "Bin Benjamin Zhu", "Hongsheng Hu", "Shi-Feng Sun", "Dawu Gu", "Shuo Wang"]
year: 2026
venue: "USENIX Security 2026"
source_id: paper-liu-2026-sentinel
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

# Quantifying Large Language Model Attacks Through the Lens of Model Cognition

## 研究问题与收录理由

论文研究攻击提示在 Transformer 各层内部表示中的传播规律，以及能否用小型探针在表面输出之前识别攻击。它提供了小参数判别头与宿主大模型联合运行的直接证据。

## 方法概览

作者逐层训练轻量安全探针，并提出 Attack Consistency Index 描述表示漂移；Sentinel 融合多个中间层的互补信号进行最终判别，规模小于 500 万参数。

## 主要实验与结论

实验覆盖 7 个 1.5B—72B 开放模型及多类攻击基准。论文报告中间层探针最高可达 99% 检测率，Sentinel 在对抗评估中保持 94% 以上准确率，并将相对生成级拒答的假阴性约减半；部分基线在对抗条件下可下降 32%。

## 局限与项目关联

小于 500 万参数只描述探针，不包含宿主 LLM 产生隐藏状态的计算成本，因此它不是独立的 5M 编码器。方法还依赖白盒访问，且作者建议部署前进行公平性、子群体和人工复核评估。

## 泛读结论

是内部状态轻量 Guard 的关键候选；若用于压缩基线，应精读层选择、训练集构造和真实时延口径。
