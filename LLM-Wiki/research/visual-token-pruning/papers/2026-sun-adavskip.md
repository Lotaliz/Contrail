---
id: note-2026-sun-adavskip
type: paper-note
title: "AdaVSkip: Adaptive Visual Token Skipping Across Layers For Efficient MLLMs Inference"
authors: [Yuyao Sun, Tao Deng, Shuang Li, Deqing Wang]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-15131
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, layer-skipping, adaptive-routing, efficient-inference]
status: active
created: 2026-09-20
updated: 2026-10-20
---

# AdaVSkip：跨层视觉计算的自适应跳过

## 书目信息与阅读边界

来源：[arXiv 2609.15131v1](https://arxiv.org/abs/2609.15131)，首次提交于 2026-09-14，许可为 CC BY 4.0。精读 12 页 PDF 的 §3–5、图 2–4、表 1–6。阅读原件：[PDF 原文](https://arxiv.org/pdf/2609.15131v1)。当前 PDF 在参考文献后结束，正文声称“附录”给出加速 profiling，但下载版本未包含对应附录；训练超参数与硬件也未完整报告。没有本地复现，以下数字均为作者报告。

## 方法定位

AdaVSkip 处理的是纵向冗余：不删除 token，而是让全部视觉 token 在某些 LLM self-attention 或 MLP 模块中跳过计算。文本 token 始终执行所有模块。它与水平 token compression 正交，可组合使用。

对每层 $l$，两个独立 router 决定视觉 token 是否参与 self-attention 与 MLP。router 输入只用 prompt 文本 hidden state：最后一个文本 token 与文本均值拼接；不含答案 token 或 padding。推理阈值为 0.5，路由只发生在 prefill，生成阶段不再决策。

当 attention gate 为 0 时，视觉 hidden state 原样旁路，文本只做 text-only attention；视觉 token 也不作为文本 attention 的 key/value。这比 ShortV 仅冻结视觉更新、仍保留视觉 KV 更激进。MLP gate 为 0 时，视觉 hidden state 跳过 MLP，文本正常更新。所有视觉 token 共享同一模块级 gate，所以这不是空间证据选择。

## 两阶段训练

### Stage I：必要性监督

对每个训练样本先以 teacher forcing 跑 full model，再逐个跳过 $2L$ 个 `{layer, attention/MLP}` 模块。以回答位置输出分布的平均 KL 定义模块必要性：

$$
s_c^l(x)=\frac{1}{T}\sum_{t=1}^{T}D_{KL}\!\left(P_{full}(\cdot\mid x,y_{<t})\;\Vert\;P_{-(l,c)}(\cdot\mid x,y_{<t})\right).
$$

attention 与 MLP 分开排序，选择累计必要性达到阈值 $\tau_c$ 的最小模块集合为 keep target。目标因样本而异。router 用 BCE 拟合这些标签，并通过 straight-through estimator 同时接受下游 LM loss；backbone 冻结。

这一 profiling 每个样本需要 full 路径加逐模块干预，离线成本很高。正文称有加速变体且性能接近，但当前 v1 PDF 没有可核对的附录细节，主结果使用 full profiling。

### Stage II：策略细化

Stage II 从每个 Bernoulli router 采样一组完整路径，用冻结 backbone 生成答案。正确性 reward 是标准化后与真值精确匹配的 0/1。为防止 RL 退回保守的高计算路径，skip-consistency reward 惩罚 attention/MLP keep ratio 偏离 Stage-I 样本级参考。作者用 GRPO 式组内标准化 advantage 更新 router。

该奖励适合短答案 benchmark，但对开放生成、多答案或安全判别的代价结构没有直接保证。

## 实验与主要结果

模型为 LLaVA-1.5-7B、LLaVA-NeXT-7B、Qwen3-VL-8B-Instruct。前两者在 VQAv2、GQA、TextVQA、POPE、MME、MMBench、SEED、MMStar 上评测；Qwen 使用 ChartQA、HallusionBench、AI2D、DocVQA、InfoVQA 等。Avg 是各任务相对 vanilla 的平均百分比。

### 纵向跳过

LLaVA-1.5 表 1（PDF 第 7 页）：AdaVSkip 在 `K=16/20/24` 设置下使用 52.0%/45.2%/32.5% 的原始 FLOPs，保持 100.0%/99.0%/95.1% 平均相对性能。与 Stage-I-only 相比，完整方法在三档均更高，但平均值掩盖单任务变化。

LLaVA-NeXT 的 `K=16` 使用 46.8% FLOPs，平均相对性能为 100.4%；Qwen3-VL `K=18` 使用 51.4% FLOPs，保持 98.6%。高于 100% 表示跨任务相对比率平均略高于 vanilla，不等于每个任务或统计显著改善。

### 与水平压缩组合

LLaVA-NeXT 在 5.6% 等效视觉 token 预算下，CDPruner 单独使用 9.7% FLOPs、94.5% 平均性能；加 AdaVSkip 后为 8.8% FLOPs、97.2%。Qwen3-VL 在 10% token 预算下，VisionZip 单独为 13.9% FLOPs、71.7%，组合为 13.5% FLOPs、85.5%；ChartQA、DocVQA、InfoVQA 改善尤其大。这里证明的是作者实现中的组合互补，不表示所有剪枝器与跳层器都可叠加。

### 实测效率

表 6（PDF 第 9 页）只报告 LLaVA-NeXT 在 MME 上的延迟。vanilla prefill/E2E 为 161.16/194.32 ms；AdaVSkip 为 77.10/109.36 ms，即 2.09×/1.78×，MME 从 1519.0 到 1535.4。CDPruner + AdaVSkip 为 26.40/64.69 ms，即 6.10×/3.00×，MME 1473.9。论文没有在该表附近给出硬件、batch、解码长度或计时细节，不能与其他论文延迟直接横比。

## 消融与自适应证据

模块级 router 比整层 router 在更低 FLOPs 下高 0.4 平均百分点。Stage-I 加入 CE 和样本特定 target 后提升；Stage-II 无 SCR 虽达 100.0%，FLOPs 回升到 53.5%，加入 SCR 将其压到 52.0%且均值不变（表 4）。

固定每样本跳过 50% 模块时平均为 98.6%，自适应预算为 100.2%；TextVQA 平均跳过 36.1%，POPE 为 62.2%。保持每样本 skip count、但按全局固定必要性顺序选择模块的 Count-Matched Prior 为 98.7%，说明收益同时来自“跳多少”和“跳哪里”（表 5）。这些是单一设置的平均结果，未报告多 seed 或置信区间。

## 局限与证据边界

- 不改变 token 数，也不缩短序列；它减少的是视觉 token 在 LLM 各模块中的参与，KV/cache 和 attention 语义与真正剪枝不同。
- router 输入来自已经经过前层计算的文本状态，无法节省视觉塔；早层路由的文本状态尚未充分融合视觉证据。
- full necessity profiling 极昂贵，v1 对加速近似、训练数据规模、RL 组大小、关键超参数与硬件说明不足。
- Stage II 的 exact-match reward 对生成式基准敏感，未覆盖安全漏报或概率校准。
- 延迟只在单个模型/基准表中给出，计时协议不完整；FLOPs 不能代替普遍端到端加速。
- 所有视觉 token 共同跳过一个模块，不能保护某个局部高风险区域。

## 对当前项目的影响

AdaVSkip 是当前“困难分支继续、简单分支少算”的纵向近邻。它表明 self-attention 与 MLP 的视觉必要性在层间、任务间、样本间不同，固定前缀退出会错过后段有用模块；因此如果当前方案允许动态路径，应把“跳过多少”与“在哪些模块跳过”分开消融。

对安全 Guard 的迁移需要重新定义必要性和奖励：KL 接近 full teacher 不保证 unsafe 召回，精确答案 reward 也不能表达漏报代价。更直接的实验是将其作为 vertical-compute baseline，与真实 token 删除、固定浅层出口及 Full Guard 比较；安全证据的空间选择仍需另一机制。该笔记不把组合结果作为安全可行性已证实，也不修改正式 motivation。

关联：[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]；[[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]]；[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|时延口径审计]]。

## 证据定位与待验证项

- 必要性分析、router 与两阶段训练：§3、图 2–3，PDF 第 3–6 页。
- 三模型主结果及水平组合：表 1–3，PDF 第 7–8 页。
- 训练组件、自适应量/位置、延迟与案例：表 4–6、图 4，PDF 第 9 页。
- TODO：获取含完整附录的版本；训练配置、硬件与计时协议；多 seed；安全 reward；KV/cache 实现；真实服务复现。均未执行。
