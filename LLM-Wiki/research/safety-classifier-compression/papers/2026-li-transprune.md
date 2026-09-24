---
id: paper-note-li-2026-transprune
type: paper-note
title: "TransPrune: Token Transition Pruning for Efficient Large Vision-Language Model"
tags: [paper-note, research, vision-language-model, visual-token-pruning, efficient-inference]
source_id: paper-li-2026-transprune
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# TransPrune

来源：[CVPR 2026 官方页面](https://openaccess.thecvf.com/content/CVPR2026/html/Li_TransPrune_Token_Transition_Pruning_for_Efficient_Large_Vision-Language_Model_CVPR_2026_paper.html)。本轮阅读摘要和方法概要，未运行代码。

TransPrune 将视觉 token 的层间表示变化 TTV 与 instruction-guided attention 结合：前者衡量 token 在模型传播中是否仍承载语义变化，后者衡量当前指令对该视觉 token 的需求；随后渐进剪枝。方法 training-free，覆盖 LLaVA-v1.5、LLaVA-NeXT 与 Qwen2.5-VL，作者报告推理 TFLOPs 降低超过一半而保持可比性能。

它比单一 attention 更适合安全任务，因为低 attention 但表示仍发生显著变化的视觉 token 不会轻易被删；不过层间 transition 仍需执行前层，不能节省完整视觉塔。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]。

