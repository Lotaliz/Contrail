---
id: paper-note-zhu-2026-hawk
type: paper-note
title: "HAWK: Head Importance-Aware Visual Token Pruning in Multimodal Models"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-zhu-2026-hawk
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# HAWK

来源：[CVPR 2026 官方页面](https://openaccess.thecvf.com/content/CVPR2026/html/Zhu_HAWK_Head_Importance-Aware_Visual_Token_Pruning_in_Multimodal_Models_CVPR_2026_paper.html)。本轮阅读摘要和方法概要，未运行代码。

HAWK 指出不同 attention head 承担不同视觉语义功能，不能对所有 head 的文本—视觉 attention 简单平均。它先估计 head importance，再加权聚合 text-guided attention 作为视觉 token 分数，全程 training-free。作者在 Qwen2.5-VL 上报告剪除 80.2% 视觉 token 后保留 96.0% 原始准确率，端到端时延降至 74.4%。

对安全 Guard，可迁移点是按安全任务校准 head 权重；但通用视觉 head importance 不等价于危害检出重要性，仍需 fixed-FPR 和证据切片验证。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]。

