---
id: note-2026-chen-otprune
type: paper-note
title: "OTPrune: Distribution-Aligned Visual Token Pruning via Optimal Transport"
tags: [paper-note, research, vision-language-model, visual-token-pruning, training-free]
source_id: paper-chen-2026-otprune
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-09
updated: 2026-09-09
---

# OTPrune: Distribution-Aligned Visual Token Pruning via Optimal Transport

来源：[arXiv 2602.20205v3](https://arxiv.org/abs/2602.20205)；原文标注 CVPR 2026。精读范围：§1–6、附录 A–C、图 1–4、表 1–4。未运行代码或复现实验。

## 问题、假设与目标

论文从 training-free one-shot token pruning 出发。理想目标是在文本 $T$ 下选择子集 $C$，使剪枝模型输出接近完整模型：

$$
\min_C \mathcal L(f(T,V_C),f(T,V)).
$$

由于推理时没有标签，也不愿增加训练，OTPrune 用视觉 token 分布对齐作为代理。核心假设是：若保留 token 的经验分布在二阶几何上接近完整 token 分布，则其下游任务表现更可能保留。

## OTPrune 如何处理“特征恢复”

### 1. 它不重构被删 token

OTPrune 的输入是视觉编码器和 projector 已输出的 token $V\in\mathbb R^{m\times d}$。算法只选择 $k$ 个原 token 并原样送入 LLM；没有 token merging、解码器、特征预测或教师蒸馏。被删除 token 的内容不会在推理或训练中恢复。

因此论文中的“distribution alignment”是子集覆盖准则，不是语义重构。它衡量保留集合能否近似完整集合的全局统计，而不是让少量 token 逐一复原完整的 $m\times d$ 特征。

### 2. 用高斯二阶统计近似 Wasserstein 距离

§3.2 将完整和保留 token 分别视为均匀经验分布 $P,Q$，目标是最小化平方 2-Wasserstein 距离。§3.3 先对特征维度做单位方差归一化，再用零均值高斯近似 $P$ 与 $Q$，从而把 OT 问题化为协方差几何的闭式距离。

为避免直接求解组合优化，论文进一步用 log-determinant 下界构造子模目标：

$$
\max_C \log\det\left(I+\widetilde\gamma V_CV^\top VV_C^\top\right).
$$

直观上，$VV^\top$ 表示完整 token 之间的相似性，选中的行若能覆盖完整集合的不同方向，log-det 会增大。实现先计算 Gram 矩阵，再用 Cholesky 更新做贪心选择；论文给出的选择复杂度为 $O(mk^2)$，另有计算 Gram 的 $O(m^2d)$ 成本。

该目标具有单调子模性质，贪心对这个代理目标有 $1-1/e$ 近似保证；保证不直接适用于原始任务损失，也不等价于精确 2-Wasserstein 最优子集。

## 实验设置与结果

- §5.1 使用 LLaVA-1.5-7B/13B、LLaVA-1.6-7B 与 CLIP 视觉编码器，在 11 个多模态基准上评估；单张 A100 80GB、batch size 1。
- 基线包括 FastV、SparseVLM、VisionZip、PruMerge、DivPrune 等 training-free 方法。
- 表 1：LLaVA-1.5-7B 在约 9.8% token 保留率下，OTPrune 与 DivPrune 的计算量都约为完整模型的 15.63%，OTPrune 平均排名 2.36，DivPrune 为 3.23；但 POPE F1 上 OTPrune 为 79.59，低于 DivPrune 的 86.02，说明通用分布覆盖不保证幻觉/安全相关任务最优。
- LLaVA-1.6-7B 的报告计算量约为完整模型的 10.79%，平均排名 1.23。
- 表 2 在合成数据上比较 OT 目标的 win rate 和 optimality gap，证明的是代理选择目标，不是下游安全召回。
- 超参数 $\gamma$ 在约 0.01 附近较稳健。
- 论文报告 TFLOPs，没有报告包含 Gram 构造和贪心选择器的端到端 P50/P95 时延。

## 局限与证据边界

1. 剪枝发生在完整视觉编码器和 projector 之后，不能节省视觉塔计算。
2. Gram 构造为 $O(m^2d)$，高分辨率下可能抵消 LLM 侧收益；论文未给 selector-inclusive latency。
3. 零均值高斯和二阶协方差只保留有限统计，忽略位置、局部纹理、高阶关系及多模态条件。
4. 所有 token 使用均匀质量，不看文本查询、安全策略或风险证据；附录 C 已把 attention 或 task-specific cross-modal alignment 的非均匀质量列为未来方向。
5. POPE 结果显示分布保持与幻觉指标可能不一致，不能把平均基准提升外推为复杂安全样本召回提升。

## 对视觉+文本安全判别的迁移价值

### 直接作为在线剪枝器：价值偏低

它位于视觉塔之后，不能满足“减少编码器层数和早期 patch 数量”的首要时延目标。固定短标签输出时，LLM token 节省有限；Gram 和贪心成本还可能成为新瓶颈。其均匀、文本无关的目标也容易删除面积小但安全关键的文字、手势或跨区域关系。

### 作为强基线、正则项或离线教师：价值高

OTPrune 适合回答“保留 token 是否覆盖完整视觉集合的二阶几何”这一问题。可在训练期用它产生子集或覆盖分数，监督一个浅层的线性/小 MLP 选择器；也可把 log-det 或 covariance/Wasserstein 距离作为辅助正则，与安全 logit、证据图和关系恢复共同训练。推理时移除 OT 求解，只执行固定 $K$ 的低成本选择器。

### 不能单独构成的创新点

把均匀 OT 改成 attention 或 policy-weighted OT 已在附录 C 被明确预告，单独做这一改动创新性有限。更强的研究问题应是：安全证据权重能否由反事实标签翻转或 worst-group 风险学习，而不是由普通 attention 给出；以及这种训练期分布约束能否蒸馏到早层选择器，在不运行在线 OT 的情况下保持复杂安全证据。

## 推荐与 ETC 的组合方式

ETC 与 OTPrune 解决不同层面：ETC 学习“少量 token 能否预测任务相关稠密表征”，OTPrune 约束“少量原 token 是否覆盖完整集合的二阶几何”。可联合为训练期多目标：

$$
\mathcal L=\mathcal L_{safety}+\lambda_1\mathcal L_{sufficiency-recovery}
+\lambda_2\mathcal L_{evidence-weighted-OT}+\lambda_3\mathcal L_{calibration}.
$$

学生从视觉塔极浅层输出固定 $K$ token；训练期教师使用完整分辨率和完整深度。恢复器与 OT 正则都在推理时删除。关键消融应分开比较：仅 ETC 式恢复、仅 OT、二者联合、普通 MSE/Gram 对齐、随机/attention/因果安全权重，并同时报告视觉塔、选择器、prefill 的真实时延和复杂样本召回。

## 未决项

- TODO：代码级确认 Gram/Cholesky 的 GPU 实现、数值稳定处理及选择器实测时间。
- TODO：验证早层特征上的 OT 子集是否与后层安全证据一致；现有论文只在 projector 后 token 上验证。
- TODO：用非均匀安全质量时，与论文附录提出的 task-specific weighting 做清楚排重。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与研究判断分开；未通过本地实验验证。
