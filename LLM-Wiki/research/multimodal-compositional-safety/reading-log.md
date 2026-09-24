---
id: multimodal-compositional-safety-reading-log
type: synthesis
title: 图文联合内容风险调研记录
tags: [research, multimodal-safety, safety-evaluation, source]
project_id: multimodal-compositional-safety
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-zhou-2024-multimodal-situational-safety, paper-kiela-2020-hateful-memes, paper-singguard-team-2026-singguard, paper-zong-2024-vlguard, paper-zhang-2024-spa-vl, paper-chakraborty-2024-cross-modal-safety, paper-gou-2024-ecso, paper-shayegani-2023-jailbreak-pieces, paper-lee-2025-elite, paper-liu-2025-guardreasoner-vl, paper-chi-2024-llama-guard-vision, paper-huang-2025-llavashield, paper-wang-2026-safeatlas-vl]
status: active
created: 2026-09-20
updated: 2026-09-21
---

# 图文联合内容风险调研记录

## 2026-09-21：调研晋升为攻击—测量—防御路线

保留本页全部来源、筛选和证据边界；当前研究计划不再以快速图文 Token 判别器为中心，而是以 strict 数据攻击协议、专业 Guard 统一测量、端到端组合式逃逸和 legacy 非劣防御为主。完整计划见 [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md]]。

## 检索范围

- **原调研截止日期：** 2026-09-20；2026-09-21 仅重组研究计划，未新增论文检索。
- **问题：** 安全图像与安全文本联合后产生有害意图时，任务模型与安全判别模型是否失效；数据/攻击、任务模型对齐和 Guard 防御分别发展到什么程度。
- **来源：** ACL Anthology、arXiv、OpenReview/ICLR、ECVA/ECCV，以及 Wiki 已登记的原始论文笔记。
- **代表查询：** `safe image safe text unsafe combination VLM safety`、`cross-modal hidden intent guardrail`、`multimodal safety classifier joint image text`、`situational safety VLM`、`multimodal guard response safety`、`safe-safe-unsafe benchmark`。

## 纳入标准

1. 优先纳入直接定义或评测 `safe image + safe text -> unsafe composition` 的工作。
2. 纳入能够隔离单模态与联合错误、或评测自动安全判别器的工作。
3. 防御侧纳入多模态安全 SFT/偏好对齐、推理时转换、原生 Guard、推理式 Guard 和政策条件化 Guard。
4. 将仇恨梗图、情境安全、多轮风险累积和对抗视觉 embedding 作为机制近邻，明确其不等同于严格 `S-S-U`。

## 排除或降级标准

- 仅把完整有害文本排版到图像中，且没有证明图像语义安全的 OCR jailbreak，不计作核心 strict 证据。
- 只报告总体 ASR/F1、无法区分图片/文本/组合标签的工作，不用于证明联合必要性。
- 博客、二手综述和搜索摘要只用于发现，不作为事实依据；综合结论回到论文正文或官方出版页。
- 模型或数据未公开且 strict 子集数量未报告时，保留为有限证据，不外推成通用结论。

## 候选筛选与阅读层级

| 工作 | 层级 / 核验 | 决定 | 作用 |
|---|---|---|---|
| SIUO | skimmed / source-checked | 核心纳入并建笔记 | strict 定义、构造与任务模型失效 |
| MSTS | skimmed / source-checked | 核心纳入并建笔记 | strict 生成测试、文本对照、8 个自动分类器 |
| VLSU | skimmed / source-checked；复用既有笔记 | 核心纳入 | 三标签组合、单/双模态消融、borderline |
| Hateful Memes | skimmed / source-checked | 历史先例并建笔记 | benign confounder 与联合审核 |
| MSSBench | skimmed / source-checked | 近邻纳入并建笔记 | 安全活动随视觉情境翻转 |
| SingGuard | skimmed / source-checked；扩展既有笔记 | 核心防御证据 | strict hidden-intent 合成与 Guard attack split |
| VLGuard | discovered / abstract source-checked | 防御基线 | 广义多模态安全 SFT，strict 未单列 |
| SPA-VL | discovered / abstract source-checked | 防御基线 | 大规模安全偏好对齐，strict 未单列 |
| Cross-Modal Safety Alignment | discovered / abstract source-checked | 防御近邻 | 文本 unlearning 跨模态迁移；主要非 strict 攻击 |
| ECSO | discovered / abstract source-checked | 防御近邻 | 图转文激活语言侧对齐 |
| Llama Guard 3 Vision | discovered / source-checked；复用既有笔记 | Guard 基线 | MSTS 专用判别器对照 |
| GuardReasoner-VL | discovered / source-checked；复用既有来源 | Guard 基线 | 推理式多模态 Guard |
| LLaVAShield/MMDS | discovered / abstract source-checked | 时序扩展 | 多轮风险累积与跨模态联合审核 |
| SafeAtlas-VL | skimmed / source-checked；复用既有笔记 | Guard 数据近邻 | 大规模目标条件化数据，但联合必要性未做消融 |
| ELITE | discovered / abstract source-checked | 广义 benchmark | 多种模态安全极性与 evaluator |
| Jailbreak in Pieces | discovered / abstract source-checked | 攻击近邻 | 对抗 embedding，不属于自然 strict 语义 |

## 版本与证据边界

- SIUO 使用 Findings of NAACL 2025 正式版本及 arXiv v2 正文。
- MSTS 当前来源为 arXiv v1，页面标注 under review；结果未复现。
- VLSU 使用 arXiv v2，既有笔记记录 Apple 页面标注 ICLR 2026；未做模型复现。
- MSSBench 不同论文版本出现 1,820、1,840/1,960 等规模口径，综合表不混算；复现前需锁定具体 release。
- SingGuard 使用 2026-06 的 arXiv v1；strict 子集规模未单独披露，训练/测试合成流程未独立审计。
- 所有数值均来自原论文，未在本地运行数据或模型。

## 完成检查

- [x] 明确 strict 核心范围与相邻攻击边界。
- [x] 记录检索截止日期、来源、查询、纳入与排除标准。
- [x] 把发现来源登记到 `raw/sources.yaml`，复用现有论文笔记避免重复。
- [x] 从数据构造、任务模型对齐、Guard 判别三侧形成机制版图与比较表。
- [x] 将事实、作者结果、个人推断和待实验假设分开。
- [x] 交由 wiki-finalize 完成索引、日期、CHANGELOG 与校验。
