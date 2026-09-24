---
id: note-2024-wang-siuo
type: paper-note
title: "Safe Inputs but Unsafe Output: Benchmarking Cross-modality Safety Alignment of Large Vision-Language Models"
tags: [paper-note, research, multimodal-safety, safety-alignment, safety-evaluation, vision-language-model]
source_id: paper-wang-2024-siuo
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-20
updated: 2026-09-20
---

# SIUO

来源：[ACL Anthology 正式版本](https://aclanthology.org/2025.findings-naacl.198/)与 [arXiv v2 HTML](https://arxiv.org/html/2406.15279v2)。核验摘要、§1、§3–4 和主要结果；未复现实验。

## 问题与构造

论文把“安全图像 + 安全文本，但联合语义可能导致不安全输出”定义为 SIUO。safe image 不含显式暴力、色情、歧视等内容且无对抗扰动；safe text 不含显式有害内容或危险操作指导。

人工构造先从 9 类风险设想场景，再搜索日常图片或从社交媒体图片反推安全文本。AI 辅助构造从 Open Images/EgoShots 的安全图片出发，由 GPT-4o 生成潜在危险联合事件和查询，再去除模态冗余、用 text-only judge 排除单独有害文本、最后人工编辑。2,000 张图片经流程得到 102 条有效样本；加上 167 条人工样本共 269 条。

## 主要结果

- Azure GPT-4V 与 Gemini 的输入过滤分别将 94.76% 和 95.96% 样本标为安全/可忽略风险，说明常规过滤难以发现组合风险。
- 15 个 LVLM 中 13 个安全率低于 50%；GPT-4V 人工评测安全率约 53.29%，其余模型中位正确率约 23.65%。
- 论文还区分 safety 与 effectiveness，避免把机械拒答直接当作理想安全回应。

## 证据边界

输入安全率来自模型过滤器，并非每条的双盲人类单模态政策标签。核心人工集仅 167 条，类别与语言覆盖有限；模型版本已较旧。尽管如此，它对“任务模型联合风险导致安全对齐失效”给出了最直接定义与证据。

关联：[[LLM-Wiki/research/multimodal-compositional-safety/overview.md]]。

