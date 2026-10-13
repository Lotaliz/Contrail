---
id: note-2026-liang-vip-router
type: paper-note
title: "Beyond One-Size-Fits-All: Sample-Adaptive Strategy Routing for Vision Token Pruning in MLLMs"
authors: [Haiji Liang, Pengfei Zhou, Zhenglin Wan, Wei Wang, Yang You, Wangbo Zhao]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-10346
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, adaptive-routing, multimodal-llm, cost-aware-inference]
status: active
created: 2026-09-20
updated: 2026-10-13
---

# VIP-Router：按样本选择视觉剪枝策略

## 书目信息与阅读边界

来源：[arXiv 2609.10346v1](https://arxiv.org/abs/2609.10346)，首次提交于 2026-09-09，许可为 CC BY 4.0。精读 26 页 PDF 的方法、主实验、限制、算法与数据/训练附录。阅读原件：[PDF 原文](https://arxiv.org/pdf/2609.10346v1)。论文代码标为“will be released soon”，本轮没有可固定的代码 revision，也未运行模型。

## 问题设定

论文观察到：按 benchmark 平均分选出的最佳剪枝方法，在许多单样本上并非最佳。VIP-Router 不设计新的 token scorer，而是在给定保留比例下，从 `{Full, FastV, VisionZip, PruMerge+, DART}` 中选择一个策略。

主实验限定在 VTC-Bench Group A：完整 token 推理正确、等比例下采样错误。对压缩方法成本记为保留率 $r$，Full 成本为 1；效用为：

$$
U_i(s,r)=a_i^s-c(s,r).
$$

因此在 Group A 中，正确压缩策略的效用为 $1-r$，Full 为 0，错误压缩策略为 $-r$。这使 Full 成为有成本的回退，但也意味着数据已经排除了 full model 本身失败的样本。

## 方法与训练

冻结的 CLIP ViT-B/32 和文本 encoder 提供 49 个视觉 patch、全局视觉向量、文本 token 与全局文本向量。文本 token 对视觉 patch 做一次四头 cross-attention，取 EOS 位置作为 query-conditioned visual summary。最终输入为全局文本、全局视觉、$r$、$\log r$ 与交互向量；两层 MLP `1538→512→5` 回归五个候选策略的效用。

训练标签来自离线运行每个候选策略后的正确性。各策略效用按训练集统计量分别标准化，使用 element-wise Huber loss。仅训练投影、cross-attention、LayerNorm 与 MLP；preview encoders 和 MLLM 冻结。默认模型有 1,382,405 个可训练参数，约为 Qwen2-VL 的 0.017%，但另加载约 151.28M 冻结 CLIP 参数。算法 1–2 明确推理时先做 preview，再选择策略，最后只运行一次被选中的 MLLM 路径。

单个 router 通过输入 $r$ 支持 0.25、0.1111、0.0625、0.04、0.01 五个保留率，不必为每个比例训练独立模型。训练使用 AdamW、学习率 $10^{-3}$、batch 256、最多 50 epoch、五个随机种子；H200、FP32（附录 A.3，PDF 第 20–21 页）。

## 数据、指标与主要结果

数据由 VTC-Bench 已发布的 Qwen2-VL-7B 推理标签构造，共 33,091 个 record–ratio 样本，来自 12,919 个唯一 image–question record；按 record 做 70/15/15 固定划分。相同 record 的不同比例不会跨 split，但同一底图若配不同问题和 document ID，仍可能跨 split，论文明确指出并非 image-disjoint。

指标包括 Group A accuracy、实际 token cost、utility 与 OHR。VIP-Router 可选 Full，所以实际 token cost 高于压缩候选的目标 $r$。Per-Sample Oracle 使用测试标签，只是不可达上界。

### 主结果

表 1–2（PDF 第 7 页）显示，五个 reduction ratio 下 VIP-Router 的 accuracy 为 66.91/57.65/49.62/44.29/37.48%，对应 Best Fixed 为 57.54/47.94/39.73/34.91/25.82%。跨比例平均 accuracy 从 40.35 提到 51.19，作者报告相对提升 26.9%。平均 utility 从 30.88 提到 37.68，相对提升 22.0%；OHR 为 17.6%–31.7%，宏平均 26.5%。

Full 只占 3.48%–6.66% 的选择。作者给出的最坏情形界表明，Full 回退平均最多解释 0.41 utility 点，即观测增益的 6.1%；大部分收益来自在多种压缩准则间路由。附录逐任务表显示 40 个 benchmark–ratio 组合中 30 个为最高压缩结果，但不是全部组合。

### 计算与迁移

图 3 把 preview 与被选策略的计算都计入 FLOPs；VIP-Router 在约 4.5 TFLOPs 以上的大部分范围保持更好的 accuracy–compute 前沿。99% reduction 时因 Full 回退变多，匹配计算下竞争力下降。论文没有提供 selector-inclusive wall-clock、TTFT 或并发吞吐，因此只支持 FLOPs 口径的效率主张。

对 LLaVA-1.5、LLaVA-OneVision、InternVL3、Qwen2.5-VL 分别重建数据并训练 backbone-specific router 后，utility 均高于 Best Fixed，但增益从 0.55 到 5.06，差异很大。迁移到未训练 benchmark 时仍为正增益，SEED-Bench Image 仅提高 0.07 utility。限制部分进一步报告：把一个 source backbone 的 router 零样本搬到新架构通常失败，常低于静态策略。因此“跨 backbone 有效”依赖目标 backbone 标签与训练，不是策略零样本迁移。

## 消融与误差

全局视觉特征比纯文本特征强；五个比例独立 router 的 utility 为 38.07，一个共享比例条件 router 为 36.96。加入保留空间结构与 text-to-vision cross-attention 后恢复到 38.09（表 5，PDF 第 10 页）。原生 MLLM 特征可以消除额外冻结参数，但 utility 略降；不同 preview encoder 的差异只做单次运行，不能严格排名。

路由误差分析区分策略 argmax 不同与真实 utility regret。约 28.9% 的 argmax mismatch 为零 regret；高 margin mismatch 占不一致的 40.9%，却贡献 63.5% regret（表 9）。这说明“路由分类准确率”本身不是最重要指标，代价加权错误才决定价值。

## 局限与证据边界

- 结果只覆盖经过成功条件筛选的 Group A，不能代表未过滤线上分布，也不包含 full model 失败样本。
- 离线标签要求为每个样本运行所有候选策略，新增策略或 backbone 后需重新产生成本高昂的监督。
- record-disjoint 并非 image-disjoint，可能高估同底图跨问题的泛化。
- 默认 router 仍需外部 CLIP preview；0.017% 只指可训练参数，不是总加载参数或实际延迟。
- Full 的正确性在 Group A 由构造保证；现实中 Full 也可能错误，效用设计需重做。
- 跨 backbone 的零样本策略迁移失败，且论文未报告真实 wall-clock。

## 对当前项目的影响

VIP-Router 提供了重要的系统层视角：不存在对每个样本都最优的固定剪枝准则，完整路径应作为可计成本的候选。当前安全项目可将候选扩展为不同证据保留策略、不同浅层退出深度和 Full Guard，并以 false-negative 成本、延迟和资源约束定义效用。

但直接迁移会有三处根本变化：Group A 的“full 一定正确”必须改成真实安全标签；普通 accuracy 要替换为对 unsafe 漏报更敏感的风险函数；preview 本身的视觉计算必须计入端到端成本。该路由器更适合作为策略选择基线或实验上界，不证明浅层安全出口可行。本轮不修改正式 motivation。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md|方法比较]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|固定方法内的预算适配]]。

## 证据定位与待验证项

- utility、preview 与比例条件路由：§3、图 2，PDF 第 4–6 页。
- 数据划分、主结果、计算与跨模型/任务结果：§4、表 1–5、图 3，PDF 第 6–10 页。
- Group A 与跨 backbone 限制：Limitations，PDF 第 11 页。
- 算法、33,091 样本、训练配置与详细结果：附录 A.2–A.5，PDF 第 19–26 页。
- TODO：代码发布后固定 revision；image-disjoint 重划分；未过滤分布；wall-clock；安全代价与策略更新。均未执行。
