---
id: paper-note-zhang-2025-jbshield
type: paper-note
title: "JBShield: Defending Large Language Models from Jailbreak Attacks through Activated Concept Analysis and Manipulation"
authors: ["Shenyi Zhang", "Yuchen Zhai", "Keyan Guo", "Hongxin Hu", "Shengnan Guo", "Zheng Fang", "Lingchen Zhao", "Chao Shen", "Cong Wang", "Qian Wang"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-zhang-2025-jbshield
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

# JBShield: Defending Large Language Models from Jailbreak Attacks through Activated Concept Analysis and Manipulation

## 研究问题与收录理由

论文研究越狱提示如何改变 LLM 内部概念，并利用这些内部信号同时完成检测与缓解。它说明轻量判别不必只依赖最终文本，也可以利用宿主模型的隐藏状态。

## 方法概览

作者将隐藏表示中的“有害概念”和“越狱概念”分离：JBShield-D 根据两类概念的激活检测越狱，JBShield-M 则增强有害概念、削弱越狱概念，以修改后续生成行为。校准阶段所需样本较少，但依赖代表性数据。

## 主要实验与结论

论文在多个 LLM 和多种越狱方法上评估，报告平均检测准确率约 0.95，并将平均攻击成功率从 61% 降至 2%。跨未见攻击的实验表明概念信号具有一定迁移性，但作者也指出校准数据的质量与多样性会影响泛化。

## 局限与项目关联

方法需要白盒隐藏状态及在线表示干预，无法直接用于仅提供 API 的闭源模型。其参数或检测器规模不能单独代表系统成本，还需统计宿主模型前向计算、干预和端到端时延。

## 泛读结论

适合作为内部特征 Guard 的证据；若后续采用概念方向做剪枝敏感性分析，应升级精读。
