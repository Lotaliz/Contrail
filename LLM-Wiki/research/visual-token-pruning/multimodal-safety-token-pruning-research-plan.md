---
id: multimodal-safety-token-pruning-research-plan
type: synthesis
tags: [research, method, visual-token-pruning, vision-language-model, multimodal-pretraining, model-compression, token-merging, structured-pruning, budget-optimization, dynamic-inference, dynamic-sparsity, early-exit, model-routing, training-free, test-time-adaptation, hardware-aware-optimization, efficient-inference, model-serving, continuous-batching, slo-aware-serving, efficiency-evaluation, multimodal-safety, knowledge-distillation, hard-example-mining]
title: "多模态安全判别 Token 剪枝研究方案：训练参与、证据可见性与低时延"
project_id: visual-token-pruning
sources: [paper-zhong-2025-blockpruner, paper-ma-2023-llm-pruner, paper-an-2024-flap, paper-muralidharan-2024-minitron, paper-lin-2024-mope-clip, paper-shen-2025-numerical-pruning, paper-michel-2019-sixteen-heads, paper-voita-2019-specialized-heads, paper-geva-2021-ffn-memory, paper-dai-2022-knowledge-neurons, paper-wang-2026-gisp, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-zhang-2025-sparsevlm, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-chen-2025-safewatch, paper-meng-2024-deepstack, paper-bai-2025-qwen3-vl, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-wang-2026-metacompress, paper-liao-2026-vtc-bench, paper-yang-2025-visionthink, paper-wang-2024-qwen2-vl, paper-cai-2024-matryoshka-mm, paper-yao-2024-deco, paper-zhang-2026-security-pitfalls-token-compression, paper-mao-2025-prune-and-merge, paper-he-2026-diffprune, paper-he-2026-e-adaprune, paper-li-2026-occamtoken, paper-uddin-2026-conformal-routing, paper-she-2026-pla-serve, paper-kumar-2026-helios, paper-wang-2024-smarttrim, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding, paper-cai-2020-once-for-all, paper-devvrit-2024-matformer, paper-raposo-2024-mixture-of-depths, paper-yu-2023-x-pruner, paper-jain-2020-fresh, paper-deyoung-2020-eraser, paper-hsia-2024-goodhart-explanations, paper-wu-2024-token-transformation, paper-chien-2025-gap, paper-li-2026-semvid, paper-sun-2026-if-prune, paper-reich-2023-fpvg, paper-kim-2026-dstp, paper-sun-2025-tvc, paper-cai-2026-look-think, paper-yang-2025-vflowopt, paper-zhang-2026-policy-guided-safety-tuning, paper-liu-2025-guardreasoner-vl, paper-wen-2025-dart, paper-liu-2026-crisprune, paper-fan-2026-visual-token-semantics, paper-wang-2026-information-horizon, paper-zhuang-2025-vasparse, paper-zhang-2025-vispruner, paper-turpin-2023-unfaithful-cot, paper-wiegreffe-2021-label-rationale-association, paper-jiang-2024-rora, paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-gu-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap]
status: active
created: 2026-09-04
updated: 2026-09-08
---

# 多模态安全判别 Token 剪枝研究方案

## 0. 文档定位

**2026-09-08 主线更新：** 从推理选择器优先转为模型训练优先，并进一步收束为 §21 的“政策因果安全充分视觉前缀”。§1、§20–21 为当前决策；§12 的 evidence-carrying 设计保留为候选组件与历史推导，不再称为最终方法。来源、背景、比较、空白及正式动机见 [[LLM-Wiki/research/visual-token-pruning/overview.md]]、[[LLM-Wiki/research/visual-token-pruning/landscape.md]]、[[LLM-Wiki/research/visual-token-pruning/comparison.md]]、[[LLM-Wiki/research/visual-token-pruning/gaps.md]]、[[LLM-Wiki/research/visual-token-pruning/motivation.md]]。本轮未运行新实验。

本文整合本轮会话中有关以下问题的全部研究判断：

- BlockPruner 的 PPL 指标如何替换为安全任务对齐的重要性；
- MHA、MLP 与细粒度结构剪枝的能力影响；
- TRIPS、PuMer、FastV、SparseVLM、VisionZip、DivPrune、SafeWatch 等多模态 Token 剪枝方法的适用场景；
- selector 开销、端到端时延与直接降低输入分辨率；
- DeepStack/Qwen3-VL 对跨深度 Token 价值的启发；
- 离线激活/梯度校准、条件 profile、固定 shape 动态寻址与批服务；
- 低分辨率容易失败的安全样本；
- Token 剪枝与模型可解释性、因果 rationale 和安全审计的结合。

本文是一份研究方案与决策依据，不把尚未复现的论文结果写成本地实验结论。来源事实、跨论文综合判断和待验证假设分别标注。

## 1. 最终结论

不建议把论文主线设为以下任一单点：

1. 用安全 accuracy 替换 PPL 做剪枝；
2. 用 activation、gradient 或 attention 设计一个新的 Top-K score；
3. 对输入直接降分辨率；
4. 离线生成若干固定 token masks；
5. 用 profile router 选择 token 数并按 profile 组批；
6. 给剪枝结果附加一张 attention heatmap。

这些单点要么已有直接先例，要么容易被简单 baseline、选择器开销、空间位置变化或安全漏报击穿。

当前推荐将核心问题收束为：

> **不设计新 backbone，以完整视觉塔作训练期教师，把图文—政策安全判别所需的因果证据前移到可部署的浅层视觉前缀；在分辨率×patch×深度压缩格上优化会造成漏报的尾部状态，在固定误报率下推进困难召回—判定时延前沿。**

这是候选问题，不是已验证贡献。EfficientVLM 已覆盖 VLM 蒸馏与视觉层缩减，METR 已覆盖多出口 early pressure，Dyna-ViT/QuietPrune 已覆盖 pre-encoder/ViT 内早剪，EPIC/TBD/ViCO 已覆盖压缩参与训练。因此三项策略简单相加不够。当前最高优先级是 G0 的安全充分视觉前缀与 G0-A 的最坏压缩状态训练；G1 学生证据可观察性作为关键门控；G0-B 双尺度输入和 G4 Guard 压缩安全分别作为视觉与安全分支。新 backbone、大型在线 router 和 serving 放到机制成立之后。

## 2. 目标场景

### 2.1 用户输入

- 单图或短/长视频；可能包含小目标、角落危险物体、OCR、手势、裸露、暴力或跨帧短暂事件；
- 用户文本可能很短，也可能包含上下文、否定、引用、隐喻、规避提示或长文本攻击；
- 系统还包含一组固定或可更新的安全政策条款。

### 2.2 任务输出

核心输出是 `safe/unsafe`、风险类别和置信度，可选输出证据区域、文本 span 和短 rationale。首先优化 time-to-verdict；解释生成可以在 verdict 后执行，不能把长解释 decode 混入关键路径加速结论。

### 2.3 质量约束

平均 accuracy 不是主要约束。至少使用：

- 固定 FPR 下的 unsafe recall；
- macro 与 worst-policy recall；
- false-negative severity；
- AUPRC、ECE 与风险校准；
- OOD、分辨率反事实和压缩路径特有攻击。

### 2.4 系统约束

Guard 位于服务关键路径，输出短，缺少长 decode 来摊销 selector。必须把视觉编码、selector、gather/merge、LLM prefill、verdict decode、rationale decode 分项计时，并报告 P50/P95/P99 和 batch goodput。

## 3. 核心论点—证据—边界

| 核心论点 | 主要证据 | 可支持结论 | 不能过度声称 |
|---|---|---|---|
| PPL 与安全判别不对齐 | BlockPruner 使用 PPL；GISP/MoPE-CLIP 等使用任务或跨模态损失 | 应保留迭代真实消融框架，替换为安全连续损失和风险指标 | accuracy drop 或 gradient 自动成为最优指标 |
| attention selector 不一定可靠 | FastV/SparseVLM；统一复核中的 random/pooling 反例；TokenTM | attention 只是候选信号，需要覆盖、变换或真实消融校正 | attention heatmap 等于因果解释 |
| selector 会抵消加速 | FastV/SparseVLM/DivPrune 的计算位置和公开时延拆分 | 必须报告 selector 与 compact 开销和端到端收益 | FLOPs、prefill 加速可直接外推 E2E |
| 降分辨率是强 baseline | VTC-Bench、VisionThink、Qwen2-VL、M3、DeCo | 应把 resolution-first 放在所有复杂 selector 前比较 | 低分辨率对安全长尾同样可靠 |
| 空间与关系证据易被破坏 | GAP、SemVID、RefCOCO/视频 grounding | 需保留 position IDs、邻域、跨帧连接和 provenance | 只保留孤立高分 Token 足够 |
| 多深度视觉信息不等价 | DeepStack、Qwen3-VL 多层视觉注入 | Token 价值具有空间 × 深度双维性 | 浅层低分 Token 在后续一定无用 |
| 离线校准已有先例 | Prune and Merge、DiffRate、VisPCO、SmartTrim、DiffPrune | 可离线学 score/profile，但在线动态寻址仍常有必要 | “离线梯度剪枝”本身新颖 |
| profile/子网 serving 已有先例 | OFA、MatFormer、SuperServe、PuDDing、Deja Vu、MoD、PLA-Serve | 运行时通常选择预定义执行路径而非现场重构权重 | “按任务加载子网”可概括所有框架 |
| 可解释剪枝已有交叉 | X-Pruner、FRESH、IF-Prune、SafeWatch、SemVID | 新意需落在因果 evidence bottleneck 与安全契约 | 首次 explanation-guided pruning |

