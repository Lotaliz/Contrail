---
id: paper-note-sun-2026-hi-lo-prune
type: paper-note
title: "Hi-Lo Prune: Look at What You'll Lose before Pruning with Hierarchical Token Selection"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-sun-2026-hi-lo-prune
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# Hi-Lo Prune

来源：[CVPR 2026 官方页面](https://openaccess.thecvf.com/content/CVPR2026/html/Sun_Hi-Lo_Prune_Look_at_What_Youll_Lose_before_Pruning_with_CVPR_2026_paper.html)。本轮阅读摘要和方法概要，未运行代码。

## 方法与直接证据

Hi-Lo Prune 在视觉编码后做 coarse-to-fine 的视觉 token 候选选择，在早期 LLM 层将待删 token 的信息通过 attention-guided merging 吸收到保留 token，再物理移除低信息候选。官方实验覆盖 Qwen2-VL、Qwen2.5-VL 与 Qwen3-VL。

## 对当前场景的意义

这是目标架构上的强 visual-only 基线，也说明“先回收信息再删除”比直接 Top-k 更值得迁移到安全证据保护。但它仍不剪输入文本；用户指令只参与模型推理，不能作为视觉—文本共同输入剪枝的证据。安全标签与简短归因、固定 FPR 和危害证据充分性均未验证。

关联：[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]。
