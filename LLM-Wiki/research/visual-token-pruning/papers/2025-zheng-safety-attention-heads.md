---
id: note-2025-zheng-safety-attention-heads
type: paper-note
title: "Spot Risks Before Speaking! Unraveling Safety Attention Heads in Large Vision-Language Models"
tags: [paper-note, research, multimodal-safety, jailbreak-defense, vision-language-model, safety-evaluation]
source_id: paper-zheng-2025-safety-attention-heads
reading_level: skimmed
verification: source-checked
status: active
created: 2026-10-10
updated: 2026-10-20
---

# SAHs：从内部激活识别危险输入

## 场景与方法

作者希望在 VLM 回答前识别恶意请求。对语言模型注意力头的输出训练线性探针，选出能区分危险与良性输入的头，再拼接其激活训练逻辑回归检测器。这里的“安全头”是能读出相关信息的内部组件，不是图像区域。

## 已核对证据

来源：[arXiv v1 正文](https://arxiv.org/html/2501.02029v1)。本轮略读摘要、引言、图7、§3–5主要机制、表1/5和结论；未保存原件、读完附录或复现。

- §3.1：主信号来自首次生成时语言层注意力头、上下文最后位置；已经经过视觉编码和图文前向。
- §3.2、图5：头消融影响拒答，提供组件级干预证据；没有逐视觉 token 的因果贡献证明。
- 表1：覆盖 LLaVA-1.5、MiniGPT4、Qwen-VL-Chat，评测攻击成功率及良性通过率。
- 表5、§5.3：ViT 探针在 MM-Safety 上约92.61–94.04%准确率，在 VLGuard 上均为50%；语言层最后位置为98.42%。视觉信号的可用性取决于危险是否来自图像或图文组合。

## 对 Cx 的判断

支持校准集探针；不证明 Qwen3-VL 早期视觉层具有政策判别方向，也不证明这些激活适合提前剪枝。首次生成前检测仍需主干计算。关联 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|cx-policy-safety-representation-pruning（历史方案，已删除）]]；暂保持 skimmed，若作为实现依据需精读。
