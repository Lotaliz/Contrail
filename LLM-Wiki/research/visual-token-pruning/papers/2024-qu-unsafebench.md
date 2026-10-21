---
id: note-2024-qu-unsafebench
type: paper-note
title: "UnsafeBench: Benchmarking Image Safety Classifiers on Real-World and AI-Generated Images"
authors: [Yiting Qu, Xinyue Shen, Yixin Wu, Michael Backes, Savvas Zannettou, Yang Zhang]
year: 2024
venue: arXiv
source_id: paper-qu-2024-unsafebench
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, safety-guardrail, multimodal-safety, vision-language-model, safety-evaluation]
status: active
created: 2026-10-14
updated: 2026-10-14
---

# UnsafeBench：图片安全与真实/生成分布差异

该工作从LAION-5B与Lexica收集图片，按11类定义标注，再比较传统和VLM安全分类器，并训练PerspectiveVision。它是图片审核数据，不是局部预算训练集。

定向略读[官方v2](https://arxiv.org/html/2405.03486v2)摘要、引言、总览、§3数据、§4主表与布局实验、§5.2构造、结论；查看Figure12/14(a)的符号和暴力漏报簇例图。补核[v3](https://arxiv.org/html/2405.03486v3)题录/摘要、数据与结论；v3题录注CCS2025，年份按2024初始预印本登记。未访问gated原始数据行或复现。

v2 §3/Table2：12,932张候选中6,098 safe、4,048 unsafe、2,786 N/A，后者在实验排除；Fleiss kappa0.47。v3对应Table1保留同一规模统计，但改报agreement0.780、kappa0.697；本轮未追查该一致性统计的修订原因，不能用旧0.47概括当前版本。两个版本都说明：同时含多种违规的图只标主要类别，这直接限制“移除主类→safe”的派生规则。

§4中作者用艺术风格及2×2、3×3、4×4网格改变图片，人工检查语义保留；视觉困难并非本轮首次合成思路。§5.2随机移除无关类、重排类别，另用不包含原违规的taxonomy构造safe翻转。Figure12困难常是符号语义；Figure14包含漫画、多格战斗和大主体，不支持全数据单一难度结论。

项目判断：可用来寻找控制难度/布局的先例，但应区分重复网格与一个小风险物体嵌入正常背景；来源不同的风格差异不等于局部细节必要性。新规则标签、原数据的近重复组和派生图片均需重新审计。若准备重建完整数据或量化小证据比例，再精读。

关联：[[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]]。
