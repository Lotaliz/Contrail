---
id: text-guided-visual-token-pruning-generative-guard
type: synthesis
title: "生成式多模态 Guard 的文本指导视觉 Token 剪枝"
tags: [research, multimodal-safety, vision-language-model, visual-token-pruning, efficient-inference]
project_id: safety-classifier-compression
sources: [paper-chen-2024-fastv, paper-zhang-2025-sparsevlm, paper-chen-2025-safewatch, paper-zhang-2026-trimtokenator, paper-gao-2026-quietprune, paper-liu-2026-crisprune, paper-zhu-2026-hawk, paper-li-2026-transprune, paper-chen-2026-priortr, paper-ding-2026-et-prune, paper-sun-2026-hi-lo-prune]
status: active
created: 2026-09-14
updated: 2026-09-14
---

# 生成式多模态 Guard 的文本指导视觉 Token 剪枝

## 范围

检索截止 2026-09-14。只把视觉 token 与文本 token 拼接进入同一 decoder-only LLM、并自回归生成结果的 MLLM 作为核心对象。文本用于 query/policy 条件化视觉选择，但文本 token 本身不剪。CLIP、ViLT/METER 和 `[CLS]` 分类模型仅作为机制来源。

检索站点包括 CVF、PMLR、ACL Anthology、ICLR Proceedings、arXiv 与作者仓库；关键词包括 `text-guided visual token pruning MLLM`、`query-guided early token pruning Qwen3-VL`、`instruction-guided attention visual token reduction`、`policy-aware pruning multimodal guard`、`prior-corrected text visual attention`。公开检索未命中不构成不存在性证明。

## 结论

文本指导视觉剪枝已经从“直接平均文本—视觉 attention”发展出五类更可靠的方法：视觉塔内提前注入 query、筛选有效文本/attention head、修正模型先验与位置偏置、联合相关性与视觉覆盖、按样本证据密度动态分配预算。对安全 Guard，最值得组合的是 SafeWatch 的 policy-conditioned 目标、QuietPrune 的早剪位置、PriorTR/HAWK 的 attention 校正、CrisPrune/TrimTokenator 的覆盖与多样性，以及 SparseVLM/Hi-Lo 的被删信息回收。

不存在跨任务统一最优 selector。短安全判别的优先级应是：先证明真实端到端收益，再守住低显著度危害证据、OCR、小目标、否定和跨模态组合关系；不能只比较平均 VQA accuracy。

## 方法家族

### 1. 浅层 LLM attention 直接打分：简单基线

FastV 复用浅层 LLM 中从文本 token 到视觉 token 的 attention，聚合后 Top-k 删除视觉 token。优点是 training-free、实现简单；缺点是视觉塔和若干 LLM 层已经执行，且 attention 可能有位置偏置、head 差异与 FlashAttention 兼容问题。它适合作为最低复杂度基线，不适合作为安全最终方案。

### 2. 让文本指导更干净：rater、head 与 prior 校正

- SparseVLM 只选与视觉相关的文本 token 作为 raters，减少标点、模板和无关文本对视觉评分的污染；再做层级自适应预算和 token recycling。
- HAWK 不再把 attention heads 等权平均，而以 head importance 加权 text-guided attention。
- PriorTR 将 instruction-conditioned posterior 与 null-probe 得到的模型先验区分，保留因当前 query 额外变得重要的视觉 token。
- TransPrune 将 instruction-guided attention 与视觉 token 的层间表示变化结合，防止单一 attention 漏掉仍在发生语义更新的 token。

这一类最适合对现有 Qwen-VL/LLaVA forward 做 training-free 或低改动增强，但多数不能节省视觉编码器成本。

### 3. 将 query 前移到视觉编码器：真正减少前段计算

QuietPrune 用轻量 adapter 把文本 query 逆映射到视觉域形成 `[Q-CLS]`，在 ViT 内对相邻 token 分组，用 query—visual attention 早剪并聚合。它直接覆盖 Qwen3-VL/InternVL3，能同时减少后续视觉塔和 LLM prefill；代价是需要训练 adapter，并改变视觉塔前向。

如果目标包含视觉编码器成本，这比 FastV/SparseVLM 式 LLM 层内剪枝更有吸引力。对安全政策，不能只把 query 换成 policy；必须证明浅层视觉表示已经能表达 OCR、小目标和组合危害。

### 4. 相关性 + 覆盖/多样性：防止视野过窄

- CrisPrune 联合 text relevance、intrinsic visual saliency 与多样性，明确修复文本指导方法只保留狭窄焦点的问题。
- TrimTokenator 用跨模态互信息保留文本对齐 token，再最大化视觉 token 间差异，减少重复而维持覆盖。
- Hi-Lo Prune 先将待删 token 的信息合并到保留 token，再删除，降低硬删除的信息断裂。

这类方法对安全 Guard 特别重要，因为判定通常需要“对象 + 行为 + 背景/关系”，政策最相关的局部区域不一定构成充分证据集。

### 5. Policy/evidence-aware 动态预算：最贴近安全场景

