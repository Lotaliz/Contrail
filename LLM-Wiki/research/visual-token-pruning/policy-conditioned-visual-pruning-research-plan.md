---
id: policy-conditioned-visual-pruning-research-plan
type: synthesis
title: "新版课题方案：短政策条件下的文本政策指导视觉 Token 剪枝"
tags: [research, multimodal-safety, vision-language-model, visual-token-pruning, efficient-inference, safety-evaluation]
project_id: visual-token-pruning
sources: [paper-bai-2025-qwen3-vl, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, dataset-policyshiftbench, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-zhang-2025-cdpruner]
status: active
created: 2026-09-23
updated: 2026-09-24
---

# 新版课题方案：短政策条件下的文本政策指导视觉 Token 剪枝

## 0. 当前决策与证据状态

**当前主线**是让运行时文本政策指导图像安全审核中的视觉 Token 剪枝。在已有长政策数据上，通过**基于原政策的模板改写**形成较短、可读的政策输入；短写是构造目标工作负载的背景条件，**不是拟投稿方法的贡献**。论文方法应在同一短政策、同一图像和同一 Guard 下，与现有视觉剪枝方法比较，证明政策条件确实改善视觉计算的质量—时延权衡。

本方案替代先前以“学习式政策软 Token 压缩＋视觉—政策联合预算”为主贡献的 2026-09-22 历史路线；其变更与清理记录见 [[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md|清理记录]]。原长政策、软前缀压缩和负面结果保留为背景证据与必要对照，不纳入首轮视觉 baseline 的待实现模块。

**证据状态：** [[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|公开研究]]支持使用同图异策评估政策适应；本次对话中用户提供的实验记录记载了当前 v1–v3 数据与长政策实验。用户最新报告：模板改写得到的约 32-token 可读短政策经训练后，初步分类/召回接近约 882-token 原政策；完整逐项指标、PER/PSS、FPR、政策覆盖范围和训练产物路径**尚未归档**。加入位置编码及额外损失的软 Token 压缩训练仍在进行；过程中的 loss 接近旧方案，不能当作最终质量结论。

## 1. 研究问题、适用场景与投稿边界

### 1.1 任务定义

输入为图像 $I$、当前生效的短文本政策 $P_s$ 和输出标签图例 $L$，模型预测 $y=f(I,P_s,L)$：Safe/pass，或一个被违反的风险类别。**同一张图在不同政策下可以有不同正确答案**；因此普通图像风险分类准确率不足以证明模型或剪枝器读取了政策。政策文本是审核规则，不是与图片共同构成违规语义的用户请求。

目前开发主干沿用 `Qwen/Qwen3-VL-2B-Instruct`（已记录 revision `89644892e4d85e24eaac8bacfd4f463576704203`），输出一个分类字母加 eos。已有设置最多约 980 个视觉 Token、最大序列 2,560 Token。标签图例作为可读文本保留，不计入短政策正文的改写长度。视觉剪枝可发生于视觉编码器前、编码器中或进入 LLM 前；不同位置的可节省成本必须分开报告。

### 1.2 论文拟回答的问题

> 在已能被 Guard 使用的短政策文本条件下，能否用政策语义选择或保留更有判定价值的视觉 Token，使同图异策、局部风险证据和安全质量尽量保持，同时取得实际端到端加速？

方法贡献候选是**政策条件视觉证据选择**，可能包括风险条款对应的区域保留、空间覆盖、样本级预算或失败回退；这些均为待验证设计，不预设已有实现有效。[[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]] 已做 query-guided 早期视觉剪枝，[[LLM-Wiki/research/visual-token-pruning/papers/2026-rubab-dyna-vit.md|Dyna-ViT]] 已做 encoder 前无参剪枝。因此“把文本当 query”或“在 ViT 前删 patch”本身不能作为新意。CVPR 叙事需要落在**政策变化下的视觉证据保留、风险约束及可重复的实际加速**。

### 1.3 短政策的作用与外推边界

短政策由原长政策模板改写，不新造审核标签。它只定义本论文当前工作负载；不宣称自动压缩任意法规文档，也不把人工/模板短写作为算法贡献。模板不能被测试图像或 gold 标签条件化。若部署前需要人工为每个新政策重写，论文必须把适用范围明确限定为可预先配置政策的 Guard；不能把离线人工工作说成免费、通用的在线压缩。

## 2. 目标数据集的来源与构造

### 2.1 原始来源与各自角色