## 4. 已有 Token 剪枝方法对本课题的含义

### 4.1 TRIPS

TRIPS 在视觉—语言预训练中根据文本逐步选择相关图像 patch，目标同时包含训练与推理效率；它改变了 ViT block 内的执行流程但不重新定义基本 attention/MLP 算子。论文说明越早删除 patch，越可能同时减少后续视觉编码和跨模态计算；代价是需要在视觉塔中加入文本条件选择，不能直接当作完全无开销的后处理。

### 4.2 PuMer

PuMer 在 cross-modal layers 中用文本指导视觉 pruning，并分别合并视觉和文本 Token。它是“视觉与文本联合减少”最直接的早期先例，但其选择和相似度计算仍发生在前向路径中，不是离线固定策略。

### 4.3 FastV

FastV 利用浅层 LLM 的图文 attention 给视觉 Token 排序，在中间层开始删除。优点是 training-free、实现直观；局限是必须先执行视觉塔和若干 LLM 层才能得到分数，前段成本无法节省，attention 读取、排序和不规则 gather 也可能抵消后段 prefill 收益。

### 4.4 SparseVLM

SparseVLM 使用文本 Token 作为 raters，自适应确定保留比例并回收被删视觉信息。其 benchmark 并非都只有极少文本 Token：存在短问答，也覆盖 OCR、文档和较复杂指令。方法依赖 decoder attention 或相应兼容实现，因此短文本并不意味着选择成本必然低，更不能代表安全 Guard 的短标签场景。

### 4.5 VisionZip 与 DivPrune

VisionZip 在进入 LLM 前选择 dominant visual tokens 并聚合上下文，适合 multi-turn 复用；DivPrune 不依赖文本 attention，而用 embedding diversity 保证覆盖。DivPrune 避免额外神经网络前向，但仍需要两两距离和迭代选择，所以“不依赖 attention”不等于“零 selector 成本”。其价值在于揭示 coverage/diversity 是 attention relevance 的必要竞争基线。

### 4.6 SafeWatch

SafeWatch 是安全场景最直接的先例：对视频执行 policy-aware visual token pruning，并生成多标签 verdict 与内容解释。它证明政策条件化选择可行，但没有证明保留 Token 是 verdict 的因果 rationale，质量仍以平均 Guard 指标和生成解释评价为主。

### 4.7 训练参与已有直接先例

新背景按训练对象组织：同结构模型适配（EPIC/TBD）、多预算一致性（ViCO、已有 M3）、任务统计与记忆压缩（ETC/VisCo）、训练吞吐与路径失配（DualSpeed）、训练期证据依赖（Evidence-RL/Att-CoT）。详见 [[LLM-Wiki/research/visual-token-pruning/landscape.md]] 和 [[LLM-Wiki/research/visual-token-pruning/comparison.md]]。input resize、高清编码后少 token、压缩前语义凝聚是不同计算路径，必须分开计时。

## 5. 为什么选择器开销必须成为方法的一部分

总时延应写成：

$$
T_{\mathrm{e2e}}=T_{\mathrm{preprocess}}+T_{\mathrm{vision}}+T_{\mathrm{selector}}+T_{\mathrm{compact}}+T_{\mathrm{prefill}}+T_{\mathrm{verdict}}+T_{\mathrm{rationale}}.
$$

FastV 或 SparseVLM 可能显著减少被剪层之后的 FLOPs，却不减少视觉编码器和剪枝层之前的执行；若 attention materialization、top-k、数据搬运与 shape fragmentation 较重，端到端改善可以接近零。论文通常承认或通过分项结果暴露 prefill 与 E2E 不同步，但很少把 selector 负收益作为主要研究问题。

因此新方法必须满足至少一项：

- 在视觉塔前通过分辨率/patchification 减少工作；
- 复用已经必需的早层激活，不额外运行完整小 VLM；
- 把昂贵 attribution 和梯度全部放在离线阶段；
- 使用固定窗口、规则 top-k、固定 fan-in merge 和 batched gather；
- 证明 selector 净收益，而不是只报告下游 FLOPs。

## 6. 分辨率优先策略

### 6.1 为什么是强基线

直接降低输入分辨率在 patchification 前就减少 Token，可同时降低视觉编码和 LLM prefill，在线几乎没有重要性估计开销；若图像尺寸可以预处理或离线生成多个版本，压缩开销还可移出关键路径。

VTC-Bench 表明，在支持动态分辨率的模型上，直接下采样可在普通 benchmark 中胜过多种复杂 Token selector；但在“低清错、高清对”的细节敏感子集上趋势反转。VisionThink 进一步支持低清先行、必要时请求高清，但 OCR/图表等高升级率任务可能因双跑变慢。

### 6.2 安全场景的候选空白

值得聚焦的不是“降分辨率通常很好”，而是：

> 哪些安全样本在低分辨率下由 unsafe 翻转为 safe，能否用低成本证据覆盖与不确定性信号在漏报发生前识别它们？

关键子群包括小目标、角落符号、细小武器、OCR、模糊裸露、手势、局部遮挡、跨帧短事件，以及图像和文本组合后才成立的危险语义。

### 6.3 推荐执行方式

低分辨率不是最终方法，而是第一级 profile：

1. 低清全局 coverage；
2. evidence/uncertainty 检查；
3. 对可疑区域做高清 ROI 或整图恢复；
4. 若仍不稳定，回退 full Guard。

必须比较低清单跑、低清+整图高清双跑、低清+ROI、post-ViT pooling 和动态 Token selector 的实际 P95。

## 7. DeepStack 对 Token 剪枝的启发

Qwen3-VL 式 DeepStack 不是简单使用不同分辨率，而是从视觉编码器浅、中、深层抽取特征，逐步注入 LLM 早期层。其内涵是：

- 浅层提供边缘、纹理、局部文字等细节；
- 中层提供部件和局部组合；
- 深层提供更抽象的对象与语义；
- LLM 不必只依赖视觉编码器最后一层的单一语义截面。

对剪枝的核心启发是 Token 重要性应建模为 **空间位置 × 表征深度 × 政策查询**，而不是只在某一层对 patch 排一次 Top-K。安全小字可能在浅层最明显，危险对象在深层才可分，图文关系则可能在 projector/LLM 早层才出现。

可研究的多深度方案包括：

- coverage Token 从浅层获得并保持空间结构；
- evidence Token 在中/深层由政策条件选择；
- 对不同风险类别学习不同 depth allocation；
- 若某 patch 被深层删除，仍保留低成本浅层摘要或 provenance；
- 比较只剪最终视觉 Token 与同时改变多层注入预算的差异。

## 8. 离线校准与 Profile 设计

### 8.1 三类“离线”必须区分

| 类型 | 离线获得 | 在线仍需执行 | 代表方向 |
|---|---|---|---|
| 固定结构 | 固定 mask、merge/reconstruct matrix | gather 或固定稀疏矩阵 | Prune and Merge |
| 固定预算/层配置 | 每层保留率、剪枝位置、Pareto profile | 当前样本的 Token 排序 | DiffRate、VisPCO |
| 学习式选择器 | activation→score 函数 | 每个输入运行 scorer/top-k | SmartTrim、DiffPrune |

真正固定绝对 patch 位置无法处理危险对象平移；固定文本第 $i$ 个 Token 更缺乏稳定语义。可行折中是固定执行骨架、动态内容寻址。

### 8.2 Profile 中固定与可变的内容

| 固定 | 随样本变化 |
|---|---|
| 输入分辨率桶、候选数 $N$ | 当前图像/视频内容 |
| 保留总数 $K$、剪枝层与输出 shape | 实际被 gather 的 indices |
| 空间窗口及最低 coverage quota | 哪些窗口得到额外 evidence quota |
| evidence/relation slot 数、邻域大小 | seed 位置和关系伙伴 |
| scorer 结构与离线参数 | 早层 activation、query/policy score |
| fallback 阈值和执行签名 | 是否升级分辨率/预算/模型 |

推荐固定长度分解：

$$
K=K_c+K_e+K_r,
$$

其中 $K_c$ 是 coverage slots，$K_e$ 是 evidence slots，$K_r$ 是 relation/context slots。同一 profile 返回恰好 $K$ 个 Token，便于 CUDA Graph、dense batching 和稳定时延；indices 可不同，不影响矩阵 shape。

### 8.3 Router 不应使用未知真值

真实风险类别和难度在完整判别前未知，不能把 ground-truth category 当在线 router 输入。合法信号包括：

- 用户明确指定的 policy；
- 输入尺寸、视频长度、OCR 密度和文本长度；
- 早层 attribution agreement；
- 低清/高清局部表示分歧；
- evidence coverage 与 calibrated uncertainty；
- OOD/攻击检测。

## 9. Token 重要性指标

### 9.1 不建议只使用离散 accuracy drop

