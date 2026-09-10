---
id: note-2026-na-responseguard
type: paper-note
title: "When Are Reasoning-Based Guardrails Not Efficient? ResponseGuard: A Fast Vision-Language Guard for Real-Time Moderation"
tags: [paper-note, research, safety-guardrail, multimodal-safety, content-moderation, vision-language-model, efficient-inference, safety-evaluation]
source_id: paper-na-2026-responseguard
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# ResponseGuard

来源：[arXiv 原文](https://arxiv.org/abs/2607.21401)；阅读版本：2607.21401v1；阅读 §1–6、表 1–3 与校准/选择性预测分析，未运行代码。

## 方法与直接证据

ResponseGuard 将图像、请求与响应的 pooled representation 直接映射到二分类概率，不生成 CoT。作者在 RTX A6000 上报告 ResponseGuard-2B 单次判定中位时延 67.6 ms，而比较的 GuardReasoner-VL-3B 约 10.12 s；两者骨干不同，因此这不是只移除 CoT 的同模型因果消融。ResponseGuard 在响应有害性加权 F1 上略高，但请求有害性整体低于推理 Guard。

## 视觉瓶颈与边界

论文 §5.4 报告差距集中在 image-only cells，并从 precision/recall、verdict attention 与一维可分性给出“感知可能是瓶颈”的一致迹象；两个设计的视觉编码器均冻结。作者明确说明未做解冻视觉编码器消融，且一次 trainable visual path 尝试没有改善 aggregate，因此“冻结编码器导致差距”仍是解释性假设。

这为安全任务专用视觉编码器训练提供直接动机，也要求本课题证明视觉前缀训练改善 image-only 与跨模态困难组，而不只改善总体 F1。其单次 pooled head 改变了输出形式；本项目若沿用首标签 Guard，须把完整判定 token 时延单独报告。

关联：[[LLM-Wiki/research/visual-token-pruning/motivation.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。