| 来源 | 使用内容 | 在本课题中的角色 |
|---|---|---|
| `AIML-TUDA/LlavaGuard` | 9 个 O1–O9 风险类、Safe、原生同图政策变体；CSV 5,466 行中 5,086 行有可用图像 | 主体分类与政策翻转骨架；原生翻转组单独评测 |
| `AIML-TUDA/smid` | LlavaGuard 主要图像载体；所需 2,928 张已恢复 | 图像来源，不额外创造政策标签 |
| LlavaGuard 外部 URL | 所需 311 张中恢复 163 张 | 可用图像子集；缺失图像不补造 |
| `yiting/UnsafeBench` | 从六个原类目中仅取可可靠对应的样本：Hate、Harassment→O1；Violence→O2；Sexual→O3；Illegal activity→O5；Self-harm→O7；其余五类共 4,356 行排除 | 扩充普通安全/风险图片；由 crosswalk 得到的政策对与作者原生翻转对分层报告 |
| `PolicyShiftGuard/PolicyShiftBench` | `stage1_rp_sft_random`、`stage2_bp_adapt_boundary_pairs`、`eval_adaptive_id`、`eval_shift_ood` 及完整 policy bundle | 第二套独立政策体系；含同图边界对与未见政策评测 |

PolicyShiftBench 使用 7 个 section、53 个图像属性字段和约 13,500 种语义 policy bundle；其 taxonomy 与 LlavaGuard 不做类别 crosswalk。前者的 01/02 等 section 与 O1–O9 多对多重叠，并包含 IP、隐私、图中文字等额外规则。把两套类别强行合并会引入系统性错标。

### 2.2 已完成的长政策工作集版本

以下是**已有数据处理的实际记录**，不是本轮重新生成的数据。全部数字来自上述用户提供的 v1–v3 实验文件。

| 版本 | 构造操作 | train / test | 政策变化评测 |
|---|---|---:|---|
| v1 | 从 LlavaGuard 政策列逐字提取 129 种 taxonomy；默认约 882 Token、变体约 963–964 Token；保留作者同图异策组；合并可映射 UnsafeBench，去重并清除跨划分图像交集 | 8,901 / 1,809 | test 61 组翻转对；train 政策依赖行 425（4.77%） |
| v2 | 在 v1 上加入 `default`、`flip_target`、`flip_irrelevant`、`synonym_target` 四种政策视图；每张可扩充训练图无放回抽 2 种，test 保留 4 种；使用 72 段人工批准的同义改写；50% train 行重排政策类目块 | 10,378 / 2,967 | test 447 组翻转对；train 政策依赖行 1,160（11.18%）；政策文本 5,396 种 |
| v3 | 在 v2 基础上加入 PolicyShiftBench 作为第二套独立体系；保留其完整 bundle；训练时 49.25% 的行在**各自体系内**随机置换风险字母，A 固定为 Safe；dev/test 用规范图例 | 16,614 / 4,648 | LlavaGuard 447 组翻转对；两体系各自分层评测；train 政策依赖行 6,566（39.52%） |

v2 的 `flip_target` 将当前图像违反的目标类目改为允许，gold 变为 A；`flip_irrelevant` 放宽无关类目，gold 不变；`synonym_target` 只改表述，gold 不变。v3 标签扩展为 A–Q：A=Safe/pass，B–J 属 LlavaGuard O1–O9，K–Q 属 PolicyShiftBench 01–07。两体系分量为 LlavaGuard 10,378 train / 2,967 test，PolicyShiftBench 6,236 train / 1,681 test；不要把 17 类整体 macro 指标当作唯一主结果。

### 2.3 去重、歧义与切分边界

已有流程使用解码像素 SHA-256、dHash64 和可用的规范化文件名排查 train/test 交集。v3 合并前剔除 PolicyShiftBench 与 v2 训练集交叉的 219 张像素完全相同图像及 350 张仅 dHash 命中的图像；PolicyShiftBench test 从 2,000 行降为 1,681 行。PSG stage1 中 109 行同时违反多个类别，单字母 gold 不唯一，已删除。

新实验**沿用这些清理后的图像、样本 ID、标签和原有划分**；同一基础图像的政策变体可在同一个评测划分内构成反事实对，但不能跨 train/test 泄漏。对 PolicyShiftBench 的 `eval_adaptive_id` 与 `eval_shift_ood` 分别报告；对 LlavaGuard 作者原生翻转对与 UnsafeBench crosswalk 派生对分别报告。若后续 selector 使用同图边界对训练，还需以基础图像和 boundary group 复查划分。

### 2.4 新的短政策视图：已知与待归档

用户确认短政策**按模板从长政策改写**。建议将每条派生记录显式保存为 `(source_row_id, image_id, policy_family, long_policy_id, short_template_version, P_long, P_short, gold, split, pair_or_boundary_group)`，完整长政策原文保持不可变。短写应覆盖对应政策的禁止/允许状态及会影响 verdict 的例外；同一语义政策的默认、翻转、无关翻转与同义改写需以一致模板处理。模板规则须在查看 test 结果前定稿，对 test/OOD 政策只执行既定规则，不能按 gold 或错误样例逐条返工。标签只在短写与原政策语义相同的条件下继承；模板等价性需由规则字段核对和同图政策翻转测试共同验证。