小型校准集的 accuracy 是离散量，大量候选删除后分数可能不变，排序噪声很大。更适合定义连续安全目标，例如 unsafe margin、policy-conditioned cross-entropy、fixed-FPR surrogate 或教师—学生 logit divergence。

### 9.2 推荐三级筛选

第一层是廉价前向代理，用于排除明显冗余候选：

- activation norm；
- activation variance/FLAP 类可恢复性；
- weight magnitude、activation × weight；
- coverage/diversity 与空间约束。

第二层使用任务对齐的一阶/二阶信号：

$$
s_i^{\mathrm{Taylor}}(x)=\left|z_i\frac{\partial \mathcal{L}_{\mathrm{safety}}(x)}{\partial z_i}\right|,
\qquad
s_i^{\mathrm{Fisher}}=\mathbb{E}_{x}\left[\left(\frac{\partial \mathcal{L}_{\mathrm{safety}}(x)}{\partial z_i}\right)^2\right],
$$

其中 $z_i$ 是 Token、head、channel 或 block gate。按政策、风险类别、模态结构和 margin 分层汇总，使用 worst-group、上分位数或 CVaR，避免多数 safe 样本淹没长尾风险。

第三层对少量候选做真实 mask/remove/merge 前向消融，并在每轮剪枝后重估。应保留 BlockPruner 的“真实删除 + 迭代重排”，只是把 PPL 换成安全目标。

### 9.3 图文交互项

视觉或文本单独都可能安全，组合后才违规。若删除视觉组 $v$ 与文本组 $t$ 的联合损失明显大于两个单独损失之和，应把二者作为 relation group 联合保留。自然语言 Token 不宜使用跨数据平均绝对位置 mask，应按 span、实体、否定词、policy anchor 或关系组选择。

## 10. MHA、MLP 与模型结构剪枝

### 10.1 功能区别

- MHA 主要承担 Token/模态之间的信息路由、聚合和关系建模；少数 head 可能高度专门化。
- MLP/FFN 主要承担逐 Token 非线性变换、容量扩展，并承载部分模式和知识表征。

二者都存在冗余，但不存在跨模型、跨任务和跨剪枝粒度都成立的“应先剪谁”。BlockPruner 在 Llama2 的低于约 17% 参数剪枝区间观察到 MHA blocks 更冗余；继续 MHA-only 剪枝后性能陡降。这只能说明存在“先有冗余、后遇关键瓶颈”，不能外推为统一规则。

### 10.2 安全 Guard 的建议

1. 搜索空间同时包含 MHA block、MLP block、attention head 和 FFN channel；分别归一化后按安全损失/实测时延做全局预算。
2. 默认从 FFN channel 和低重要 head 的细粒度、规则宽度剪枝开始，不先删除完整 MLP block。
3. 跨模态 attention、OCR/关系专门 head 和 projector 周围模块应保守处理。
4. 分别在相同参数量、相同 FLOPs 和相同 P95 latency 下比较 MHA-only、MLP-only 与 mixed pruning。
5. 模型结构剪枝应在 Token 方案稳定以后作为第二阶段；否则两个自适应维度会让失败原因不可辨认。

## 11. 自适应模型规模的正确理解

现有框架通常不会在每个请求中重新计算结构重要性、永久删除参数并重写模型，但也不都通过“加载一个适当子网”实现：

- Once-for-All 可在部署前抽取固定子网；
- MatFormer/SuperServe 可让权重共享超网常驻并按请求激活切片；
- PuDDing 在内存受限环境按 prompt 加载预定义 blocks；
- Deja Vu、Mixture-of-Depths、PowerInfer 在前向中动态跳过 head、MLP、neuron 或 token-block；
- SafeRoute 在独立小/大 Guard 之间路由。

对数据中心多模态 Guard，推荐完整或嵌套权重常驻 GPU，预编译少量 `(token profile, backbone profile)`；在线只路由、切片或跳过，不从 CPU/SSD 临时装配任意子网。只有边缘内存确实放不下完整 Guard 时，模块加载才值得考虑。

## 12. 保留候选：Evidence-Carrying Token Compression

本节是此前的证据选择与解释路线，不再作为预定最终架构，训练主线见 §20。ET-Prune 与 Evidence-RL 等新增反证降低了“证据预算/因果训练”本身的新颖性；无需先实现 provenance selector 才能开展训练验证。

### 12.1 总体流程

```text
image/video + user text + policy
          │
          ▼
low-cost resolution / evidence probe
          │
          ▼
fixed-shape profile selection
          │
          ▼
coverage + evidence + relation token selector
          │   carries coordinates / spans / support sets
          ▼
multimodal evidence bottleneck
          │
          ▼
Guard verdict/category/confidence
          │
          ├── sufficient & stable → return verdict, optional rationale
          └── insufficient/unstable/OOD → restore tokens/resolution/full Guard
```

### 12.2 Faithful-by-construction 条件

借鉴 FRESH，后续判别器应只能访问所选证据，不能同时偷偷访问完整特征。若选择发生在多层 self/cross-attention 之后，保留 Token 已混入被删区域信息；此时必须：

- 把选择提前到主要 Token mixing 前；或
- 传播每个 Token 的 source support set 和混合权重；或
- 明确把输出称为 post-hoc attribution，而不是因果 rationale。

对 merge Token，必须保存原 patch indices、二维/时序位置、文本 span、support range 和 merge weights。GAP 已说明 position IDs 的次序和值错误足以使 grounding 质量崩溃。

### 12.3 非对称安全证据契约

以下是待验证假设：许多 unsafe 判定是存在性命题，一个局部或关系证据可足以触发；safe 判定是近似全称命题，需要证明未遗漏全局风险。因此定义三类 profile：

| Profile | 证据状态 | 主要 Token 分配 | 行为 |
|---|---|---|---|
| Unsafe-evidence | 高置信局部/关系违规证据 | 较多 evidence/relation，较少但非零 coverage | 快速 unsafe verdict |
| Safe-coverage | 暂无违规证据、输入分布内 | 较多 coverage、OCR/小目标和政策扫描 | 防止假安全 |
| Uncertain/full | attribution 不稳、OOD、攻击或高风险政策 | 高分辨率/高 Token/full path | 保守回退 |

该假设可能在讽刺、组合危害、上下文豁免和长视频因果链中失败，必须逐政策验证。

### 12.4 训练目标草图

设 selector 产生 mask $m$，完整 Guard 为 $f(x)$，压缩 Guard 为 $f(x\odot m)$：

$$
\mathcal{L}=\mathcal{L}_{\mathrm{safety}}
+\lambda_d D\!\left(f(x),f(x\odot m)\right)
+\lambda_b |m|
+\lambda_c\mathcal{L}_{\mathrm{coverage}}
+\lambda_r\mathcal{L}_{\mathrm{relation}}
+\lambda_s\mathcal{L}_{\mathrm{stability}}.
$$

- $D$ 约束 verdict/category logits 和风险排序；
- coverage 保护空间、时序和政策覆盖；
- relation 保护图文桥接和上下文；
- stability 约束分辨率、平移、轻微裁剪和政策同义改写下的证据一致性；
- $|m|$ 或实测 latency model 控制成本。

ERASER 式 sufficiency/comprehensiveness 可以作为诊断，但 Goodhart 研究表明它们可因 out-of-support complement 或 label encoding 被投机优化，不能作为唯一损失或唯一忠实性证据。

### 12.5 离线与在线分工

离线：

- 用 full Guard 的 gradient/IG、occlusion、token transformation、真实 leave-group-out 和人工 region/span 产生候选证据；
- 学习轻量 selector、预算档和回退阈值；
- 按 policy、OCR/小目标、视频事件、文本结构和 margin 做 worst-group 校准；
- 编译固定 shape 的 gather/merge/profile execution signatures。

在线：

- 只运行低清探针或早层轻量 selector；
- 动态选择 indices，但输出固定 $K$；
- 执行 Guard verdict；
- 根据 evidence sufficiency、coverage、stability 和 OOD 信号决定是否回退；
- rationale 在 verdict 后生成，证据坐标直接来自 provenance。

### 12.6 感知保留但政策绑定退化：2026-09-08 更新

XGuard 反转样本暴露出比“小目标被删”更细的候选失效模式：视觉 Token 剪枝后，模型仍能在归因中说出文字、雕塑、人像等主要实体，却无法稳定把实体、用户文本和安全政策组合成正确类别；随剪枝率上升，政策推断和语言生成同时下降。本文暂称其为 **perception-preserved policy-binding failure（感知保留的政策绑定失败）**。这是本地实验观察，不等于已证明因果机理；“归因中提到实体”也不保证模型在作出首 Token 判定时依赖了该实体。

相邻工作已经覆盖问题的不同侧面：

