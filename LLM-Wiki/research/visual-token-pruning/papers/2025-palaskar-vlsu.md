---
id: note-2025-palaskar-vlsu
type: paper-note
title: "VLSU: Mapping the Limits of Joint Multimodal Understanding for AI Safety"
tags: [paper-note, research, multimodal-safety, safety-evaluation, vision-language-model]
source_id: paper-palaskar-2025-vlsu
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-18
updated: 2026-09-21
---

# VLSU

来源：[arXiv v2 原文](https://arxiv.org/html/2510.18214v2)与 [Apple 官方项目](https://machinelearning.apple.com/research/vlsu)。定向核验 §2–5、Limitations；没有全读附录、审查代码或复现实验。v2 日期为 2025-12-03；Apple 页标注 ICLR 2026，会议身份未独立核验。

## 来源陈述

§2–3 定义 safe/borderline/unsafe，并分别标注图像、文本、组合标签，覆盖 17 种组合模式。§4.2 报告：组合 S-S-U 需要联合理解，模型表现明显弱于单模态显然有害的情形；遇到教育等上下文也会过度阻断。§5 的 34% 是“组合判断错误中，两种单模态判断都正确”的比例，不是总体错误率。Limitations 指出文本仅英语。

全文共 8,187 个样本、15 个有害类别。摘要报告清晰单模态安全信号上模型可超过 90%，需联合图文推理的组合约 20%–55%。Table 4 的三分类 F1 例子：GPT-4o 联合/图像/文本分别为 45.8/66.3/66.7，Gemini-2.5 为 65.3/67.4/72.3；总体联合输入弱于单模态。结构化安全推理对 GPT-4o 与 Qwen2.5-VL-7B 可提高约 8.6 和 9.1 F1，但最好联合 F1 仍明显低于人类 91.0。

## 本课题判断与边界

“看到风险物体就早退”必须考虑文本用途与政策例外；不能用单模态高置信替代组合判断。建议将 S-S-U 与含风险但合法的组合设为早出口和剪枝的压力子群。这是评测建议，原文没有验证本项目浅层方案的可行性。

关联：[[LLM-Wiki/research/visual-token-pruning/research-plan.md]]；[[LLM-Wiki/research/multimodal-compositional-safety/overview.md]]。