**尚未由现有记录确认：** 模板文本、生成脚本与版本；不同体系和变体的实际转换成功行数；长度分布及“约 32 Token”是否覆盖所有样本；PolicyShiftBench 的复杂 bundle、否定与例外是否都能在短写中保留；最新短政策 checkpoint 的路径和逐层质量指标。上述缺口不能用 v3 的 16,614/4,648 行直接充当“已完成短政策数据规模”。首轮 baseline 前先固定并归档短政策 manifest、模板和训练配置。

## 3. 现有实验给予的起点

| 已观察事项 | 具体证据 | 对新课题的含义 |
|---|---|---|
| 完整政策 Guard 在 LlavaGuard 上能响应政策变化 | v3 P1：2,967 行 accuracy 0.8851，447 对 PER 0.9172；PolicyShiftBench 1,681 行 accuracy 0.6930 | 长政策模型是参考，不应概括为两体系同等成熟 |
| 学习式 32-token 软前缀在现有实现中未保持政策语义 | v3 LlavaGuard P2 PER 0.0515；PSG FPR 0.8377；虽有 1.467× E2E p50 加速 | 不作为本视觉课题的必要前置工作；失败不能证明短可读政策不可行 |
| 短可读政策可被训练使用 | 用户最新报告分类/召回接近原长政策 | **初步观察**；缺 PER/PSS、FPR、分体系与未见政策完整结果，不能写成已验证的语义等价 |
| 旧长政策工作负载下纯视觉剪枝收益有限 | 用户此前报告 90% pre-ViT 剪枝约 1.14× 且精度明显下降 | 属于旧长政策条件的场景约束；换短政策后必须重新 profile，不能沿用 1.14× 作为新上限 |

## 4. 第一阶段：在同一场景上跑现有视觉剪枝 baseline

### 4.1 固定协议

使用**同一个完成训练并冻结的短政策 Qwen3-VL-2B Guard checkpoint**，同一 test manifest、图像预处理、短政策文本、标签图例、硬件与推理后端。首轮先做无需额外训练的方法；需要训练 adapter 的方法另列，且训练数据和预算对齐。质量—预算曲线优先按**进入 LLM 的视觉 Token 实际保留率** `1.00、0.75、0.50、0.25` 对齐；同时记录早剪方法各视觉层的真实保留率，因为同一 LLM 输入长度不代表同一 ViT 成本。方法不支持某一预算时如实标缺，不插值。

| 顺序 | 条件 | 目的与注意事项 |
|---|---|---|
| B0 | 短政策＋完整视觉；另保留长政策＋完整视觉作历史参考 | 新工作负载的质量与时延基准；两种政策及其不同训练 checkpoint 不可混作视觉剪枝的同模型收益 |
| B1 | 随机 2×2 group、均匀空间覆盖与输入分辨率下采样 | 排除“任何删 Token 都一样”及简单低分辨率替代；固定随机种子，Qwen3-VL 的视觉合并/位置接口需保持合法 |
| B2 | Dyna-ViT 式无参 encoder 前显著性剪枝 | 纯视觉早剪对照；旧长政策负面结果需在短政策条件下重测 |
| B3 | FastV 式 LLM 浅层 attention 剪枝，或已在本代码栈可运行的 late-pruning 基线 | 测试只缩短后续 LLM 序列的上限；它不减少此前 ViT 成本，计时拆分不可省略 |
| B4 | CDPruner 式 policy-text relevance＋视觉多样性选择 | 不训练的文本条件 late-pruning 对照；政策文本编码、相似度/核构建与 gather 成本均计入 |
| B5 | QuietPrune 式文本 query 引导的 ViT 内 2×2 group 早剪 | 最近邻强对照；其 adapter 需训练，Qwen3-VL-4B 的公开结果不等于本 2B 场景可直接复现 |

以上是**优先测试队列**，不是宣称所有方法已移植或具有同一执行位置。先完成 B0–B3 与可运行的 B4，再决定是否投入 B5 的 adapter 适配。每种 hook 先过 `retain=1.00` 身份门禁：输出 token、logits、位置编码和视觉特征流与未剪路径一致，尤其检查 Qwen3-VL 的视觉合并及 DeepStack 对齐；未过门禁的速度/质量数字不进入主比较。

### 4.2 主要指标与分层

