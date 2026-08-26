---
id: paper-note-wei-2026-character-platforms
type: paper-note
title: "Benchmarking and Understanding Safety Risks in AI Character Platforms"
authors: ["Yiluo Wei", "Peixian Zhang", "Gareth Tyson"]
year: 2026
venue: "NDSS 2026"
source_id: paper-wei-2026-character-platforms
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, platform-safety, safety-evaluation, content-moderation, human-centered-security]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-26
---

# Benchmarking and Understanding Safety Risks in AI Character Platforms

## 研究问题与收录理由

论文评估 AI 角色平台在不同人格、角色属性和产品配置下的实际安全风险。它提醒安全判别不能只验收基础模型，还要覆盖角色设定和平台层带来的分布变化。

## 方法概览

作者对 16 个流行 AI 角色平台进行测量，使用覆盖 16 类安全问题的 5,000 个问题测试多样化角色，并分析人口属性、人格等特征与不安全响应之间的关联；随后训练模型预测相对不安全的角色。

## 主要实验与结论

论文报告各平台平均不安全响应率为 65.1%，而所设基线为 17.7%；用于识别较不安全角色的预测模型达到 0.81 F1。结果表明，角色和平台特征与安全失败显著相关，产品层可能放大基础模型风险。

## 局限与项目关联

平台服务会持续更新，黑盒测量难以分离基础模型、系统提示和审核链路的贡献，结果也具有时间敏感性。压缩 Guard 需要持续校准，并按角色、平台与风险类别报告分层指标。

## 泛读结论

适合作为分布漂移和平台评测依据；若要复用其角色特征或测量协议，应升级精读。
