# 修改记录

本文件按实际发生的 Wiki 内容、结构和流程变化记录，与 Git 状态、暂存或提交无关。日期按新到旧排列。

统一格式：

    - [类型] [范围] 一句话说明结果（可选：详情链接）。

允许的类型：Added、Changed、Fixed、Deprecated、Removed。

## 2026-08-25

- [Added] [research/safety-classifier-compression] 调研 On-policy 蒸馏并凝练为概念实体，补充安全 Guard 的适用边界、方法路线、候选缺口与假设（[[LLM-Wiki/changes/2026-08-25-survey-on-policy-distillation.md|详情]]）。
- [Changed] [research/visual-token-pruning] 精读 VisPCO 的 Qwen2.5-VL 实验与官方实现，并新增不含代码的小规模预注册实验方案（[[LLM-Wiki/changes/2026-08-25-deep-read-vispco-qwen-experiment.md|详情]]）。
- [Changed] [wiki] 将 Wiki 品牌名统一为 Contrail，以云迹意象的冷色轨迹横幅重设 README 首页，并将视觉资产独立存放于仓库根目录 assets。

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
