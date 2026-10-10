---
id: note-2025-zou-shiftdc
type: paper-note
title: "Understanding and Rectifying Safety Perception Distortion in VLMs"
tags: [paper-note, research, multimodal-safety, safety-alignment, vision-language-model, safety-evaluation]
source_id: paper-zou-2025-shiftdc
reading_level: skimmed
verification: source-checked
status: active
created: 2026-10-10
updated: 2026-10-10
---

# ShiftDC：对照激活中的安全方向

## 场景与方法

作者研究有害语义从文字改成图像后，VLM 为何更易回答恶意请求。通过安全/危险文字的平均激活差得到方向，再比较图文输入与文字描述输入的激活偏移，校正其沿安全方向的分量。

## 已核对证据

来源：[arXiv v1 正文](https://arxiv.org/html/2502.13095v1)。略读摘要、引言、图1/7、§3–6、主结果表、误报表5及结论；未复现或全面检查附录。

- §3、式2：方向来自语言层最后 token 的 residual stream 均值差；不是视觉 token 定位器。
- §4–5：图像引入的偏移可能使危险输入更接近安全侧；校正依赖图像描述对照。
- §6.4/6.5：同时检查安全分类和良性误报，不能仅看拒答增多。
- §6.7：图像描述和对照激活引入两次额外前向；不是零开销早期剪枝。

## 对 Cx 的判断

支持正反样本均值差作为诊断基线；跨模态分布变化和误报需分别解释。本文没有动态政策、单框预算或早期视觉证据保留评测。关联 [[LLM-Wiki/research/visual-token-pruning/cx-policy-safety-representation-pruning.md]]；暂保持 skimmed。
