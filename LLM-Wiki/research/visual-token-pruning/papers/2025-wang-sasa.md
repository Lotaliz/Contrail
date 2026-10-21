---
id: note-2025-wang-sasa
type: paper-note
title: "Self-Aware Safety Augmentation: Leveraging Internal Semantic Understanding to Enhance Safety in Vision-Language Models"
tags: [paper-note, research, multimodal-safety, safety-alignment, vision-language-model, safety-evaluation]
source_id: paper-wang-2025-sasa
reading_level: skimmed
verification: source-checked
status: active
created: 2026-10-10
updated: 2026-10-20
---

# SASA：让安全检测利用更充分的语义

## 场景与方法

作者研究 VLM 为何未充分识别恶意输入。将安全相关层、语义较充分的融合层、语言表达层分开；用注意力头消融定位安全相关组件，并借助较后层语义改善安全检测。

## 已核对证据

来源：[arXiv v1 正文](https://arxiv.org/html/2507.21637v1)。略读摘要、引言、图6/7、§3–5、表1/2/4和结论，未复现或完整核查附录。摘要页注明 ACM Multimedia 2025 接收，未独立核验会议题录。

- §3.3：比较危险/良性任务的头消融与表征子空间变化，定位语言主干中的安全相关头。
- §4、算法1：融合层与先前安全层做表征投影；最后训练输出 logits 的逻辑回归探针。不能简化成仅在早层运行的检测器。
- 表1/2：覆盖三个 VLM 的攻击、良性任务和探针分类；表4用结构相似的危险/良性输入比较直接探针，支持对模板捷径的控制。

## 对 Cx 的判断

提供“安全信号与充分语义出现的位置可能不同”的证据；文中的早层是语言层，不是 pre-ViT。投影的因果执行与实现成本尚未在本轮精读，不能照搬为低时延剪枝。关联 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|cx-policy-safety-representation-pruning（历史方案，已删除）]]；作为实现依据前需升级阅读。
