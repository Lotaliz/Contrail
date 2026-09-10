---
id: note-2022-zong-self-slimmed-vit
type: paper-note
title: "Self-Slimmed Vision Transformer"
tags: [paper-note, research, visual-token-pruning, knowledge-distillation, efficient-inference]
source_id: paper-zong-2022-self-slimmed-vit
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-09
updated: 2026-09-09
---

# Self-Slimmed Vision Transformer

来源：[ECCV 2022 官方页](https://www.ecva.net/papers/eccv_2022/papers_ECCV/html/5408_ECCV_2022_paper.php)；阅读摘要与 §3.1–3.3 的 TSM、RTSM 和 FRD，未运行代码。

## 方法与直接证据

SiT 用可学习矩阵把 $N$ 枚 token 软聚合为 $\hat N$ 枚 token：$\hat X=\hat A X$。由于压缩后的非结构化 token 与教师的规则网格不再一一对应，训练期使用逆向 TSM（RTSM）把 $\hat N$ 枚 token 映射回 $N$ 枚重校准 token，再以逐 block token MSE 对齐完整 ViT 教师，同时加入 logit 蒸馏。RTSM 仅训练时存在，论文声称推理不增加其开销。

## 与本课题的边界

这是“少 token 先恢复成稠密表征，再做中间层语义对齐”的直接先例；因此 training-only decoder、全 token MSE 与逐层 feature reconstruction 都不能单独作为创新。RTSM 是学习到的非线性恢复器，不是闭式最小二乘校准；实验集中于 ImageNet 分类，也没有文本/政策条件、危险证据召回或学生可观察性约束。

关联：[[LLM-Wiki/research/visual-token-pruning/landscape.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。