| 工作 | 已覆盖现象或机制 | 对本场景仍缺什么 |
|---|---|---|
| DSTP / RVIS（ECCV 2026） | 直接证明静态 prefill 剪枝在复杂视觉推理中失效；生成过程中所需视觉区域会变化，并用 decoding-stage detect-and-swap 恢复保留集 | 面向数学/逻辑推理；label-first Guard 在第一次 verdict Token 前还没有 decoding shift 可供检测 |
| Take-along Visual Conditioning（ACL 2025） | 长 CoT 中视觉注意逐步衰减，文本前缀接管后续推理；在关键推理阶段重新引入视觉条件 | 长数学 CoT，而非固定政策、多类安全判别和短 verdict |
| Look and Think（Findings ACL 2026） | 显式交替 looking/thinking，只在不需要视觉 grounding 时驱逐视觉 Token | 需要改变推理协议；没有评测 safety recall、政策绑定或 label-first 时延 |
| VFlowOpt（ICCV 2025） | 用渐进剪枝、recycled tokens 和 full/pruned 最后 Token 表征差异优化策略 | 最后 Token 表征是通用代理，不区分实体识别、政策关系和归因生成 |
| SafeWatch、Policy-Guided Safety Tuning、GuardReasoner-VL | 分别提供 policy-aware pruning、将政策写入安全推理、reason-before-decision 的直接安全先例 | 尚未系统隔离“实体已识别但政策映射失败”，也未在相同 Guard 上联合研究 Token 预算、决策顺序和归因忠实性 |
| GAP、SemVID | 分别处理 position-ID 错位和对象—运动—上下文证据链 | 没有覆盖图像安全政策绑定和生成阶段的决策轨迹 |

截至 2026-09-08 的检索范围内，已经有人研究“视觉 Token 剪枝破坏复杂推理”和“多模态推理中的视觉遗忘”，但没有发现正式工作同时满足以下四个条件：**label-first 多类安全 Guard、视觉实体仍可识别、政策绑定/类别判定退化、归因生成随预算退化**。这构成有本地实验和多篇相邻论文支撑的候选缺口，但不是穷尽性首次声明。

推荐把明确目标定义为 **Policy-Conditioned Reasoning-Preserving Token Compression（政策条件的推理保持 Token 压缩）**：在固定视觉 Token 预算且不增加完整 VLM 前向的条件下，同时保持：

1. perception sufficiency：小目标、OCR 和实体属性仍可恢复；
2. policy-binding sufficiency：在 verdict 位置保持图像—用户文本—政策关系和 full-token 风险 margin；
3. trace sufficiency：在确实需要归因时，保持视觉依赖生成 Token 的条件分布与证据 provenance。

第一版方法不应直接实现复杂 decoding-stage swap。更可判定的路线是用 full-token teacher 离线产生三类监督：verdict logit/margin、verdict 位置的 policy-conditioned hidden/attention relation、以及 on-policy 归因中视觉依赖较高的生成步骤；在线 selector 输出固定 shape 的 `evidence + relation + residual-memory` Token。被删 Token 不全部丢弃，可用少量带 provenance 的 merge/recycled tokens 保留上下文。

在开发 selector 前先做四个低成本因果诊断：

1. 在同一 pruned Token 集上比较 `label→归因`、`短实体描述→label`、`短政策推理→label`；若 description/reasoning-first 显著恢复分类，说明失败更接近过早决策或政策绑定，而非纯感知丢失。
2. 向剪枝路径注入人工/teacher 实体清单但不恢复图像 Token；若仍不能恢复，实体名本身不足以完成政策关系推理。
3. 分层比较 full/pruned 在 verdict Token、政策 Token 和风险类别 Token 上的 hidden state、logit lens、视觉注意与 gradient×activation；定位“看见”到“绑定政策”的断裂层。
4. 把归因拆成实体 span、关系/动作 span、政策理由 span 和普通模板 span，分别计算 teacher-forcing NLL；整体 PPL 会被大量模板 Token 稀释。

Go 条件：存在足够多、跨方法/seed 稳定的“实体召回保持但 verdict 翻转”样本；且 description-first、policy relation 恢复或决策状态对齐中至少一项能显著修复这些样本。若错误主要由实体遗漏或 position/M-RoPE 实现问题解释，则回到小目标 coverage/position correction，不应包装成新的推理保持问题。

### 12.7 双向翻转揭示的本质效应：2026-09-08 更新

本地实验还观察到两种相反变化：完整模型错误而剪枝后正确（`W→C`），以及完整模型正确而剪枝后错误（`C→W`）。当前后者数量约为前者的 2.5 倍；`W→C` 多见于视觉内容较简单的样本，提示完整路径可能受无关细节干扰。该观察支持但尚未证明“剪枝是证据净化”的解释，因为硬删除 Token 同时改变了输入内容、注意力归一化、序列长度、position ID、KV 形状和后续残差流。

更合适的概念不是“重要 Token 选择”，而是把视觉 Token 剪枝视为一次 **structured information intervention（结构化信息干预）**。一次翻转可能来自四类效应：

1. 删除正证据：应保留的实体、OCR、属性或关系断裂，形成 `C→W`；
2. 删除负贡献干扰：背景、共现捷径或竞争类别证据消失，形成稳定的 `W→C`；
3. 计算重标定：即使被删内容没有语义作用，attention denominator、位置和残差混合改变也可能翻转；
4. 决策边界抖动：低 margin 样本偶然越过边界，表面纠错但对轻微增强、prompt 或 seed 不稳定。

因此保留集不能直接当作模型解释，attention heatmap 也只能作描述性证据。DART 表明基于“重要性”的选择可落后于随机剪枝，说明冗余消除可能比单 Token 排序更关键；CrisPrune 与 VisPruner 分别揭示 attention sink、过窄文本聚焦和空间位置偏置，并以显著性、相关性和多样性共同补偿；EmbedLens 的 sink/dead/alive 分类与 Information Horizon 的删除效应则支持跨层追踪 Token 语义和因果影响。另一方面，VASparse 发现视觉无关的稀疏化会加剧幻觉，反对把稀疏化普遍解释为正则化或去噪。

当前最优先的实验是 [[LLM-Wiki/experiments/20260908-bidirectional-token-intervention/README.md|双向因果 Token 干预审计]]，而不是立即训练新 selector。实验在 `W→C`、`C→W`、`C→C` 与 `W→W` 四组中，对同一 mask 比较硬删除、等长占位、像素区域遮挡、互补集、随机/网格同预算、逐组回插和 merge-residual。若只有硬删除纠错，研究重点应转向注意力重标定与位置效应；若像素遮挡和删除均稳定纠错，且被删区域对错误类别有正因果贡献，才可将其称为 distractor removal；若随机 mask 同样纠错或轻微变换后失效，则属于不稳定边界效应。

若双向审计成立，候选方法应把 Token 分成带符号和结构角色的四类：`policy evidence`、`relation bridge`、`distractor`、`redundant`。目标不是保留最高分 Token，而是在固定预算中保留正证据与关系桥、合并冗余、删除对错误政策有稳定正贡献的干扰；离线因果干预可以生成监督，在线仍使用固定 shape 的轻量选择器。

### 12.8 标签先行的事后合理化：2026-09-08 更新

当前 Guard 按 `label → rationale` 自回归生成，可写为：

$$
P(y,r\mid x,z)=P(y\mid x,z)P(r\mid x,z,y),
$$

其中 $x$ 是图像、用户文本和政策，$z$ 是 Token 压缩状态，$y$ 是首标签，$r$ 是后续归因。由于 $r$ 在计算图上位于 $y$ 之后，归因天然同时受到视觉输入和已生成标签的条件化。于是“归因仍正确描述图像”只说明后续生成阶段仍可访问部分视觉语义，不证明这些语义曾导致首标签；“归因支持标签”也可能只是 label leakage 或 decision-conditioned justification。

这能解释一种表面矛盾：剪枝后，模型仍能在归因中识别实体，却先输出错误类别，并随后把真实实体重新组织成支持错误类别的解释。额外生成的标签和解释 Token 还提供了首标签位置不存在的后续计算，因此它也可能在判定后才恢复或强化视觉表征。当前不应把这种现象直接称为“推理能力完全丢失”，更准确的是 **early-commitment / decision–evidence consistency failure（过早承诺或决策—证据一致性失败）**。

它与双向翻转共享同一因果骨架：Token 剪枝先改变 verdict 前的决策状态，导致 `C→W` 或 `W→C`；首标签再作为中介变量支配后续政策理由。因而：

- `C→W` 后出现连贯错误归因，不能证明视觉信息已丢失；
- `W→C` 后出现连贯正确归因，也不能证明删除的 Token 是 distractor；
- 两类归因都可能只是在解释已经发生的标签翻转。

已有解释性研究为这一判断提供边界：Turpin 等证明语言模型会为由偏置诱导的答案生成看似合理但未披露真实原因的解释；Wiegreffe 等提出 label—rationale association 的必要诊断，但关联不等于“归因导致了先前标签”；RORA 进一步显示 rationale 对标签的支持度可被显式或隐式 label leakage 抬高。FRESH 的 faithful-by-construction 思路则要求预测器只能看到先抽取的证据，提供了更强但需要改变推理协议的对照。

优先实验应把标签作为可干预的中介变量。在同一 full/pruned 图像上分别强制 gold label、full prediction、pruned prediction 和一个语义邻近错误 label，再生成结构化归因；同时固定标签、切换 full/pruned/像素遮挡图像。分别评价：

1. perception report：实体、属性、OCR 与区域 grounding；
2. relation report：实体—动作—上下文关系；
3. policy justification：关系如何映射到安全条款；
4. label-consistency：归因是否仅顺从给定标签。

