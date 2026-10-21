---
id: note-2024-helff-llavaguard
type: paper-note
title: "LlavaGuard: An Open VLM-based Framework for Safeguarding Vision Datasets and Models"
authors: [Lukas Helff, Felix Friedrich, Manuel Brack, Kristian Kersting, Patrick Schramowski]
year: 2024
venue: arXiv
source_id: paper-helff-2024-llavaguard
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, safety-guardrail, multimodal-safety, vision-language-model, safety-evaluation]
status: active
created: 2026-10-14
updated: 2026-10-14
---

# LlavaGuard：图像与可变审核政策

它把图像和政策输入VLM，输出安全判定、风险类别与理由。训练数据由SMID和补充网页图片构成，并加入类别被声明为非违规时的同图政策变化。

本轮略读[官方v2](https://arxiv.org/html/2406.05113v2)摘要、引言、§3–6主要方法/结果、结论和Appendix G，并目视查看士兵持枪、饮酒、泳池下棋三个例图。又核查[v3](https://arxiv.org/html/2406.05113v3)题录、数据/机制和结论，未把v2图号视为所有版本的图号。题录注明ICML2025；年份以初始2024预印本登记。未复现。

v2 §6/Table2报告其7B在自有held-out集balanced accuracy90.84%、recall91.39%。这些是作者专门训练模型的成绩，不是当前Qwen3-VL-2B或局部剪枝效果。政策例外处理已有明确先例。

Appendix G中持枪例图涉及角色与整体环境，饮酒图主体突出，泳池图多物体但安全依据未必要求高清局部。这是展示图的定向观察，无法估计用户派生数据的困难比例。数据卡有policy、url、rating、category、rationale；原始CSV本轮401，未取得随机行。标注许可不覆盖所有被引用图片。

项目判断：不能称原数据全都简单，也不能把主类移到Allowed后无条件继承safe。新增更细条件要核实原事实、其他违规及标签；原有例外翻转应作为基础对照。若要复现原始标注/训练或系统分析错误，再精读完整v3。

关联：[[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]]。
