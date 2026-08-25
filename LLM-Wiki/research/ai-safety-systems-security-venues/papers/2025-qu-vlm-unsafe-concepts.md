---
id: paper-note-qu-2025-vlm-unsafe-concepts
type: paper-note
title: "Bridging the Gap in Vision Language Models in Identifying Unsafe Concepts Across Modalities"
authors: ["Yiting Qu", "Michael Backes", "Yang Zhang"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-qu-2025-vlm-unsafe-concepts
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

# Bridging the Gap in Vision Language Models in Identifying Unsafe Concepts Across Modalities

## 研究问题与收录理由

论文研究视觉语言模型对同一不安全概念的图像与文本输入是否采用一致的安全标准。它直接关联多模态安全判别，能够约束视觉 Token 压缩后的评测设计。

## 方法概览

作者构建 UnsafeConcepts 数据集，覆盖 75 个不安全概念和约 1,500 张图像，并将能力拆为“是否感知到概念”与“是否作出正确安全判断”。在发现跨模态差距后，论文采用基于响应分类器的简化 PPO 训练，不另行训练奖励模型，并与 SFT、DPO 等方案比较。

## 主要实验与结论

对 8 个 VLM 的评估显示，图像与文本形式之间存在持续的安全识别差距，问题不能仅归因于视觉感知不足；训练时的视觉安全对齐能够缩小该差距，论文报告其方案优于所比较的 SFT 和 DPO 路线。

## 局限与项目关联

数据规模和概念覆盖仍有限，且跨语言、开放世界及更复杂组合概念未被充分验证。对视觉 Token 剪枝而言，应按模态和风险类别分别报告感知正确率与安全判定指标，不能只看整体任务精度。

## 泛读结论

是多模态安全压缩评测的重要依据；若后续采用 UnsafeConcepts 做实验或复现 PPO 对齐，应升级为精读。
