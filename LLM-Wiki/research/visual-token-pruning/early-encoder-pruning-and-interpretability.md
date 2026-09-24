---
id: early-encoder-pruning-and-interpretability
type: synthesis
title: "视觉编码器浅层剪枝与可解释性证据"
tags: [research, visual-token-pruning, vision-language-model, representation-probing, efficient-inference]
project_id: visual-token-pruning
sources: [paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-yu-2023-x-pruner, paper-fan-2026-visual-token-semantics, paper-wang-2026-information-horizon, paper-tong-2025-flowcut, paper-liu-2025-meteor, paper-han-2026-ficoco, paper-hu-2026-illava, paper-liu-2024-mustdrop, paper-islam-2025-adaptmerge, paper-chen-2026-evoprune, paper-zhang-2026-vscan]
status: active
created: 2026-09-10
updated: 2026-09-24
---

# 结论

在视觉编码过程中用浅层特征决定 token 去留是可行且已有正式先例的；决策甚至可以发生在首个 Transformer block 之前。需要区分三种位置：pre-encoder patch 选择、视觉编码器内部的渐进剪枝，以及完整视觉塔之后的 VLM token 压缩。只有前两种能够减少视觉塔本身的计算。

是否需要重训取决于选择信号。无参图像显著性可以直接用于 pre-encoder 选择；复用已有 attention 也可能免训练或仅微调。若要让选择依赖文本 query、政策或安全判别，则通常需要轻量 adapter、辅助出口、蒸馏或联合训练，使浅层表示提前携带任务相关信号。Patch Slimming 的深层到浅层监督、METR 的多出口压力与自蒸馏、QuietPrune 的 query-to-vision adapter 分别提供了这三类先例。

# 方法谱系

## 严格子集：生成式 MLLM 的 ViT 内 token 减少

2026-09-16 按用户约束重新筛选：必须在视觉 Transformer 出口之前实际缩短序列，且在图文/视频输入到自回归文本输出的模型上评测；纯分类、检索、分割及仅在 projector/LLM 输入端压缩不算。VQA 的最终指标可以是准确率，但模型仍通过自回归生成答案，不等同于纯 ViT 分类。

以下为原文方法及实现位置的 skimmed 核验，不是代码复现。QuietPrune 复用既有 deep-read。表中联合流水线收益不能归因给 encoder-only 部分，也不能跨硬件比较 SOTA。

| 方法 / 来源笔记 | ViT 内执行位置与机制 | 类型 / 训练 | 生成式评测与代表数据 |
|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-tong-flowcut.md]] | 每两层剪一次；attention 熵控制预算，attention、全局语义相似性、Value 范数及跨层累计分数选 token；LLaVA-1.5 在视觉倒数第二层完成 | 剪枝；可免训练，也评测训练时使用 | LLaVA-1.5/NeXT、Qwen2-VL、Video-LLaVA；LLaVA-1.5 576→64，12 项平均相对性能 96.0%；POPE/A800：prefill 102→62.6 ms，整套运行 17:05→11:17 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-liu-meteor.md]] | 多视觉编码器内多个 block 后渐进 gather；前三分之一用平均 token 相似性，后两段用 class attention；feature-map rank 分配各编码器预算 | 剪枝；projector 预训练及 whole-model SFT；LLM 末段策略免训练 | EAGLE 风格 Vicuna-7B/Llama3-8B；11 项 VQA/OCR/chart；Ascend 910B 联合三阶段：26.21→13.42 TFLOPs，0.81→1.18 throughput，平均 69.3→69.0 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md]] | ViT 深度 1/4、1/2、3/4；query adapter 得到 `[Q-CLS]`，按 2×2 分组 attention 剪除，另聚合被删信息 | 剪枝加聚合；冻结 VLM，仅训练轻量 adapter | Qwen3-VL-4B、InternVL3-1B/8B；六项生成式多模态基准；50% 平均剪枝时 InternVL3-8B 相对性能 97.4%、prefill latency 降 49.3%（A100） |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-han-ficoco.md]] | FiCoCo-V 从视觉第 12 层开始；联合替代性与 CLS 语义冗余过滤，关联并选择性回灌到保留 token | 剪枝—合并混合；免训练 | LLaVA-1.5/NeXT、Video-LLaVA；FiCoCo-V 单独在 LLaVA-1.5-7B 8.5→3.3 TFLOPs、六项平均相对性能 95.2%；不要借用 FiCoCo-L 的最佳数字 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-hu-illava.md]] | 若干视觉 block 的 Attention 与 FFN 之间合并，再在若干 LLM block 后合并 | 合并，不是纯丢弃；免训练 | Qwen2.5-VL、InternVL2.5、MiniCPM-V2.6、LLaVA-OneVision；图像/视频问答；联合模型摘要报告最高 2× throughput、4× prefill 加速 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2024-liu-mustdrop.md]] | Local Spatial Merging 在 ViT 第 1 层按窗口合并邻近高相似 token；后续 prefill/decode 另剪枝 | ViT 阶段是合并；免训练 | LLaVA-1.5/NeXT、Video-LLaVA；TextVQA encoder-only 消融：平均 576→440，58.2→58.3；88.5% FLOPs 下降是联合方法，非 ViT 单阶段 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-islam-adaptmerge.md]] | AVTM 在每个视觉 encoder layer 的 Attention 与 MLP 之间按 key 多样性合并；ALVTM 在视觉塔之后进行语言引导合并 | 合并；免训练 | Gemma3-4B/12B；OKVQA、AI2D、SQA、TextVQA；4B 联合方法 7.91→5.12 TFLOPs，OKVQA 53.67→53.47；不是端到端实测时延 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-evoprune.md]] | Algorithm 1 在 Attention 与 MLP 之间 ScoreGuidedMerge；默认隔层执行，相似性、多样性与关键 token 保护决定配对 | 名称为 pruning，核心是合并；免训练，arXiv v1 | LLaVA-1.5-7B、LLaVA-Video-7B；图像和 Video-MME/MVBench/LongVideoBench；摘要称 VideoMME 2× 推理、性能下降小于 1%；尚未复现 |

