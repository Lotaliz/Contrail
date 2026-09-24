---
id: note-2026-chen-evoprune
type: paper-note
title: "EvoPrune: Early-Stage Visual Token Pruning for Efficient MLLMs"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-chen-2026-evoprune
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-16
updated: 2026-09-17
---

来源：[arXiv v1](https://arxiv.org/html/2603.03681v1)。本轮核 Algorithm 1、§3.2–3.3、§4.1、Tables 1–3 及附录层预算策略；未复现或下载原件，按 preprint 处理。

## 原文方法与执行位置

Algorithm 1 明确在视觉每层 Attention 后、MLP 前调用 ScoreGuidedMerge；默认 skip 策略是每隔一层合并，固定全局预算均分到选定层。相似性、局部多样性及 attention 高重要 token 保护共同决定配对。名称为 pruning，但核心操作是 score-guided token merging，不是纯 drop。

## 生成式证据与边界

LLaVA-1.5-7B 图像问答，LLaVA-Video-7B/Qwen2 主干视频问答，NVIDIA H20。摘要称 VideoMME 达到 2× 推理、性能下降小于 1%；这是作者自报，不是统一基准测量。Table 1 图像保留 128 时总体相对 latency 0.84、平均相对性能 97.9%；pre-LLM latency 1.10，说明 ViT 内减少 token 不保证选择/合并计入后一定加速该阶段。Table 3 的视频分数含不同预算/消融，不把摘要速度与任意表中准确率混合成单工作点。

解释性 caveat：attention 方向/归一化和 diversity 权重描述应与实现逐项核对，尚未审计代码；不能因模型名和摘要称 SOTA 就确认其优于统一复现基线。

2026-09-17 时延审计：请求 batch 未明确，64 帧不是 batch=64。§4.2 将 overall 称 end-to-end，定义 pre-LLM 含视觉编码和剪枝、LLM 含语言模型推理；Table 2 的 64×64 tokens 同点 overall 为 0.55×（1.82×）、多任务相对性能 99.7%。但 §4.3/Figure 3 的效率图明确为 TTFT，所核文字未固定完整答案 decode 长度；因此不把 overall 提升为已确认全输出 E2E，也不将摘要 2× 与该表性能强行拼接。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]]。
