---
id: note-2026-guo-token-budget-distillation
type: paper-note
title: "Token-Budget Distillation: Transferring Full-Token Semantics to Compressed Video Vision-Language Models"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation]
source_id: paper-guo-2026-token-budget-distillation
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Token-Budget Distillation: Transferring Full-Token Semantics to Compressed Video Vision-Language Models

来源：[原文](https://arxiv.org/abs/2608.28138)；阅读版本：2608.28138v1，2026-08-28；会议标注来自稿件，未独立确认 proceedings。

## 原文核验
已读图 1、§1–5、算法 1、表 1–3、图 2–4；未复现。

## 方法与直接证据
§3：full-token 冻结教师、FlashVID 压缩学生，只更新 LoRA；CE、答案位置 KL、GT margin、教师正确且置信过滤及 KD 权重控制。§4.1：LLaVA-Video-178K，三个主干、四个视频问答基准。表 2 在 LLaVA-Video、10% 保留率下，LoRA-only 均分 58.3，完整 TBD 58.9；增益不能全归于复杂 KD。表 1 的 Qwen3-VL-8B 同预算相对准确率仅 92.2%，并非普遍无损。

## 边界与研究判断
§5 承认完整教师训练成本和不可逆信息损失。图 4 单例 attention 不能证明因果 grounding。稿件未提供本项目所需的固定 FPR、长尾召回和 verdict P99 证据；不得把原模型称为理论准确率上界。可靠教师过滤、margin 蒸馏已有直接先例；候选差异必须涉及学生证据是否可见，而不只是教师是否正确。
代码：本次未核实可用官方实现；复现实参仍需补齐。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