### 边界与优先阅读

- **纯剪枝最近邻：** FlowCut 和 METEOR；**文本条件 ViT 内选择：** QuietPrune。前两者 encoder 阶段主要依赖视觉信号，METEOR 的文本自适应策略主要在 LLM 阶段。
- **合并最近邻：** iLLaVA、MustDrop、AdaptMerge、EvoPrune。它们符合“ViT 出口之前减少 token”但不应作为纯 drop 方法介绍。FiCoCo-V 位于二者之间，保留被筛 token 的部分信息。
- **VScan 不纳入此严格子集：** 原文 §4.1 的 global scan 使用视觉输出层（LLaVA 为倒数第二层）特征，选择/合并后送入 LLM；§4.2 才是 LLM 中层剪枝。原表“视觉编码阶段”过于宽泛，不代表缩短前面 ViT block 的计算。
- VisionZip、LLaVA-PruMerge、DivPrune 常规设置是视觉塔输出侧选择；FastV、SparseVLM 常规设置是 LLM 内选择。仅引用视觉 attention 或中间层 attention，不能证明剪枝发生在该层。
- 解释性比较（综合判断）：FlowCut 的信息流代理、熵、累计重要性消融和 QuietPrune 的 query relevance 比单张热图更有机制依据；仍不足以证明所选集合是生成答案的因果充分证据，需删除/恢复等干预验证。

检索与版本边界见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md]]；只核公开可访问代表作，不声称穷尽所有早剪工作。

| 路线 | 决策输入 | 决策位置 | 训练 | 可解释信号 | 主要边界 |
|---|---|---|---|---|---|
| Dyna-ViT | patch embedding 的能量、边缘、熵等显著性代理 | 首个视觉 block 前 | 不需要 | 可直接映射回图像 patch，但与最终任务弱耦合 | 小字、低对比危险证据可能被删 |
| Patch Slimming | 深层 token 对最终输出的影响，反向指导浅层 | 视觉编码器内部、多阶段 | 微调 | 可看作 teacher-guided patch importance | 深层教师只在训练或打分时提供依据；原任务为纯视觉 |
| METR | 浅层辅助出口及早期 `[CLS]` attention | 视觉编码器内部 | 多出口训练与自蒸馏 | 每层出口可测任务充分性 | 已覆盖“让任务压力前移”，但不是多模态安全证据 |
| QuietPrune | 文本 query 映射成视觉 `[Q-CLS]` 后的 attention | ViT 早层 | 训练轻量 adapter | query-conditioned 空间 relevance | attention 仍可能有位置偏差，且安全 policy 未验证 |
| X-Pruner | 类别条件下结构单元对分类的贡献 mask | 结构化权重/头/矩阵剪枝 | 端到端训练 | 类别级贡献显式进入 mask | 不是 token 剪枝，也不构成样本级因果解释 |

# “解释性强”应如何分级

1. **可视化相关性：** 将保留 token、halting depth 或 attention 映射回 patch。直观但不能证明删掉该 token 会改变输出。
2. **表示可解码性：** 用 probe 检查浅层 token 是否编码对象、颜色、OCR 或图像特有语义。EmbedLens 对 sink/dead/alive token 的分析属于这一层；它支持“浅层已有可用语义”，但 probe 可解码不等于主模型实际使用。
3. **输出因果效应：** 删除或干预单个 token，测量目标输出概率变化。Information Horizon 工作使用这类定义研究跨层 token 信息，较接近忠实的重要性证据；仍需注意单 token 删除不能完整刻画 token 间交互。
4. **充分集与稳定性：** 检查所选 token 集在反事实、遮挡、压缩率、模型和任务变化下是否仍保持输出，并与随机集、互补集和恢复实验比较。这比一张注意力热图更适合作为剪枝解释性的主评测。

# 对多模态安全判别的设计判断

浅层 selector 应同时输入图像浅层特征与文本/政策表示；只用通用视觉显著性不足以识别“低显著度但政策关键”的 patch。推荐把解释目标定义为政策条件下的**因果充分 token 集**，而不是“看起来落在物体上的热图”。训练期可用完整模型产生 token/区域干预效应，蒸馏给浅层 scorer；推理时只保留浅层 scorer 和真实缩短后的 token 序列。

一个最小可证伪方案是：在视觉第 $1$、$2$、$4$ 层分别接相同容量 scorer，固定保留预算 $K$，比较无参显著性、attention、普通监督 scorer 和因果效应蒸馏 scorer。除准确率外，必须报告固定 FPR 下的安全召回、small/OCR/低对比子群、selector-inclusive 端到端时延，以及 mask 与遮挡/删除效应之间的 rank correlation。若浅层因果 scorer 不优于简单显著性或直接低分辨率输入，则没有必要承担视觉编码器重训成本。

# 证据边界

- 现有强证据主要来自图像分类和通用 VLM，不直接证明安全政策条件下的浅层选择有效。
- attention、mask 或空间对齐只提供相关性解释；因果删除更强，但仍受离群输入和特征交互影响。
- 浅层重要性可能随后续层发生反转；不可逆 early drop 应与 token bypass、保底全局覆盖或恢复机制比较。
- 动态 token 数只有在张量真实缩短且 kernel/batching 支持时才会转化为时延收益。

关联：[[LLM-Wiki/research/visual-token-pruning/landscape.md]]；[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。
