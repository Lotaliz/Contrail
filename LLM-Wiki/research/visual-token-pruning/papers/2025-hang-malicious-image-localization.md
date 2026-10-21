---
id: note-2025-hang-malicious-image-localization
type: paper-note
title: "Malicious Image Analysis via Vision-Language Segmentation Fusion: Detection, Element, and Location in One-shot"
authors: [Sheng Hang, Chaoxiang He, Hongsheng Hu, Hanqing Hu, Bin Benjamin Zhu, Shi-Feng Sun, Dawu Gu, Shuo Wang]
year: 2025
venue: arXiv
source_id: paper-hang-2025-malicious-image-localization
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, safety-guardrail, multimodal-safety, vision-language-model, safety-evaluation]
status: active
created: 2026-10-14
updated: 2026-10-14
---

# 从整图安全标签到有害元素位置

论文希望审核同时说明是否违规、哪些物体构成违规和这些物体在哪里。方法用SAM生成区域，合并/筛选后以VLM给区域评分，再汇成空间热图。对象与组合场景的判断是核心，不是视觉预算规划。

定向略读[官方v1](https://arxiv.org/html/2512.04599v1)摘要/引言、图1及§III方法、§IV数据/指标、Tables I–II、§V.D、§VI限制/运行成本、结论与伦理说明；未下载790图包、精读全部攻击细节或复现。

§IV.A报告790张图，每张1–5个关键元素人工mask，覆盖药物、性、暴力、极端主义等内容。§IV.C说明指标来自各类随机100图的人审口径；Table I的整体recall/precision为85.82%/78.05%，不能写成790张全量独立人审成绩。作者称元素分割和有害判别为不同指标。

§VI.F直接承认厨房刀可能被当成暴力、玩具枪被当武器，mask也可能损失上下文。§VI.C约10区域/图、每区域1–2秒的描述与当前毫秒级单次Cx不是同成本；“one-shot”标题不等于一个廉价Guard forward。伦理说明称数据需vetting后提供；本轮未确认公开下载入口或mask许可。

项目判断：可参考区域事实标注与良性混淆样本，不能把该热图当因果必要证据，亦不能宣称已获得可直接合并的开源数据。多元素覆盖与模型误报是迁移反例；若需采用mask或审计实现，应再精读。

关联：[[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]]；[[LLM-Wiki/research/visual-token-pruning/papers/2025-bao-vmoda.md]]。
