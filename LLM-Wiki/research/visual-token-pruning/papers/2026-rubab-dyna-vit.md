---
id: note-2026-rubab-dyna-vit
type: paper-note
title: "Dyna-ViT: Parameter-Free Pre-Encoder Token Pruning for Efficient Vision Transformers"
tags: [paper-note, research, visual-token-pruning, training-free, efficient-inference]
source_id: paper-rubab-2026-dyna-vit
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Dyna-ViT

来源：[CVPR 2026 Findings 官方页](https://openaccess.thecvf.com/content/CVPR2026F/html/Rubab_Dyna-ViT_Parameter-Free_Pre-Encoder_Token_Pruning_for_Efficient_Vision_Transformers_CVPRF_2026_paper.html)；阅读摘要和官方题录，未运行代码。

## 方法与直接证据

Dyna-ViT 在 encoder 前按无监督显著性代理排序 patch，只保留 Top-K，并保持标准 ViT 主干及 `[CLS]`、位置编码不变。论文在三个纯视觉基准上比较 L2 energy、Sobel 和 entropy 等评分，并报告训练/推理效率与准确率。

## 与本课题的边界

输入到首个 Transformer block 前删 patch 已有直接正式先例；“前置剪枝”和“不增加参数”本身都不足以构成贡献。Dyna-ViT 不看文本/政策，也没有验证低显著度危险证据、OCR 和困难安全子群。它应作为最便宜的前置无参基线，而非新方法核心。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。

