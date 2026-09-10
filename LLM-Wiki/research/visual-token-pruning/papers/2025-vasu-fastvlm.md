---
id: note-2025-vasu-fastvlm
type: paper-note
title: "FastVLM: Efficient Vision Encoding for Vision Language Models"
tags: [paper-note, research, vision-language-model, multimodal-pretraining, efficient-inference, efficiency-evaluation]
source_id: paper-vasu-2025-fastvlm
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# FastVLM

来源：[CVPR 2025 官方页](https://openaccess.thecvf.com/content/CVPR2025/html/Vasu_FastVLM_Efficient_Vision_Encoding_for_Vision_Language_Models_CVPR_2025_paper.html)；阅读摘要、效率设置与主要比较，未运行代码。

## 方法与直接证据

FastVLM 联合分析输入分辨率、视觉编码时延、输出视觉 token 数和 LLM 大小，使用新的 FastViTHD 混合视觉编码器减少高分辨率编码开销与输出 token。作者在 LLaVA-1.5 设置报告 3.2 倍 TTFT 改善；评测把图像编码与 LLM prefill 相加，并在 M1 Max 上分别使用 Core ML 与 MLX。

## 与本课题的边界

它证明视觉塔成本与送入 LLM 的 token 成本必须联合优化，也说明重新设计高效编码器是拥挤路线。本课题优先复用原视觉主干的浅层前缀，避免把新 backbone 架构作为贡献；FastVLM 必须作为换编码器上界或强系统基线。其通用 VLM 分数不代表固定 FPR 的安全困难召回。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/motivation.md]]。