- SafeWatch 将每个安全 policy chunk 作为查询，计算 policy—video relevance，为不同政策选择视觉 Top-k，并配合 pruning-aware training 生成多标签判定和解释。
- ET-Prune 面向 OCR/text-rich 场景，从 decoder-side query-key block 获取问题条件证据，保护文字区域，并根据证据不确定性与空间密度预测样本级 token floor；在 Qwen3-VL-8B 上提供预印本直接证据。

固定保留率不适合安全数据：一个大面积明显违规对象可以低预算处理，而一个角落小字、隐晦手势或图文组合危害需要更高预算。动态预算的目标应是风险和证据充分性，不是平均 token 数最小。

## 统一比较

| 方法 | 文本信号 | 剪枝位置 | 预算 | 信息回收/覆盖 | 训练 | 当前安全价值 |
|---|---|---|---|---|---|---|
| FastV | 浅层文本→视觉 attention | LLM 层内 | 固定 | 无 | 否 | 简单负载基线 |
| SparseVLM | 视觉相关文本 raters | LLM 层内渐进 | rank-based 自适应 | token recycling | 否 | 适合迁移 rater 与回收 |
| HAWK | head-weighted text attention | LLM 层内 | 配置式 | 间接 | 否 | 修正 head 等权假设 |
| PriorTR | query posterior − model prior | LLM attention | 配置式 | 无 | 否 | 区分安全政策增量关注与模型先验 |
| TransPrune | instruction attention + token transition | LLM 层内渐进 | 配置式 | 以 transition 保护 | 否 | 比单 attention 更稳健 |
| QuietPrune | query→视觉域 `[Q-CLS]` | ViT 早层 | 多档 | 分组聚合 | 轻量 adapter | 同时省视觉塔与 LLM，Qwen3-VL 强基线 |
| CrisPrune | text relevance | LLM 前/视觉侧选择 | 配置式 | intrinsic saliency + diversity | 否 | 保护背景与关系证据 |
| TrimTokenator | 跨模态互信息 | LLM 输入侧 | 自适应视觉选择 | 显式视觉多样性 | 否 | 相关性—冗余联合 |
| SafeWatch PAP | 每条安全 policy | LLM 前视频 token 选择 | policy-wise Top-k | 多政策并行覆盖 | 是 | 唯一直接生成式安全 Guard 正例 |
| ET-Prune | query-conditioned evidence | LLM 中层渐进 | 样本级 token floor | OCR region 保护 | 否 | text-rich/Qwen3-VL 近邻；预印本 |

## 面向 Qwen3-VL 安全 Guard 的推荐组合

最稳妥的最小方法不是简单 attention Top-k，而是一个**政策条件化、覆盖保护、风险自适应、可回收**的视觉 selector：

$$
s_i = \alpha s_i^{policy}
+ \beta s_i^{intrinsic}
+ \gamma s_i^{novelty}
+ \delta s_i^{transition}
- \eta s_i^{prior},
$$

其中 $s_i^{policy}$ 表示 policy/user text 对视觉 token 的增量需求，$s_i^{intrinsic}$ 保护视觉自身显著信息，$s_i^{novelty}$ 保持空间/语义多样性，$s_i^{transition}$ 保护仍在发生表示变化的 token，$s_i^{prior}$ 用于校正任务无关 attention prior。该公式是跨论文综合假设，不是已有论文原式。

选择过程再加入硬约束：

- 每个空间窗口最低配额；
- OCR、人物/手部、小目标及安全敏感 detector region 的最低保留；
- policy 类别之间取 union 或带覆盖约束的 set selection，而不是只保留最高分政策；
- 被删 token 合并为少量 residual/context tokens；
- 低置信、图文冲突、证据分散时提高预算或回退 full tokens。

## 必要实验

1. 基线：Random、uniform pooling、FastV、SparseVLM、QuietPrune、CrisPrune/TrimTokenator、SafeWatch-style policy Top-k。
2. 位置：视觉塔内早剪、LLM 前一次剪、LLM 第 2/8/16 层渐进剪；分别报告视觉塔和 prefill。
3. 信号消融：纯 policy relevance、加 head weighting、加 prior correction、加 saliency/diversity、加 token recycling。
4. 安全切片：image-only、text-only、图文组合 unsafe、否定/引用、OCR、小目标、多个分散证据、hard benign。
5. 指标：fixed-FPR unsafe recall、unsafe-to-safe flip、worst-group recall、ECE、归因 sufficiency/comprehensiveness、selector-inclusive P50/P95 与 time-to-verdict。

## 证据边界

SafeWatch 是直接安全证据但集中于视频；QuietPrune、HAWK、TransPrune 等主要是通用 VQA/OCR；PriorTR 与 ET-Prune 为预印本。文本指导 attention 的 benchmark 优势不能自动证明其保留了因果安全证据。当前最有价值的新意应落在政策条件化证据组、尾部风险约束、被删证据回收与不确定性回退，而不是“首次使用文本指导视觉剪枝”。

关联：[[LLM-Wiki/research/safety-classifier-compression/autoregressive-multimodal-guard-token-pruning.md]]；[[LLM-Wiki/research/safety-classifier-compression/joint-visual-text-token-pruning.md]]；[[LLM-Wiki/research/visual-token-pruning/region-rationale-guided-safety-token-pruning.md]]。