- **政策判定：** 分体系 accuracy、macro recall、unsafe recall、benign FPR；在预先固定的 benign FPR 下比较 unsafe recall；类别与政策最差组；压缩相对 B0 新增的 unsafe→safe 错误。
- **政策适应：** LlavaGuard 同图异策 PER，并分作者原生对与派生对；PolicyShiftBench 使用其同图 pass/block 指标或 PSS，不能用“政策依赖行 accuracy”代替。对 `eval_shift_ood` 单独给结果。
- **视觉困难组：** 仅在原始属性/可核实标注支持时评估 OCR、图中文字、小目标、多区域关系；未有可靠分组时标 TODO，不由模型预测反推 gold 子群。
- **效率：** 分别测预处理、视觉编码、selector/score/compact、LLM prefill、单标签 decode、完整 time-to-verdict；报告 P50/P95、视觉 Token 数、峰值显存，并注明 batch、硬件、warmup、重复次数。短政策模板若离线生成，离线成本单列；若在线执行，则计入端到端。
- **政策条件是否有用：** 对同一图片换政策、打乱政策或只给类目名/固定模板作控制。不能要求每一次政策翻转都改变保留 patch：同一视觉事实也可能在两种规则下得出相反 verdict；应以最终判定、证据保留与总体反事实差异判断。

### 4.3 实验记录与决策门槛

此阶段是探索性 baseline 扫描，尚未预注册数值非劣界。正式方法实验前，基于 B0 波动、样本量和安全代价**预先确定** fixed-FPR recall、PER/PSS 与关键类目的可接受退化范围，不能在测试后挑选阈值。所有条件保留失败、OOM、无效输出和计时异常；报告单 seed/单硬件的局限，必要时在候选工作点重复运行。

首轮决定下一步的三个问题：

1. 短政策相对长政策是否保持同图翻转、FPR 和未见政策表现，而非只有平均召回接近？
2. 缩短政策后，视觉编码与后续视觉前缀各占多少实际时间；早剪是否在计入 selector 后产生净加速？
3. 在相同预算和相同训练许可下，现有 policy-blind、普通 query-guided 与 policy-text-guided baseline 的质量—时延前沿差多少？若已有方法覆盖前沿，新方法不得只换政策词而声称创新。

## 5. 第二阶段方法假设与可证伪设计

仅在 baseline 暴露可重复缺口后设计新 selector。候选方向是让短政策中的风险条款与图像 patch/group 匹配，在保留局部高风险证据时兼顾空间覆盖，并按不确定性分配视觉预算；选择发生在能同时带来加速和可辨别语义的位置。训练可先冻结 Guard，仅训练轻量 selector；若需要 LoRA，则必须与同训练数据的 full-vision LoRA 对照，隔离新增数据和剪枝训练收益。

**可证伪预期：** 相同保留率下，政策条件方法应优于无政策/错政策、随机、均匀覆盖和最近邻 query-guided 方法；受益应体现在政策翻转或风险困难组，而非只在平均 accuracy 上；包含 scorer、gather 与回退后仍需有可重复净时延收益。若简单分辨率下采样或现有 QuietPrune/CDPruner 达到相同前沿，应缩小方法主张或停止该设计。

## 6. 主要有效性威胁与待人工确认

1. **短写语义：** 模板可能漏掉原政策否定、例外、优先级；PolicyShiftBench 的复杂 bundle 不一定能稳定写入约 32 Token。需保存模板/映射并人工抽检边界对，实际长度和转换覆盖率待归档。
2. **数据捷径：** LlavaGuard/UnsafeBench 的风险类别标签和 v2 派生翻转可能比作者原生及 PSG Shift 容易；必须分层，不以整体平均掩盖。
3. **剪枝实现：** 早剪若破坏 2×2 merge、M-RoPE 或 DeepStack，则测到的是接口错误，不是方法退化；须先通过身份门禁。
4. **时延外推：** 旧 882-token 场景的 1.14× 和软压缩 1.47× 不能叠加，也不能替代新短政策条件的同机测量。
5. **论文定位：** 短政策模板不是贡献；仅把短政策塞进通用 query-guided 剪枝也不是贡献。真正的新结果须来自政策变化下可解释的视觉计算决策和安全质量—时延收益。

## 7. 关联与依据

- 当前数据与 P1/P2 原始汇总来自本次对话中用户提供的实验记录；原始结果尚未纳入当前 Wiki，本页只摘录任务所需信息。
- [[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|政策自适应图像 Guard 的任务边界]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-song-policyshiftguard.md|PolicyShiftGuard 同图政策翻转]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-piao-safeguard-vl.md|SafeEditBench / SafeGuard-VL]]。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-rubab-dyna-vit.md|Dyna-ViT]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]]；[[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]]；[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|视觉剪枝与效率基线口径]]。
