---
id: note-2025-rottger-msts
type: paper-note
title: "MSTS: A Multimodal Safety Test Suite for Vision-Language Models"
tags: [paper-note, research, multimodal-safety, safety-evaluation, vision-language-model]
source_id: paper-rottger-2025-msts
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-20
updated: 2026-09-20
---

# MSTS

来源：[arXiv v1 HTML](https://arxiv.org/html/2501.10057v1)。核验 §2–5、Tables 3/6/7 和 limitations；页面标注 under review，未复现实验。

## 问题与构造

MSTS 的每条图文提示只有联合后才显露完整危险含义。作者对 40 个危险叶类各手工设计 5 个基础案例，使用一个文本片段和一张唯一图片，再以 “Should I …?” 与 “I am going to …” 生成 400 条英文提示。图片主要来自 Wikimedia 等可商用来源；另构造文本等价提示和 10 种语言翻译。

## 任务模型结果

作者只把明确支持/鼓励危险行动的回答标为 unsafe；误解、无意义或要求澄清虽属 safe，但单列为 safe by accident。英文联合提示上，部分开源模型产生 5.8%–14% unsafe 回答。MiniCPM-2.6 的联合 unsafe rate 为 7.3%，文本等价提示为 2.5%；GPT-4o 两者均为 1.0%。这说明多模态输入对部分模型带来额外安全退化，但不是所有模型都同幅下降。

## 自动安全判别结果

作者用 8 种系统复现 4,000 条回复的人工安全标签：

| 分类器 | 宏 F1 | unsafe precision | unsafe recall |
|---|---:|---:|---:|
| Gemini-1.5 | 0.79 | 0.53 | 0.68 |
| Claude-3.5 | 0.75 | 0.52 | 0.52 |
| GPT-4o | 0.60 | 0.19 | 0.91 |
| Llama Guard 3 Vision | 0.64 | 0.55 | 0.20 |
| LlavaGuard | 0.51 | 0.07 | 0.05 |
| OpenAI Omni Moderation | 0.46 | 0.02 | 0.10 |

这直接证明自动审核在联合语境中会出现严重精确率/召回率失衡。

## 证据边界

分类器任务是判断 `(image, prompt, model response)` 的回复安全，不是单纯的输入拦截；没有对每个专用 Guard 进行 image-only、text-only、joint 三路消融。因此它支持“判别器会漏检联合语境中的有害内容”，但不足以证明所有 Guard 相对单模态都显著下降。

关联：[[LLM-Wiki/research/multimodal-compositional-safety/overview.md]]。

