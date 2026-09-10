---
id: note-2026-gu-ood-vtp
type: paper-note
title: "Visual Token Compression Enhances Robustness of MLLMs"
tags: [paper-note, research, vision-language-model, visual-token-pruning, multimodal-safety, safety-evaluation]
source_id: paper-gu-2026-ood-vtp
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Visual Token Compression Enhances Robustness of MLLMs

来源：[原文](https://arxiv.org/abs/2607.22716)；阅读版本：2607.22716v1；稿件会议 DOI 为占位符，不据此确认录用。

## 原文事实
阅读引言、图 1、§3–4 及结论。OOD-VTP 以视觉到语言特征空间距离筛除 token，目标是生成模型抗越狱和幻觉。表 3 比较统一第 14 层与逐基准最优层；表 4 用 SafeBench 拒答指标和 MME，表 5 用 CHAIR/HallusionBench。

## 边界与研究判断
“远离语言空间”是作者的 OOD 代理，不能等同于无关或危险。减少危险内容对生成模型的诱导，不保证检测器仍看到危险证据。这是与 Security Pitfalls 结论方向不同的必要反证，须按威胁模型解释，不能概括剪枝必然更安全或更不安全。
代码：[OOD-VTP](https://github.com/Eurek001/OOD-VTP)，未运行；下一步需在同批 Guard 样本比较召回与拒答的目标冲突。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

