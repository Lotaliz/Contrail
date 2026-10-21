---
id: note-2025-bao-vmoda
type: paper-note
title: "VModA: An Effective Framework for Adaptive NSFW Image Moderation"
authors: [Han Bao, Qinying Wang, Zhi Chen, Qingming Li, Xuhong Zhang, Changjiang Li, Zonghui Wang, Shouling Ji, Wenzhi Chen]
year: 2025
venue: arXiv
source_id: paper-bao-2025-vmoda
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, safety-guardrail, multimodal-safety, vision-language-model, safety-evaluation]
status: active
created: 2026-10-14
updated: 2026-10-14
---

# VModA：不同规则下的细节审核与整体语义

场景是社交图片审核：违规可能在小图标、局部动作、图中文字，判断也随审核规则改变。作者用整体图和区域一起解释这些事实，随后按规则决定是否违规。

阅读[官方v1](https://arxiv.org/html/2505.23386v1)摘要/引言、§IV方法和图2–3、主要实验表及§V.C、§VI.B–D、结论；目视核查图3。未精读完整附录、审计代码或复现实验。

§IV.A以RAM/GroundingDINO提区域，整图与ROI配对审核；只读crop可能让模型猜测裁外语境。再提取OCR，结合条件prompt和从对象到状态、修辞的描述。§IV.B采用temperature=1、每问10次采样并用LLM合并；这是多模型、多调用审核流程。

§V.C/Table IV比较学校欺凌和抗议暴力规则交换后的行为，表明细规则的范围会改变检出；它不是完整同图、单条款翻转配对指标。§VI.C人工复核公共数据争议标签；§IX说明Memedroid图像不发布，重标数据只计划提供文件名与修正标签。大幅总体提升不能单独归于ROI，框架混合多个模块。

项目判断：是全局＋局部、具体规则、标签质量的直接近邻。适合借鉴离线审图与上下文控制；当前单框、低时延Cx不可直接照搬十次采样。作者保留基础模型能力/推理速度限制，未给出本项目同token预算结果。若复现区域选择或采用其重标数据，再升级精读。

关联：[[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]]。
