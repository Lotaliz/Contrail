---
id: visual-token-pruning-overview
type: research-overview
title: "视觉 Token 剪枝研究：训练参与的多模态安全判别"
tags: [research, visual-token-pruning, multimodal-safety, knowledge-distillation]
status: active
created: 2026-09-08
updated: 2026-09-10
---

# 项目入口

截至 2026-09-08，研究主线进一步收束为**政策因果安全充分视觉前缀**：以完整视觉塔作训练期教师，在分辨率×patch×视觉深度压缩格上寻找会造成漏报的尾部状态，把图文—政策判别压力前移到可部署的浅层前缀。原有唯一综合主文继续保留，覆盖更新决策部分；来源和审查文件不复制旧实验。

- [[LLM-Wiki/research/visual-token-pruning/multimodal-safety-token-pruning-research-plan.md|主方案、训练流程与实验优先级]]
- [[LLM-Wiki/research/visual-token-pruning/landscape.md|训练与压缩的机制背景]]
- [[LLM-Wiki/research/visual-token-pruning/comparison.md|统一维度与最近邻比较]]
- [[LLM-Wiki/research/visual-token-pruning/gaps.md|候选空白、反证与淘汰条件]]
- [[LLM-Wiki/research/visual-token-pruning/motivation.md|证据约束下的正式动机草稿]]
- [[LLM-Wiki/research/visual-token-pruning/reading-log.md|查询、阅读层级与覆盖边界]]
- [[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md|视觉编码器浅层剪枝与可解释性证据]]

## 范围与优先次序

第一优先：G0 安全充分视觉前缀与 G0-A 最坏压缩状态训练。第二优先：G1 证据可观察性，以及 G0-B 的全局底图+稀疏高清残差。第三优先：攻击泛化和 serving。优先固定 Qwen3-VL-2B 主干；迁移验证使用另一 VLM 家族。先图像+文本，再扩展短视频，长视频不作为第一轮必要条件。

训练可改权重；允许 LoRA 训练后合并。完整视觉塔、辅助出口与压缩状态搜索仅在训练期使用；部署只保留原视觉塔前 $d$ 层、原 projector、LLM 与判定接口。默认不新增 Q-former、memory tokens、在线 CoT 或动态 router。G0-B 可增加极小 patch scorer，但必须单独计时并证明收益超过 QuietPrune 与无参 pre-encoder 基线。

目标 venue 是研究选择，不是录用预测：CVPR 等视觉顶会为主线，安全四大顶会在 Guard 压缩绕过及有效防御证据充分时优先；OSDI 仅在有独立系统问题时考虑。

## 当前证据状态

已核原文的训练先例包括 EPIC、TBD、ViCO、EfficientVLM 与 METR；前置/早剪强近邻包括 Dyna-ViT 与 QuietPrune。ResponseGuard 提供视觉感知瓶颈假设，SAP 进一步压缩安全的新颖性门槛。未运行新模型实验，不承诺召回或时延数字。已有 XGuard 结果支持效率基线选择，但类别覆盖不足；旧的 text-only 安全微调负结果不应被删除。G0–G6 均为待验证候选，不因写入动机而变成已证明贡献。