若换标签几乎只改变 policy justification，而视觉描述保持稳定，说明归因发生了“视觉事实保持、政策解释随标签重写”；若换标签还使视觉事实发生幻觉，说明标签反馈污染了感知报告；若固定标签后 full/pruned 仍造成关系或政策 span 显著变化，才说明压缩具有独立于标签的内容效应。

同时比较四种输出协议：`label-first`、`evidence-first→label`、`短 policy-reasoning→label`、`双通道 evidence extractor→独立 classifier`。若只需 8—32 个结构化 evidence/relation Token 就能显著恢复 pruned verdict，论文目标可从“保存所有推理 Token”缩小为 **delayed commitment under compressed vision（压缩视觉下的低成本延迟承诺）**；若只有独立 evidence bottleneck 有效，则应以 faithful-by-construction Guard 为主线；若输出顺序不能恢复，则返回 Token 内容/关系丢失问题。

## 13. Profile-aware Batch Serving 的位置

按 execution signature 组批确实可以把 Token 缩减转化为吞吐提升，但 profile routing、长度分桶、CUDA Graph clustering 和共享子网调度已有 PLA-Serve、SuperServe、Brainstorm 等直接先例。因此系统贡献只有在以下冲突被实验证明后才成立：

- 逐请求最优 Token/主干 profile 导致 batch fragmentation；
- 简单 padding 或 length bucketing 无法同时满足安全约束和 P99；
- 联合调度显著提高 fixed-FPR 约束下的 SLO goodput；
- 回退请求不会拖慢常规 batch 或耗尽容量。

建议第一篇论文只实现基本 profile batching 和真实时延；若 trace 实验证明上述耦合冲突足够强，再单独扩展为系统论文。

## 14. 实验计划

**当前顺序：** 保留下面的诊断项目，但先执行 §20.5 的训练对照矩阵；Phase A 审计与训练基线交替推进，无需等解释性假设全部成立。Phase B 只在廉价压缩+训练后仍有明确选择缺口时开展。Phase C 结构剪枝不在当前主线，Phase D serving 最后考虑。

### 14.0 2026-09-07 XGuard 实验反馈

本地 Qwen3-VL-2B-Instruct、41 类安全判别实验提供了以下探索性证据：

- L28 下 FastV 保留约 75% Token 时，accuracy 从 0.616 变为 0.615，TTFT P50 从 132.0 ms 降至 121.1 ms，是当前轻度在线剪枝基线；
- 输入 resize 保留约 50% Token 时，support≥20 macro 与 FastV/DivPrune 同保留率几乎相同（约 0.501），TTFT P50 为 64.6 ms，而 FastV/DivPrune 分别为 115.1/123.9 ms，确认 resolution-first 是必须击败的端到端基线；
- resize 的全支持类 macro 下降大于 support≥20 macro，结合类别级异质性，提示稀有安全类可能承担更集中损失，但由于 17/41 类缺少测试支持，该结论仍是假设；
- DivPrune 在轻剪枝时比完整路径慢约 1.1%，再次证明 diversity/attention-free 不等于零 selector 开销；
- R15 Ghosted 将直接删层后的 accuracy 从 0.485 恢复到 0.606，但 Gold attribution PPL 相对 L28 从 5.28 升至 16.15，说明首 Token 分类恢复不能代表归因恢复；
- Self-PPL 在严重退化时仍保持较低，不能作为压缩回退或解释质量信号；256-token 归因 decode 使吞吐只有约 0.279 requests/s，支持 verdict-first、按需归因。

该实验把 Phase A 的首要任务进一步收束为：先对已有输出做逐样本 harmful-flip 配对分析，再以平衡安全集验证 resize 的长尾失败子群；暂缓 R30/R45 结构剪枝和复杂 serving。完整复核见 [[LLM-Wiki/experiments/20260907-xguard-token-pruning-analysis/README.md]]。

### 14.1 Phase A：假设筛选

1. 建立 full-resolution/full-token 安全基线。
2. 构造 low/medium/full 分辨率配对推理，把样本分成稳定正确、低清漏报、低清误报和固有困难。
3. 比较 attention、activation、gradient、gradient×activation、Fisher、occlusion、diversity 和随机选择。
4. 计算每种分数与真实单组删除损失的 Spearman/Kendall、Top-K overlap、跨 seed/增强稳定性。
5. 分别画 safe/unsafe 的 token-budget—verdict—coverage—false-negative 曲线。
6. 建立“实体召回保持但 verdict 翻转”的 perception-preserved policy-binding 子集，比较各方法的交集与独有失败。
7. 在同一 Token 集上做 label-first、description-first 和短 policy-reasoning-first 输出顺序消融，并记录 time-to-verdict。
8. 将归因 NLL 拆为实体、关系/动作、政策理由和模板 Token，避免整体 PPL 掩盖政策推理退化。

Go 条件：至少一种低成本 evidence/stability 信号能稳定预测 pruning failure，且 unsafe 与 safe 的充分集/覆盖需求存在跨政策可重复差异；或者 perception-preserved policy-binding failure 跨方法/seed 稳定存在，并可由决策顺序、policy relation 恢复或 decision-state 对齐显著修复。

### 14.2 Phase B：Token 方法

基线：

`Full → random → uniform/grid → input downsampling → post-ViT pooling → FastV → SparseVLM → VisionZip/DivPrune → IF-Prune → SafeWatch-style policy pruning → proposed`。

核心消融：

- relevance only / coverage only / relation only / 三者联合；
- attention teacher / gradient teacher / occlusion teacher / teacher ensemble；
- early selection / late selection / provenance propagation；
- fixed mask / dynamic indices with fixed shape；
- no fallback / uncertainty fallback / coverage fallback；
- 视觉 only / 文本 only / 视觉—文本—政策联合。

### 14.3 Phase C：结构剪枝

在 Token 方法固定后，再比较：

- dense backbone；
- MHA-only、MLP-only、head/channel mixed pruning；
- 相同参数、FLOPs 和 P95 latency 三种预算；
- task Taylor/Fisher、真实迭代消融与局部重构；
- 是否保护跨模态/安全专门 head。

### 14.4 Phase D：Serving

使用真实或公开到达 trace，比较：

- 无压缩 dense Guard；
- 固定单一 Token profile；
- 逐请求最优但不感知 batch 的 router；
- 简单长度/profile bucketing；
- evidence/SLO-aware joint scheduler。

报告 time-to-verdict、P50/P95/P99、goodput、GPU utilization、回退率、每类风险漏报和单位请求能耗。

## 15. 可解释性评测

### 15.1 Plausibility

- 人工 box/span IoU、pointing game；
- policy-clause 命中；
- 人类对证据区域和短 rationale 的一致性判断。

### 15.2 Faithfulness

- selected-only 判定保持；
- complement-only / removal 后的风险下降；
- 原始像素与文本 span insertion/deletion；
- counterfactual consistency；
- 不同分辨率、平移、裁剪和政策同义改写下的 mask stability；
- 独立审计模型是否也依赖同一区域。

### 15.3 防止指标投机

- 不只在内部晚层表示上 mask，要在原始像素或早期 Token 空间干预；
- 检查选择器是否把标签编码进特殊 Token、mask 形状或位置；
- 让 rationale 与 complement 尽可能保持分布内；
- 使用未参与 selector 训练的独立 attribution/审计模型；
- 测试攻击者移动、缩小、遮挡或重语境化危险证据的能力。

## 16. 新颖性、风险与投稿策略

### 16.1 当前优先级（替代此前定性“中高新颖性”）

| 方向 | 当前判断 | 必须击败的最近邻 |
|---|---|---|
| G1 学生证据可观察性约束的跨分辨率训练 | 第一优先的候选空白，未证实 | TBD 可靠蒸馏、ViCO、EPIC、低清安全 SFT；LOREAL 尚需原文排重 |
| G2 低预算图文—政策关系与首判定训练 | 第二优先；必须有组合风险机制证据 | ETC、TBD margin、Att-CoT、GuardReasoner-VL |
| G3 压缩前后干预效应保持 | G1/G2 的备选机制消融 | Evidence-RL、FRESH/ERASER |
| G4 压缩训练后 Guard 特有绕过及防御 | 安全方向候选主线 | CAA/T-CAA、OOD-VTP、原生完整 Guard |
| G5 多预算/困难组训练课程 | 已有框架上的增量备选 | EPIC、ViCO、M3、DualSpeed |
| evidence/uncertainty selector、profile batching | 组件；不优先作为主创新 | ET-Prune、VisionThink、既有 serving |
| 模型结构剪枝 | 本轮不优先 | 既有结构压缩研究 |

未找到完全相同论文不等于没有工作；G1–G4 都需要实证。原方案的 provenance、safe-coverage、attribution stability 保留诊断价值，但不再预定为贡献。

### 16.2 主要失败风险

- 教师正确但学生输入不可辨，强一致性教会捷径或过度自信。
- 训练增益来自数据量/重采样，而非压缩特有机制。
- 首标签训练牺牲政策关系或生成解释；需要分别评测。
- 未训练的完整回退路径退化；“更多 token”并非模型能力保证。
- 用同一模型错误筛选困难集，造成选择偏差；同时报告外生子群与完整测试分布。
- 学习型压缩前端或审计开销吃掉短标签收益。
- 困难组稀少，置信区间过宽；不能从小样本推断极低 FPR 安全性。

