# 修改记录

本文件按实际发生的 Wiki 内容、结构和流程变化记录，与 Git 状态、暂存或提交无关。日期按新到旧排列。

统一格式：

    - [类型] [范围] 一句话说明结果（可选：详情链接）。

允许的类型：Added、Changed、Fixed、Deprecated、Removed。

## 2026-08-26

- [Fixed] [experiments/20260825-safety-*] 修复 Llama Guard 1B/8B chat template 与判定位置实现错误，重跑三个预注册 safety-classifier-compression 实验并更新实验 README 与项目 overview：decoder S1-adapted 由 0.5000 修正为 0.9000，T8 由 0.5095 修正为 0.8141，encoder M1 由 0.7226 修正为 0.7997；三实验时延目标均达标，质量目标仍未达成（详见各实验 README）。
- [Added] [experiments/20260826-safety-pruning-finetuned] 完成 LoRA 微调后 Qwen2.5-VL-3B 安全判别在 60%–90% 视觉 token 剪枝下的性能扫描（9 条件 × 300 样本）：微调对 unsafe recall 无提升（C0=0.660），全剪枝范围最大降幅 < 3 pp，结论为检出率由模型固有能力决定而非 token 数量。
- [Added] [raw/sources] 登记 BeaverTails 数据集（dataset-ji-2023-beavertails），作为实验 20260826 LoRA 微调来源。
- [Changed] [metadata/tags] 修复 7 个 frontmatter 分隔符错误，为 56 篇论文补充受控技术标签并重构分类标签索引（[[LLM-Wiki/changes/2026-08-26-normalize-technical-tags.md|详情]]）。

## 2026-08-25

- [Changed] [research/safety-classifier-compression] 以安全顶会审稿视角重构 Guard 轻量化动机，新增计算不对称、自适应攻击与多模态证据完整性的研究缺口和投稿定位。
- [Changed] [research/ai-safety-systems-security-venues] 精读 Sentinel 与 VLM Unsafe Concepts，补全创新、研究场景、方法、证据定位、局限及标签，并登记原始论文 PDF。
- [Added] [research/ai-safety-systems-security-venues] 完成 2023—2026 安全四大顶会中内容安全、对齐、检测与系统治理工作的保守调研，纳入20篇核心论文并明确排除攻击方法（[[LLM-Wiki/changes/2026-08-25-survey-ai-safety-systems-security-venues.md|详情]]）。
- [Changed] [research/ai-safety-systems-security-venues] 重新泛读核对14篇现有论文，并将英文阅读记录统一改写为中文结构化笔记（[[LLM-Wiki/changes/2026-08-25-survey-ai-safety-systems-security-venues.md|详情]]）。

- [Changed] [experiments/20260825-vispco-qwen25vl-small] 修复 v1 hook 实现（KV-cache 绕过问题），改用 scoring pass + embedding 归零，重跑 Phase 1 v2（20 样本，B0 macro=0.817 vs B1=0.350，剪枝实际生效）与 Phase 2 v2（275 样本，六条件），H1 不满足（V2 相对 B1 仅 +0.73 pp），TextVQA 50% 预算下几乎归零；完整记录 v1/v2 运行、实现限制与序列压缩后续路径。
- [Added] [experiments/20260825-vispco-qwen25vl-small] 执行 VisPCO Qwen2.5-VL-3B 小规模配置优化测试（Phase 0–2 v1），记录环境冻结（模型 SHA、GPU、依赖版本）、负向运行（HF generate KV-cache 导致所有条件输出完全相同）并记录修复路径。
- [Added] [research/safety-classifier-compression] 调研 On-policy 蒸馏并凝练为概念实体，补充安全 Guard 的适用边界、方法路线、候选缺口与假设（[[LLM-Wiki/changes/2026-08-25-survey-on-policy-distillation.md|详情]]）。
- [Changed] [research/visual-token-pruning] 精读 VisPCO 的 Qwen2.5-VL 实验与官方实现，并新增不含代码的小规模预注册实验方案（[[LLM-Wiki/changes/2026-08-25-deep-read-vispco-qwen-experiment.md|详情]]）。
- [Changed] [wiki] 将品牌视觉与 Wiki 内容结构分离，在仓库根目录建立主 README 与响应式 HTML 封面，并移除 LLM-Wiki 内部 README。

## 2026-08-24

- [Added] [research/safety-classifier-compression] 深读 SafeWatch 并建立可生成归因的多模态自回归 Guard Token 剪枝证据、边界与实验路线（[[LLM-Wiki/changes/2026-08-24-safewatch-attribution-guard-token-pruning.md|详情]]）。

- [Added] [research/visual-token-pruning] 扩展图文多模态分类与生成 Token 剪枝调研，登记八篇正式论文并建立挑战、路线、反证与研究缺口（[[LLM-Wiki/changes/2026-08-24-survey-multimodal-token-pruning.md|详情]]）。

- [Added] [research/safety-classifier-compression] 完成近三年安全判别及相邻文本/多模态分类的剪枝与蒸馏进展调研（[[LLM-Wiki/changes/2026-08-24-survey-safety-classifier-compression.md|详情]]）。
- [Added] [research/visual-token-pruning] 精读 STViT 并建立涵盖 ViT 结构、任务、训练推理与 patch token 的视觉 Token 剪枝基础概念。
- [Changed] [metadata/changelog] 统一为按日期、类型与范围记录的 CHANGELOG，并移除所有 Git 状态依赖（[[LLM-Wiki/changes/2026-08-24-unify-changelog-style.md|详情]]）。
- [Added] [research/visual-token-pruning] 完成 2023–2026 视觉模型 Token 剪枝顶会进展调研（[[LLM-Wiki/changes/2026-08-24-survey-visual-token-pruning.md|详情]]）。
- [Added] [automation] 添加标准研究工作流、五个仓库技能、三级论文阅读、Wiki 校验器与 Codex Stop Hook（[[LLM-Wiki/changes/2026-08-24-standardize-research-workflows.md|详情]]）。
- [Changed] [research] 建立 research 项目分区并清理 concepts 种子概念（[[LLM-Wiki/changes/2026-08-24-add-research-layout.md|详情]]）。
- [Fixed] [index] 修复 entities 索引中 WikiLink 竖线破坏 Markdown 表格列的问题。
- [Added] [wiki] 初始化 LLM Wiki 的原始资料、概念、实验、索引、模板和维护结构（[[LLM-Wiki/changes/2026-08-24-initialize-wiki.md|详情]]）。
