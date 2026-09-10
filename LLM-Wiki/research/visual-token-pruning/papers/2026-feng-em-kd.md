---
id: note-2026-feng-em-kd
type: paper-note
title: "EM-KD: Distilling Efficient Multimodal Large Language Model with Unbalanced Vision Tokens"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation]
source_id: paper-feng-2026-em-kd
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-09
updated: 2026-09-09
---

# EM-KD

来源：[AAAI 2026 官方页](https://ojs.aaai.org/index.php/AAAI/article/view/39254)；阅读摘要、视觉 token matching、VSD、VLAD 与总损失，未运行代码。

## 方法与直接证据

EM-KD 针对教师与高效学生视觉 token 数不等的问题，先把视觉 hidden states 经 LM head 解码为 vocabulary logits，以 Manhattan distance 构造代价并用 Hungarian matching 建立 token 对应。匹配后，VSD 对视觉词表分布做 reverse KL，VLAD 对视觉—文本 cosine affinity matrix 做 Smooth L1；再与监督损失及 response-logit 蒸馏联合训练。其学生使用视觉特征自适应平均池化和两层 MLP 压缩器。

## 与本课题的边界

“不等长视觉 token 的匹配后语义蒸馏”和“对齐图文关系而非仅 hidden MSE”已有直接正式先例。EM-KD 匹配少量学生 token 与教师 token 子集，并不把少量 token 重构为全部教师空间位置；它也不研究安全判别的低显著度证据和固定 FPR 长尾召回。若本项目使用匹配，应超过 Hungarian+VSD+VLAD，而不是只替换距离函数。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。
