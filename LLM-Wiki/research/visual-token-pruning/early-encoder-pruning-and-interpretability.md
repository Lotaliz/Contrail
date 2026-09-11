---
id: early-encoder-pruning-and-interpretability
type: synthesis
title: "视觉编码器浅层剪枝与可解释性证据"
tags: [research, visual-token-pruning, vision-language-model, representation-probing, efficient-inference]
project_id: visual-token-pruning
sources: [paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-yu-2023-x-pruner, paper-fan-2026-visual-token-semantics, paper-wang-2026-information-horizon]
status: active
created: 2026-09-10
updated: 2026-09-10
---

# 结论

在视觉编码过程中用浅层特征决定 token 去留是可行且已有正式先例的；决策甚至可以发生在首个 Transformer block 之前。需要区分三种位置：pre-encoder patch 选择、视觉编码器内部的渐进剪枝，以及完整视觉塔之后的 VLM token 压缩。只有前两种能够减少视觉塔本身的计算。

是否需要重训取决于选择信号。无参图像显著性可以直接用于 pre-encoder 选择；复用已有 attention 也可能免训练或仅微调。若要让选择依赖文本 query、政策或安全判别，则通常需要轻量 adapter、辅助出口、蒸馏或联合训练，使浅层表示提前携带任务相关信号。Patch Slimming 的深层到浅层监督、METR 的多出口压力与自蒸馏、QuietPrune 的 query-to-vision adapter 分别提供了这三类先例。

# 方法谱系

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

关联：[[LLM-Wiki/research/visual-token-pruning/landscape.md]]；[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。
