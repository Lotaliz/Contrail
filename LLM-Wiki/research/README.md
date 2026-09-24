---
id: research-index
type: index
title: 研究方向索引
tags: [index, research]
status: active
updated: 2026-09-22
---

# 研究方向索引

research 以一个一级子目录对应一个研究方向或项目：

    research/
    ├─ README.md
    ├─ _template/
    │  ├─ overview.md
    │  └─ papers/
    └─ <project>/
       ├─ overview.md
       ├─ papers/
       ├─ reading-log.md
       ├─ landscape.md
       ├─ comparison.md
       ├─ gaps.md
       ├─ motivation.md
       └─ hypotheses.md

只有 overview.md 和 papers/ 是最低要求；其余综合文档按项目复杂度创建，并使用 synthesis 类型。

## 项目列表

| 研究方向 | 状态 | 范围摘要 | 最近更新 |
|---|---|---|---|
| [[LLM-Wiki/research/multimodal-safety-guard/overview.md\|多模态安全 Guard 双路线计划]] | active | 路线一研究图文组合式规避与兼容防御；路线二研究长政策编译与视觉—条款协同预算 | 2026-09-22 |
| [[LLM-Wiki/research/multimodal-compositional-safety/overview.md\|图文联合内容风险与组合式安全]] | active | strict 三标签与配对反事实数据、专业 Guard 漏洞测量、端到端逃逸及 legacy 非劣防御 | 2026-09-21 |
| [[LLM-Wiki/research/visual-token-pruning/overview.md\|长政策条件下的视觉—政策协同压缩]] | active | 长政策编译/条款检索与 pre-ViT 视觉选择协同，评测可变政策下的安全—时延 Pareto；保留 [[LLM-Wiki/research/visual-token-pruning/watch/overview.md\|近期论文追踪]] | 2026-09-22 |
| [[LLM-Wiki/research/safety-classifier-compression/overview.md\|安全判别系统的剪枝与蒸馏]] | active | 截至 2026-08-27；文本与多模态安全判别的吞吐、任务对齐剪枝和总成本 | 2026-08-27 |
| [[LLM-Wiki/research/variable-length-llm-serving/overview.md\|变长自回归 LLM 的批推理与流水线调度]] | active | 截至 2026-08-27；连续组批、KV 管理、chunked prefill、PP bubble 与 SLO | 2026-08-27 |
| [[LLM-Wiki/research/model-compression-privacy/overview.md\|模型压缩与隐私泄露]] | active | 单模型与多压缩版本发布下的成员推断、MIA 前沿定位及压缩后再训练边界 | 2026-09-15 |
| [[LLM-Wiki/research/ai-system-security-landscape/overview.md\|AI 系统安全问题版图]] | active | 安全属性 × 生命周期二维分类；覆盖模型、RAG、agent、serving、隐私与供应链 | 2026-09-15 |

> 表格内若使用别名 WikiLink，必须把竖线转义。

## 论文笔记约定

- 每篇论文使用一个 Markdown 文件，存放在所属项目的 papers 子目录。
- 文件名建议为 YYYY-first-author-short-title.md。
- source_id 必须对应 raw/sources.yaml。
- reading_level 使用 discovered、skimmed、deep-read。
- verification 使用 unverified、source-checked、reproduced。
- 一篇论文涉及多个方向时选择主项目存放，其他项目只建立链接，避免复制。

完整流程见 [[LLM-Wiki/metadata/workflows/README.md|研究工作流]]。

| [[LLM-Wiki/research/ai-safety-systems-security-venues/overview.md\|安全四大顶会中的 AI 安全系统工作]] | active | 2023—2026 安全四大顶会；内容安全、对齐、检测、运行时与 agent 架构，排除攻击方法 | 2026-08-25 |
