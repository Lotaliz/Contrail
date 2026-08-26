---
id: paper-note-zhuang-2025-hmguard
type: paper-note
title: "I know what you MEME! Understanding and Detecting Harmful Memes with Multimodal Large Language Models"
authors: ["Yong Zhuang", "Keyan Guo", "Juan Wang", "Yiheng Jing", "Xiaoyang Xu", "Wenzhe Yi", "Mengda Yang", "Bo Zhao", "Hongxin Hu"]
year: 2025
venue: "NDSS 2025"
source_id: paper-zhuang-2025-hmguard
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, safety-guardrail, multimodal-safety, content-moderation]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-26
---

# I know what you MEME! Understanding and Detecting Harmful Memes with Multimodal Large Language Models

## 研究问题与收录理由

论文研究有害梗图的画面构成、宣传技巧和图文语义如何使现有检测器失效，并据此设计多模态检测流程。它是安全判别任务中兼具视觉和文本推理的代表案例。

## 方法概览

HMGUARD 以多模态大模型为基础，先用自适应提示完成梗图领域与任务适配，再通过分步骤的 HMCOT 推理分析视觉内容、嵌入文本、语境和宣传策略，最后输出有害或无害判定。

## 主要实验与结论

在 HarMeme 数据集上，论文报告准确率 0.92、F1 0.91；在包含 300 个 Pinterest 样本的实景集合上，准确率为 0.88、F1 为 0.86。消融实验显示，自适应提示和各推理模块对性能均有贡献。

## 局限与项目关联

实验主要使用 `gpt-4-vision-preview`，数据只含英文嵌入文本，实景集合规模和平台来源有限。论文未提供可与轻量模型统一比较的参数量、吞吐和端到端时延基线，因此不能直接支持低成本部署结论。

## 泛读结论

适合作为多模态审核精度与类别覆盖的参考；若要压缩其推理链或复现实景评估，应升级精读。
