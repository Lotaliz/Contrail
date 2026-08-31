# 修改记录

本文件按实际发生的 Wiki 内容、结构和流程变化记录，与 Git 状态、暂存或提交无关。日期按新到旧排列。

统一格式：

    - [类型] [范围] 一句话说明结果（可选：详情链接）。

允许的类型：Added、Changed、Fixed、Deprecated、Removed。

## 2026-08-31

- [Changed] [research/visual-token-pruning] 精读 TRIPS、PuMer、FastV、SparseVLM、VisionZip、DivPrune 与 SafeWatch，补齐问题场景、方法流程、实验条件、证据边界及多模态安全判别建议。
- [Added] [research/safety-classifier-compression] 精读 Ghosted Layers，登记 arXiv v2 原件并梳理无约束边界激活对齐、闭式求解、质量—效率证据、数学表述边界与安全 Guard 复用假设。
- [Added] [research/safety-classifier-compression] 调研 MHA 与 MLP 的任务作用、细粒度冗余和整块剪枝敏感性，形成多模态安全 Guard 的联合预算建议。
- [Fixed] [wiki] 将残留的 LaTeX `\[...\]` 与 `\(...\)` 公式统一改为 Markdown 阅读器支持的 `$$...$$` 与 `$...$` 语法，并完成全库扫描。

## 2026-08-28

- [Added] [research/safety-classifier-compression] 精读 Numerical Pruning，梳理 Newton 连续 mask、全局 attention-head/MLP-channel 结构选择、闭式权重补偿、实验依据与数学实现边界。
- [Changed] [research/visual-token-pruning] 核验自适应模型规模的子网抽取、权重驻留、模块加载和条件执行语义，并明确其在多模态安全 Guard 中的适用边界（[[LLM-Wiki/changes/2026-08-28-verify-adaptive-model-size-execution.md|详情]]）。

## 2026-08-27

- [Added] [research/safety-classifier-compression] 调研 BlockPruner 替代重要性指标，形成多模态安全任务的前向代理、Taylor/Fisher 与迭代真实消融三级剪枝方案（[[LLM-Wiki/changes/2026-08-27-survey-task-aligned-pruning-importance.md|详情]]）。
- [Added] [research/variable-length-llm-serving] 调研变长自回归请求的连续组批、Paged KV、chunked prefill、流水线均衡与 prefill/decode 解耦，结论为常规难题已较好解决但严格 SLO 和复杂集群下仍非彻底消失。
- [Changed] [research/visual-token-pruning] 深读 Sarathi-Serve、NanoFlow 与 Prism，补全请求组批、设备内异构资源重叠和跨模型显存弹性三层问题场景、系统创新、实验目的及证据边界。

## 2026-08-26

- [Changed] [research/visual-token-pruning] 补充 OSDI/SOSP/NSDI 动态网络与推理 serving 调研，将多模态 Guard 课题重构为风险/SLO 约束下的 Token—主干二维弹性执行、批处理与回退系统（[[LLM-Wiki/changes/2026-08-26-osdi-dual-adaptive-guard-serving.md|详情]]）。
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
