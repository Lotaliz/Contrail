# 修改记录

本文件按实际发生的 Wiki 内容、结构和流程变化记录，与 Git 状态、暂存或提交无关。日期按新到旧排列。

统一格式：

    - [类型] [范围] 一句话说明结果（可选：详情链接）。

允许的类型：Added、Changed、Fixed、Deprecated、Removed。

## 2026-09-09

- [Changed] [metadata, skills, research/visual-token-pruning] 将 ETC 与 OTPrune 的公式改为 Markdown 预览支持的 `$...$` 和 `$$...$$`，并把数学定界符规范写入维护约定、研究技能及 Wiki 校验器。
- [Changed] [research/visual-token-pruning] 将 ETC 与 OTPrune 升级为精读，区分训练期任务表征重构与无恢复的 OT 子集覆盖，补全执行路径、实验边界及面向早层安全充分性蒸馏的迁移判断。
- [Changed] [concepts/technology] 补充标准 ViT 从 RGB patch 到 `[B,N,D]` token 序列的张量变换、颜色通道投影与编码器输入口径，并澄清固定序列长度下的逐层计算、并行注意力、真实 token 剪枝位置及已有早剪先例。
- [Changed] [research/visual-token-pruning] 补检少量视觉 token 与完整表征的恢复和对齐方法，新增 SiT/FRD、EM-KD、RESTORE、OTPrune 四条来源及论文笔记，并将候选空白收束为安全证据加权的训练期线性可恢复性。

## 2026-09-08

- [Changed] [research/visual-token-pruning] 对缩短视觉塔、前置剪枝和压缩样本再训练做直接排重，将方法收束为政策因果安全充分视觉前缀、最坏压缩格训练与压缩翻转回放，并新增 8 条来源及论文笔记（[[LLM-Wiki/changes/2026-09-08-safety-sufficient-vision-prefix.md|详情]]）。

- [Changed] [research/visual-token-pruning] 将主线更新为同结构的任务与压缩联合训练，补充 EPIC、TBD、ViCO 等 14 条来源及 12 篇分级笔记，重写背景、候选空白和动机并加入可见性约束训练对照（[[LLM-Wiki/changes/2026-09-08-training-aware-visual-safety-pruning.md|详情]]）。

- [Changed] [research/ai-safety-systems-security-venues] 将 HMGUARD 从泛读升级为精读，补全 harmful meme 任务场景、HMCOT 方法、主结果与消融，并登记原始 PDF 及指标一致性、复现和部署证据边界。
- [Changed] [research/visual-token-pruning, experiments/20260908-bidirectional-token-intervention] 将 label-first 归因界定为可能受首标签中介的事后合理化，登记 Unfaithful CoT、label—rationale association 与 RORA，并加入标签前缀反事实、span 级标签支配指数和低成本 evidence-first/延迟承诺实验。
- [Added] [experiments/20260908-bidirectional-token-intervention] 将视觉 Token 剪枝的纠错/致错双向翻转预注册为因果干预审计，区分语义干扰删除、证据/关系损失、attention/position 重标定与随机边界抖动，并登记 DART、CrisPrune、EmbedLens、Information Horizon、VASparse 和 VisPruner 来源。
- [Changed] [research/visual-token-pruning] 调研视觉 Token 剪枝中的复杂推理退化、视觉遗忘与安全政策推理，登记 DSTP、TVC、Look and Think、VFlowOpt、Policy-Guided Safety Tuning 和 GuardReasoner-VL，并将候选缺口明确为 label-first Guard 中“感知保留但政策绑定失败”的诊断与推理保持压缩。

## 2026-09-07

- [Added] [experiments/20260907-xguard-token-pruning-analysis] 归档 XGuard 41 类安全分类、归因生成、Ghosted Layers、FastV、DivPrune 与降分辨率实验原始记录并完成派生复核，将研究优先级收束为逐样本 harmful-flip 审计、平衡长尾确认和 resolution-first 证据恢复。

## 2026-09-04

- [Changed] [research/visual-token-pruning] 将本会话的 Token 剪枝研究整理为单一方案文档，删除目录内其余专题与论文笔记，并重定向相关索引和跨项目链接（[[LLM-Wiki/changes/2026-09-04-consolidate-visual-token-pruning-research.md|详情]]）。
- [Added] [research/visual-token-pruning] 调研可解释性与 Token 剪枝交叉，登记 X-Pruner、FRESH、ERASER、TokenTM、GAP、SemVID、IF-Prune、FPVG 与解释指标反证，并将候选主线收束为带 provenance 的多模态安全证据瓶颈、非对称证据契约和不确定性回退。
- [Added] [research/visual-token-pruning] 评估离线 profile、fixed-shape token reducer 与 profile-aware batch serving 三层贡献的已有工作、实现风险和投稿路径，登记 E-AdaPrune、OccamToken、Conformal LLM Routing、PLA-Serve、HELIOS，并将主线收束为 risk-calibrated execution contract。
- [Added] [research/visual-token-pruning] 调研离线激活/梯度校准的 Token 选择与融合，登记 Prune and Merge、DiffPrune，区分固定结构、离线预算与训练式在线 selector，并将安全 profile 细化为固定执行骨架、动态内容寻址、空间覆盖/关系槽及归因恢复的候选路线。
- [Changed] [research/visual-token-pruning] 核验低分辨率安全关键样本的研究必要性，补充分辨率反事实漏报定义、现有工作覆盖边界与压缩状态攻击威胁，并登记《Less Is More—Until It Breaks》预印本。

## 2026-09-03

- [Added] [research/visual-token-pruning] 调研输入图像下采样、动态分辨率、低清先行/高清回退与均匀空间池化，登记 VTC-Bench、VisionThink、Qwen2-VL、M3、DeCo 原始论文，形成多模态安全判别的分辨率优先方案、失败边界和实验矩阵。

## 2026-09-02

- [Added] [research/visual-token-pruning] 核对 FastV、SparseVLM 与 DivPrune 的选择器、attention-kernel 和物理压缩开销，形成端到端时延成本模型、复现 profiler 清单及短标签安全 Guard 的低开销混合剪枝建议。
- [Added] [research/visual-token-pruning] 精读 CVPR 2026 MetaCompress，登记原始论文并梳理学习式压缩矩阵、attention 启发式反证、训练目标、实验边界及其与安全语义剪枝的区别。

## 2026-08-31

- [Changed] [concepts/methods] 将 DeepStack 从仅描述多尺度高分辨率 token 的定义扩展为跨层视觉信息注入家族，并基于 Qwen3-VL 技术报告与公开实现补充多深度 ViT 特征侧路、消融证据及空间 × 深度联合剪枝启发。

- [Added] [concepts/methods] 精读 NeurIPS 2024 DeepStack 并凝练视觉 Token 深度注入概念，明确固定 LLM 上下文、跨层有效 token、真实视觉编码成本及其与剪枝的边界。
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