### 16.3 投稿定位

以下是研究判断，不是 venue 录用承诺或最新征稿规则。

- **CVPR / ICCV / ECCV（首选）**：核心需是视觉证据在分辨率/预算变化下的可学习性、空间/关系保持与跨模型规律；不仅将通用 KD 换成安全标签。给出受控视觉反事实、真实困难样本与可复用训练方法。
- **IEEE S&P / USENIX Security / ACM CCS / NDSS（安全四大）**：核心需是压缩 Guard 的明确安全失效、现实攻击者能力、跨状态/跨分布评测和有效防御。只降低拒答 ASR 或只恢复普通 QA 不充分；必须区分检测遗漏与被保护模型生成行为，并排除“总拒绝/总回退”的伪防御。
- **OSDI / SOSP（第三优先）**：当前训练算法本身不支撑系统投稿。只有后来发现训练预算、升级路径与资源争用形成现有调度无法解决的系统问题，再构建系统机制、工作负载和尾时延证据。不要为 venue 强加 serving。
- **NeurIPS / ICLR**：若可观察性与学习目标的规律跨任务成立，可作为方法方向备选。

## 17. 推荐实施顺序与停止条件

1. **数据和任务基线**：确认 41 类到 safe/unsafe 的政策映射、完整多模态 SFT 能力、困难组支持数；保留旧负结果，不以 text-only 微调替代图文安全训练。
2. **训练对照先行**：固定主干与廉价压缩，用 §20.5 的 T0–T4 建立前沿；并行含义仅指实验流程交替，不要求新建 agent 或立即运行 GPU。
3. **可见性机制筛查**：在训练/开发集构造 evidence-visible/ambiguous/erased 配对，独立人工检查；用 T5 及去门控消融检验 G1。
4. **只增加一个主要机制**：若关系错误主导，加入 G2；若压缩绕过显著，转 G4；G3 作为区分捷径与真实证据的诊断。
5. **跨预算/模型复核**：检查不同压缩算子、另一 VLM 家族、保留 full-path 能力、未知政策与未见布局。
6. **最后决定在线升级**：固定预算训练已经有效且确有不可观察子群时才加 G6；结构剪枝和服务调度继续靠后。

停止条件：在相同 FPR 与实测延迟下未优于普通低清 SFT/TBD，或效果仅来自扩大数据/提高回退率，就停止声称新压缩训练贡献。G1 若不成立不意味全部训练失败；按失败归因转入任务数据改进或明确的增量研究。

## 18. 论文贡献的推荐表述

当前只能写成“拟研究/拟验证”，而非既成贡献：

1. 区分压缩安全判别中的证据仍可见但未被利用、与关键证据已不可观察两类失败，建立独立于模型单次错对的配对评测。
2. 研究保持原有主干的训练目标，将可见证据的图文—政策判别保持与证据不足时的监督分开，并检验其相对强蒸馏基线的独立收益。
3. 在固定 FPR 下报告困难组召回与完整 time-to-verdict 前沿，并审计压缩状态新增漏报及完整路径回归。

若实验只支持其中一项，论文必须缩减贡献。不要使用“首次高低分辨率蒸馏”“首次剪枝感知训练”“无损安全压缩”等措辞。

## 19. 代表性来源

### 多模态 Token 剪枝与压缩

