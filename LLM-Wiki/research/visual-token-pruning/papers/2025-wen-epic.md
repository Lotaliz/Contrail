---
id: note-2025-wen-epic
type: paper-note
title: "Efficient Multi-modal Large Language Models via Progressive Consistency Distillation"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation]
source_id: paper-wen-2025-epic
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Efficient Multi-modal Large Language Models via Progressive Consistency Distillation

来源：[原文](https://arxiv.org/abs/2510.00515)；阅读版本：2510.00515v1；会议身份另核对 NeurIPS 2025 官方页。

## 原文核验
阅读摘要、引言、图 1–2、§3–5、表 1–3、附录 D–F；未运行代码。方法简称 **EPIC**，ICD 是附录 C 的整合变体，不应把整篇简称写成 ICD。

## 方法与直接证据
§3.3–3.4：共享权重的双前向，以较轻压缩分支指导较重压缩分支；沿预算或剪枝层位置渐进训练，SFT 加输出 KL。§4.1：LLaVA-665K 视觉指令微调，比较 DART、FastV、Random，不改主干结构。表 2：A100、POPE 8,910 样本、第二层压缩，CUDA 时间与 FLOPs 分开报告；并非 Guard 的单请求时延。表 3 消融蒸馏和渐进预算。

## 边界与研究判断
附录 E 仅讨论指令微调，预训练扩展留待未来；附录 F 明确未继续人类偏好对齐。其平均任务表现不能证明固定 FPR 的安全召回。它直接排除“首次无结构修改的多预算压缩蒸馏”；本课题须检验安全证据可见性与政策关系约束的额外作用。
代码：[作者仓库](https://github.com/ZichenWen1/EPIC)。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

