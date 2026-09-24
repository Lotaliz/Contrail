---
id: multimodal-compositional-safety-motivation
type: synthesis
tags: [research, multimodal-safety, safety-alignment, safety-guardrail, safety-evaluation]
project_id: multimodal-compositional-safety
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-singguard-team-2026-singguard]
status: active
created: 2026-09-20
updated: 2026-09-21
title: "图文联合风险攻击、测量与防御的研究动机"
---

# 图文联合风险攻击、测量与防御的研究动机

## 已有多来源支持的事实

- SIUO、MSTS、VLSU 三项独立工作均发现：当风险只能从图文组合推出时，任务模型或安全分类模型显著弱于单模态显式风险场景。
- VLSU 的三标签分析表明，联合错误不只是视觉或文本感知错误；34% 的联合错误中两个单模态判断都正确。
- MSTS 表明，任务模型产生有害回复后，现有专用审核器仍可能出现极低的 unsafe recall。
- SingGuard 的自建 strict attack split 初步表明，面向组合风险的定向数据和政策推理监督可能修复一部分缺口。

## 正式动机

现有多模态安全系统常把视觉安全、文本安全和联合安全视为同一分类任务，训练数据又允许模型依赖危险词、危险物体或攻击模板。结果是系统可以分别“看懂”图片与文本，却没有学会判断二者关系是否改变政策标签。已有研究已经证明现象存在，因此本项目不能以“首次发现 safe-safe-unsafe”为贡献；需要推进到**专业 Guard 的统一测量、可利用的部署级联风险和兼容既有能力的防御**。

研究主张是：用三标签、同图换文和同文换图的配对反事实，把单模态感知正确但组合政策错误单独识别出来；在输入 Guard—任务模型—输出 Guard 的同一系统中测量组合式逃逸；再用只建模组合增量的 residual adapter 修复该漏洞，并通过 legacy non-inferiority 约束避免以整体过度拒绝换取 strict recall。

## 方法假设

若训练数据同时满足：

1. 每条样本有人类验证的 $(y_I,y_T,y_{I\oplus T})$；
2. 同图换文、同文换图产生组合标签翻转；
3. 监督显式覆盖实体—动作/对象—意图关系和对应政策规则；
4. 良性敏感与 borderline 反例保持类别平衡；

则相较普通多模态安全 SFT，组合风险 residual adapter 在未见类别、未见生成器和外部 strict benchmark 上的 unsafe recall 应提高，同时在预注册非劣 margin 内保持原有显式风险与良性样本表现。该句是待实验验证的假设，不是已有结果。

## 论文贡献需要满足的门槛

- 不只发布更多 `S-S-U` 样本，而要量化联合必要性、生成器泄漏和人类一致性。
- 不只比较通用 VLM，而要覆盖至少一种任务模型和两类专用 Guard。
- 不只报告总体 F1/ASR，而要报告固定 FPR recall、最坏类别、safe-by-accident、帮助性和端到端级联漏报。
- 防御收益必须在外部 strict benchmark 与真实图片子集上保留；只在同源合成测试集提升不足以成立。

## 尚未成为结果的部分

“专业 Guard 普遍存在可利用漏洞”“关系 residual 优于仅增加 strict 数据”“compatibility loss 可实现 legacy 非劣”“防御可承受自适应攻击”均为待实验假设。现有论文只能支持研究价值，不能替代这些结果。完整计划见 [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md]]。