- [TRIPS, EMNLP 2022](https://aclanthology.org/2022.emnlp-main.273/)
- [PuMer, ACL 2023](https://aclanthology.org/2023.acl-long.721/)
- [FastV, ECCV 2024](https://www.ecva.net/papers/eccv_2024/papers_ECCV/html/9345_ECCV_2024_paper.php)
- [DivPrune, CVPR 2025](https://openaccess.thecvf.com/content/CVPR2025/html/Alvar_DivPrune_Diversity-based_Visual_Token_Pruning_for_Large_Multimodal_Models_CVPR_2025_paper.html)
- [SafeWatch, ICLR 2025](https://proceedings.iclr.cc/paper_files/paper/2025/hash/beac6bfb7eac3d651307c16ac747df01-Abstract-Conference.html)
- [IF-Prune, CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Sun_IF-Prune_Information-Flow_Guided_Token_Pruning_for_Efficient_Vision-Language_Models_CVPR_2026_paper.html)
- [DART, EMNLP 2025](https://aclanthology.org/2025.emnlp-main.505/)
- [CrisPrune, Findings ACL 2026](https://aclanthology.org/2026.findings-acl.663/)
- [What Do Visual Tokens Really Encode?, CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Fan_What_Do_Visual_Tokens_Really_Encode_Uncovering_Sparsity_and_Redundancy_CVPR_2026_paper.html)
- [When Token Pruning is Worse than Random, CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Wang_When_Token_Pruning_is_Worse_than_Random_Understanding_Visual_Token_CVPR_2026_paper.html)
- [VASparse, CVPR 2025](https://openaccess.thecvf.com/content/CVPR2025/html/Zhuang_VASparse_Towards_Efficient_Visual_Hallucination_Mitigation_via_Visual-Aware_Token_Sparsification_CVPR_2025_paper.html)
- [VisPruner, ICCV 2025](https://openaccess.thecvf.com/content/ICCV2025/papers/Zhang_Beyond_Text-Visual_Attention_Exploiting_Visual_Cues_for_Effective_Token_Pruning_ICCV_2025_paper.pdf)
- [Grounding-Aware Token Pruning](https://arxiv.org/abs/2506.21873)
- [SemVID / Keeping the Evidence Chain, ECCV 2026](https://arxiv.org/abs/2603.05663)

### 视觉推理保持与安全政策绑定

- [Why and When Visual Token Pruning Fails? / DSTP, ECCV 2026](https://arxiv.org/abs/2604.12358)
- [Take-along Visual Conditioning, ACL 2025](https://aclanthology.org/2025.acl-long.257/)
- [Look and Think, Findings ACL 2026](https://aclanthology.org/2026.findings-acl.1241/)
- [VFlowOpt, ICCV 2025](https://openaccess.thecvf.com/content/ICCV2025/html/Yang_VFlowOpt_A_Token_Pruning_Framework_for_LMMs_with_Visual_Information_ICCV_2025_paper.html)
- [Teach to Reason Safely, ICLR 2026](https://proceedings.iclr.cc/paper_files/paper/2026/hash/8ece25974724edad00c8d0bcc8a235e8-Abstract-Conference.html)
- [GuardReasoner-VL](https://arxiv.org/abs/2505.11049)

### 可解释性与 Rationale

- [X-Pruner, CVPR 2023](https://openaccess.thecvf.com/content/CVPR2023/html/Yu_X-Pruner_eXplainable_Pruning_for_Vision_Transformers_CVPR_2023_paper.html)
- [FRESH, ACL 2020](https://aclanthology.org/2020.acl-main.409/)
- [ERASER, ACL 2020](https://aclanthology.org/2020.acl-main.408/)
- [Token Transformation Matters, CVPR 2024](https://openaccess.thecvf.com/content/CVPR2024/html/Wu_Token_Transformation_Matters_Towards_Faithful_Post-hoc_Explanation_for_Vision_Transformer_CVPR_2024_paper.html)
- [Goodhart's Law Applies to NLP's Explanation Benchmarks, Findings EACL 2024](https://aclanthology.org/2024.findings-eacl.88/)
- [Measuring Faithful and Plausible Visual Grounding in VQA, Findings EMNLP 2023](https://aclanthology.org/2023.findings-emnlp.206/)
- [Language Models Don't Always Say What They Think, NeurIPS 2023](https://proceedings.neurips.cc/paper_files/paper/2023/hash/ed3fea9033a80fea1376299fa7863f4a-Abstract.html)
- [Measuring Association Between Labels and Free-Text Rationales, EMNLP 2021](https://aclanthology.org/2021.emnlp-main.804/)
- [RORA, ACL 2024](https://aclanthology.org/2024.acl-long.60/)

### 相邻 Wiki 证据

- [[LLM-Wiki/research/safety-classifier-compression/comparison.md|安全判别剪枝、重要性指标与 MHA/MLP 比较]]
- [[LLM-Wiki/research/safety-classifier-compression/autoregressive-multimodal-guard-token-pruning.md|自回归多模态 Guard Token 剪枝]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝概念]]
- [[LLM-Wiki/concepts/methods/deepstack-visual-token-injection.md|DeepStack 视觉 Token 深度注入概念]]
- [[LLM-Wiki/experiments/20260825-vispco-qwen25vl-small/README.md|Qwen2.5-VL Token 剪枝实验记录]]

## 20. 训练流程与最小可验证方案（2026-09-08）

### 20.1 把目标写成有约束的前沿

设 x=(I,q,p) 包含图像、用户文本和政策；y 为经核验标签，g 为预先定义的困难/政策组。b=(r,k,l) 分别指输入像素预算、视觉保留预算和压缩位置，三者不能用单一“保留率”替代。θ 是同一原生主干的可训练权重，π 是可选的预算策略，τ 是在独立校准集确定的判定阈值。

一项操作目标是：最小化实测期望 time-to-verdict，约束整体 FPR≤α、关键困难组 Recall_g≥ρ_g，并检查 P99≤D。反向也可以在固定 D 下最大化 worst-group recall。α、ρ_g、D 为部署/研究预注册参数，本轮不替用户编造业务标准。报告完整 Pareto 曲线，而非宣称同时达到全局最快和最高召回。

除固定 FPR 下整体 unsafe recall 外，报告 macro/worst-policy recall、困难组 recall、严重度加权漏报、AUPRC、校准误差和每组支持数。若真值是多标签，不把 41 类强制当互斥多类；若 safe/unsafe 的映射尚未确认，则只报告原类别指标。

### 20.2 保持结构的实现边界

- 第一实现用原有视觉塔、projector、LLM 与 LM head；LoRA 可合并进线性权重。先训练 LLM+projector，是否解冻视觉塔作为独立消融，不先删层/头。
- 默认只缩短视觉输入，保留用户文本和政策。否定、引用和风险上下文不按高低 attention 随意删除；政策缓存是独立工程优化。
- 路径 A：原生可变分辨率的低像素输入；路径 B：高清视觉编码后固定网格/均匀保留，再送入 LLM；路径 C：已有浅层 selector。先验证 A/B+训练，再决定是否值得训练 selector。
- 不新增 Q-former、memory tokens 或分类头；不把 ETC/VisCo 的特殊执行协议视为默认候选。诊断辅助模块只在训练期使用并在部署移除。
- Qwen3-VL 必须同步处理保留索引、mRoPE/位置、视觉占位 token 与每个 DeepStack 注入平面；不能只裁最终 embedding。规则压缩也要物理缩短张量，掩码置零不等于节省计算。
- 无新增 head 不代表无代码改动；张量整理、原生动态分辨率支持和数值一致性仍需实测。

### 20.3 数据：把可观察性与教师正确性分开

先复用已有数据、标签和失败记录，不改 raw。训练集/开发集/校准集/测试集按原始图像或视频来源分组切分，派生分辨率、裁剪、反事实和同模板样本不能跨集合泄漏。

三种训练配对：

1. **分辨率×token 配对**：高清完整、低清完整、高清编码后少 token、低清后进一步压缩；报告实际 token 与像素。另做相同 LLM token 数、不同像素输入的匹配比较。
2. **政策关系配对**：同图不同文本/政策、同文不同图；危险对象出现不必然等于违规，文本意图/上下文可改变真值。标签必须经明确政策复核，不以模型生成 rationale 自动定真值。
3. **证据可见性配对**：局部 OCR、尺度/对比度、对象关系、角落细节、短时事件。使用独立标注与受控合成先建立可辨/模糊/不可辨三组；full 正确而 low 错误只作候选挖掘，不作可见性真值。

困难组预先定义为 small/OCR、跨模态组合、语境例外、长尾政策、遮挡/低对比度和视频短事件。单独保留 full 模型本来就错的组，不把 teacher-correct 子集当全部任务。受控子集用于解释机制，自然数据用于估计实际频率，两者分开报告。

### 20.4 训练目标草图（hypothesis，非已有实现）

先完成普通多模态安全 SFT，形成可用的 full teacher；再在与部署一致的 b 上训练学生。同一 batch 可取 full/中/低三个预算，但额外前向总成本需记录。

令 v(x,b) 为训练期独立估计的证据可见性，q_T 为教师监督质量，p_T、p_S 为政策标签分布。一个最小目标是：

L = L_task + λ q_T v(x,b) KL(stopgrad(p_T) || p_S)
    + μ L_relation + ν L_full-anchor + ξ L_observation.

- L_task：经核验标签的任务监督，类别/困难组重加权只是常规基线。对确实不可观察输入，不把高清硬标签当作确定性可学习目标；可用配对经验条件分布或升级监督，具体选择由实验验证。
- 蒸馏门控：q_T 和 v 是不同变量。只过滤教师错误是 TBD 类基线；只有增加学生可见性控制后有独立收益，G1 才成立。
- L_relation：只对语义成立且证据可观察的政策反事实保留正确标签差异；对标签不变的背景扰动学习不变性。不把真实改变标签的文本替换强制一致。
- L_full-anchor：混合完整预算监督，防止多预算训练损伤完整路径。共享权重教师用 stop-gradient 或冻结快照，避免互相追逐的漂移。
- L_observation：可选训练现有词表中的“需要复核/更多观测”动作；这是输出协议变化，须单独消融。若坚持二分类接口，则先研究固定预算和概率校准，不强加新动作。
- 不强制风险分数随 token 数单调；更多 token 也可能引入干扰。只在受控证据恢复、真值保持的条件下检验方向。
- 提升困难召回不能只通过增大 unsafe 权重宣称；所有模型均在独立校准后以相同 FPR 比较，检查是不是只移动阈值。

高低分辨率对齐优先从 verdict 分布和经验证的关系监督开始；逐 patch feature MSE 需要坐标映射、共同可见区域和遮挡处理，不能将不同网格硬对齐。辅助 relation probe 若使用，仅训练时存在；其标签解码成功不构成因果证据，仍需原像素/文本干预。

教师可离线生成短政策推理，但学生的 verdict loss 不得看到 gold label 前缀或教师答案；使用答案前可用状态。先比较 verdict-only、训练期 rationale 辅助、在线短 reasoning 三组；第三组全部 decode 都计入延迟，不能算同成本提升。

### 20.5 必要训练对照矩阵

同一数据分割、相同基础 checkpoint、相同算力预算主比较；另报告等样本量对照，因为双前向 KD 不能同时自动满足两种公平性。方法复现与本项目简化改编要分开命名。

| 条件 | 训练与推理 | 回答的问题 |
|---|---|---|
| T0 | full-resolution、多模态安全 SFT → full | 任务能力基线；不是理论上界 |
| T1 | T0 → resize / uniform / FastV / DART 等，不再训练 | 纯推理压缩代价 |
| T2 | 同样安全数据直接在低清/少 token 训练 | 普通任务适配能解决多少 |
| T3 | 固定预算 CE+KL，再加 TBD 式正确置信过滤与 margin | 蒸馏各组件和 teacher-quality 的收益 |
| T4 | EPIC 式渐进预算；ViCO 式多预算一致性；M3 式网格 | 多预算课程是否已解决问题；分别比较，不合成一个弱基线 |
| T5 | T3/T4 中较强者 + 学生可见性门控 | G1 的独立增量 |
| T6 | T5 + 政策关系反事实，或 + 干预效应 | G2/G3，逐项添加 |
| T7 | 胜出训练法 + 受约束的压缩状态鲁棒训练 | G4，含无压缩鲁棒训练对照 |
| T8 | 固定预算前沿成立后才加升级动作 | G6 的实际收益与成本 |

必须增加：等量 hard-example 重采样、随机打乱可见性标记、无门控、仅教师过滤、仅低清训练、去关系监督、text-only/image-only 和完整预算回归。若 T5 优势在打乱标记后仍在，检查是否只是增加训练资源或正则。

### 20.6 度量和统计预注册

- 阈值只在独立校准集选取，测试集锁定；各预算单独阈值与统一阈值分别报告。可画若干 FPR 操作点，但先保证良性样本数量支持该精度。
- 对 recall/FPR 报二项区间，对同样本方法差用配对 bootstrap；预先固定困难组，避免结果出来后挑有利子群。无事件不代表风险为零，极低 FPR 不能凭小样本确认。
- 训练有随机性，建议至少三个独立 seed；若算力只允许单 seed，明确探索性。预算搜索、checkpoint 选择不能用最终测试集。
- harmful-flip = full 正确检出而 compressed 漏报；另报 compressed 修复 full 错误，分开呈现。full 本来错的风险不能从总体 recall 分母移除。
- time-to-verdict 包含预处理、视觉编码、压缩/整理、LLM prefill 和实际 verdict 解码；若 verdict 本身需多个 token，计入完整序列，不只 TTFT。固定 warmup、batch、硬件、精度、输入分布和输出格式，报告 P50/P95/P99。
- 不把 teacher 训练、反事实审计或预处理的开销隐去：它们可不在在线关键路径，但需报告训练 GPU 小时、峰值显存、标注成本与缓存占用。动态升级须包含低清失败前向与重新编码，最终 FPR/recall 以完整策略评估。
- 先在 batch=1 证明模型方法，再补少量真实 batch；不需要先开发大型 serving 系统。

### 20.7 最小研究判断

若 G1 成立，最有价值的结果不是一个新 KL 公式，而是“哪些压缩错误可由训练修复，哪些必须增加观测”的可复现分界，以及该分界对固定 FPR 的困难召回—时延前沿的因果贡献。若只有 G2/G4 成立，据实际证据改写论文主张。若均不成立，保留负面证据，将普通低清安全训练视为实用结果，不用 serving 包装不存在的算法空白。

## 21. 值得优先尝试的新方法（2026-09-08 二次收束）

### 21.1 排重结论

用户提出的三点分别有强最近邻：EfficientVLM 已蒸馏并缩短视觉编码器；METR 已用多出口任务压力和自蒸馏强化早层表示；Patch Slimming、Dyna-ViT 与 QuietPrune 已覆盖深层指导早剪、encoder 前无参选择和 query-guided ViT 内早剪；EPIC、TBD 与 ViCO 已覆盖压缩样本训练、多预算一致性和教师蒸馏。FastVLM 还用新视觉 backbone 联合优化视觉编码时延与 LLM token 数。

因此，论文不能写成“截视觉层+早剪 patch+剪枝样本微调”。建议把三者变成一个共同机制问题：

> **一个原始视觉塔前缀在什么条件下已经包含完成图文—政策安全判别所需的充分证据；如何用训练主动发现并修复输入预算与深度共同造成的最危险漏报？**

这一定义使每个组件都服务于安全充分性，而非并列堆叠加速技巧。

### 21.2 主方法：政策因果安全充分视觉前缀（PC-SVP，hypothesis）

#### 推理路径

部署只保留现有视觉塔前 $d^*$ 层、原 projector、原 LLM 与原判定接口。训练期辅助出口、完整教师和压缩状态搜索全部删除；若 LoRA 使用后可合并，则在线不增加模块。第一版使用固定 $d^*$ 与固定输入预算，避免动态路由和双跑吞噬 P99 收益。

#### 训练期多深度学生

对候选深度 $d\in D$，将该层视觉隐藏状态直接送入原 projector 和 Guard 判定路径，得到风险分数 $s_\theta(x,z)$。完整深度 $L$ 的冻结快照作为教师。浅层监督不以复原所有 final-layer patch feature 为目标，而使用三类安全充分性信号：

1. **真实标签损失**：在每个候选压缩状态上训练安全标签，所有模型在独立校准后按相同 FPR 比较。
2. **政策效应蒸馏**：对同图不同文本/政策、同文不同图的经核验最小对照，保持教师的分数差 $\Delta s_T$，而非复制 rationale 文本。若对照使真值改变，学生应保持方向与间隔；若只改无关背景，学生应保持不变。
3. **原像素证据效应**：删除或恢复经核验视觉证据，要求浅层学生的 verdict 变化与完整路径同向。attention 或内部 mask 只用于候选发现，不能替代像素干预。

可写成训练草图：

$$
L_{prefix}=L_{gold}+\lambda v(x,z)q_T L_{KD}+\mu v(x,z)L_{policy\text{-}effect}+\nu L_{pixel\text{-}effect}+\eta L_{full\text{-}anchor},
$$

其中 $q_T$ 表示教师标签可靠性，$v(x,z)$ 表示学生在状态 $z$ 下的证据可观察性。二者必须分开：高清教师正确不代表低清/少 patch 学生看得到证据。不可观察样本不做强确定性 KD；若二分类接口不允许复核动作，则这些样本用于确定可接受的最低输入预算，而非宣传训练恢复了消失信息。

#### 与 METR/EfficientVLM 的关键差异

- METR 的 early pressure 用于改善 `[CLS]` attention 与视觉类别 token 重要性；PC-SVP 检验的是图文—政策最小对照和像素证据干预下的 Guard 决策充分性。
- EfficientVLM 蒸馏通用紧凑 VL 模型并做模态结构剪枝；PC-SVP 复用同一视觉塔前缀，主指标是固定 FPR 的 image-only/跨模态 worst-group recall 与完整 time-to-verdict。
- 若去掉政策/像素效应后普通 logit KD 一样好，则不得保留“因果安全前缀”的主张。

### 21.3 联合训练器：最坏压缩格训练（WCST，hypothesis）

设 $z=(r,k,d,m)$ 分别表示输入分辨率、首层 token 数、视觉深度和 patch mask。每个样本不平均遍历所有预算，而从候选状态中选择导致 unsafe margin 最低或判定损失最高的 top-$q$ 状态，优化其 CVaR；同时保留完整路径 anchor。对 safe 样本不简单最大化 unsafe 分数，而在独立良性集上保持 FPR/排序校准。

训练闭环为：

1. 当前学生在一组廉价候选状态上前向；
2. 找到造成 full-correct→compressed-miss 的状态，或选择损失尾部；
3. 回传该状态的 PC-SVP 损失；
4. 将稳定复现的 harmful flip 放入下一轮 replay；
5. 周期性加入 full、随机状态和 safe hard negative，防止只学保守阈值。

这一组件不是把 random multi-budget 换成 max loss后就声称创新。必须证明压缩格尾部训练对**未见分辨率、mask 与深度**仍有效，并超过等量 hard-example 重采样、类别重加权、EPIC 渐进课程和 ViCO 式一致性。若只在已采样状态有效，作为训练技巧降级。

### 21.4 数据机制：压缩翻转反事实回放（CFR，hypothesis）

合成数据不以“随便剪一遍再训练”为单位，而以**能改变安全判定且真值可复核的压缩翻转**为单位。优先构造四种成对变换：

- 尺度/位置：同一危险证据移动到角落、缩小或被轻度遮挡，仍保持人可识别和标签不变；
- OCR/对比度：保持政策含义的文字在不同字号、对比度和背景出现；
- 图文关系：保持图像，改变请求意图、否定、引用、教育/报道语境，使标签按政策明确改变或保持；
- 干扰覆盖：加入高显著但无关区域，测试早剪是否因 saliency/query shortcut 丢失低显著危险证据。

生成器只提出候选；标签、标签是否保持以及证据可见性要通过规则、人工抽查或可信标注流程确认。数据按原图、模板和背景族分组切分。训练时只重放在多个 seed/算子下稳定出现的 flip，避免把一次随机边界抖动学成伪规律。

CFR 与普通 hard-example mining 的差异必须由交互消融证明：在 full 模型和非压缩训练上加入同样样本的收益应显著小于在 PC-SVP+WCST 上的收益；否则它只是更好的安全数据，不是压缩研究贡献。

### 21.5 第二阶段输入机制：全局底图 + 稀疏高清证据残差（GCR，hypothesis）

若直接 resize 的小证据损失成为主要失败，可在首个自注意力前构造固定 token 序列：低分辨率全图 token 作为不可删除的 global canvas，保证每个区域至少有粗观测；再从高清 patch embedding 中追加固定 $K$ 个 residual tiles，补回 OCR、小目标和局部关系。位置仍使用原二维坐标，Transformer 主干不新增 token memory 或 resampler。

训练期以 PC-SVP 的政策/像素效应监督 residual tile；推理 scorer 必须极小且单次运行。最小实现可先用已有 patch embedding 加一个可合并线性 scorer；若需要 QuietPrune 式文本 adapter，则结构与时延开销必须诚实计入。Dyna-ViT、QuietPrune、uniform grid、纯 resize 和更高统一分辨率是必要基线。

GCR 的风险较高：混合尺度和 query-guided early pruning 已很拥挤。只有在相同首层 token、相同输入读取和 selector 延迟下显著改善 small/OCR/角落危险组，且 policy/causal supervision 的消融解释收益，才适合作为视觉顶会贡献。

### 21.6 推荐的论文打包方式

**首选 CVPR 路线：** PC-SVP 为主贡献，WCST 为训练算法，CFR 为机制数据，GCR 仅在证据表明 resize 不可接受后加入。中心 claim 是“安全充分性可被前移并用压缩尾部训练验证”，而非创建新 selector。需要跨两种 VLM/Guard、至少三种视觉深度和多种输入预算；主要图展示 fixed-FPR worst-group recall—time-to-verdict Pareto 与 harmful-flip 机制分解。

**安全四大路线：** 将攻击者能力明确为控制危险证据尺度、位置、OCR 和图文关系，但不能改变人类可见真值；评估未知预算/剪枝算子/模型。主贡献必须是独立 Guard 的压缩绕过面与训练防御，且区别于 SAP 的生成模型 jailbreak、推理期良性 token 恢复。PC-SVP/WCST 是防御，CFR 同时构成自适应攻击训练集。

**OSDI 路线：** 当前不优先。只有固定前缀/固定 token profile 已产生显著模型前沿，且真实请求分布下出现独立的组批、缓存、尾时延或升级 goodput 问题，才转为系统论文；否则 serving 只是实现验证。

### 21.7 最小实验顺序与停止条件

1. **E0 可行性：** 固定 full 输入，分别截到 25%/50%/75% 视觉深度；比较无训练、普通安全 SFT、logit KD、METR 式多出口、自提 PC-SVP。若浅前缀在合理预算下无法接近 full，先停止早剪组合。
2. **E1 两轴交互：** 对胜出深度加入 resize/uniform token；比较独立训练与联合深度×输入训练。确认收益不是阈值移动。
3. **E2 尾部训练：** 随机多预算 vs 等量 hard replay vs WCST；测试未见 mask/分辨率/深度和预注册困难组。
4. **E3 输入方案：** 只有 E1 显示小证据不可见是主要瓶颈时实现 GCR；严格计算 patchify/scorer/packing/视觉塔/prefill/判定全时延。
5. **E4 安全分支：** full/compressed × clean/perturbed 四格，自适应攻击后重测；若收益靠始终 unsafe 或大比例回退，判失败。

最先值得实现的是 E0。它只需训练期接出候选视觉层、复用原 projector/Guard 判定并加配对 loss，不需要先开发 selector、router 或 serving。若 E0 中 PC-SVP 对 METR/KD 没有独立优势，应及时放弃复杂组合，避免把三个已有组件包装成新方法。
