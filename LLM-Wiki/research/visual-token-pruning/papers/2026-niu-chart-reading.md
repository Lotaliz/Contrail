---
id: note-2026-niu-chart-reading
type: paper-note
title: "Inside VLM Chart Reading: Tracing Value Reading from Vertical Bar Charts Across Space and Depth"
authors: [Tianhao Niu, Qingfu Zhu, Wanxiang Che]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-13745
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, mechanistic-interpretability, activation-patching, visual-evidence, chart-understanding]
status: active
created: 2026-09-20
updated: 2026-09-21
---

# VLM 图表读数：视觉证据的空间与深度因果定位

## 书目信息与阅读边界

来源：[arXiv 2609.13745v1](https://arxiv.org/abs/2609.13745)，首次提交于 2026-09-12。精读 33 页 PDF 的正文 §3–8、关键统计定义与数据审计附录。本地原件：[[LLM-Wiki/raw/papers/2609.13745v1.pdf]]。论文不是剪枝方法；纳入原因是它提供“哪些局部视觉状态在何时仍可影响输出”的反事实测量工具。未运行模型或重建数据，以下数字均为作者报告。

## 研究问题与实验对象

任务是从合成竖直柱状图中读取指定 series/category 的精确整数。正确答案同时依赖：legend 将 series 绑定到颜色、x-label 绑定目标柱、柱顶编码视觉高度、y 轴将高度映射为数值。作者用 Qwen2.5-VL-7B-Instruct 和 InternVL3.5-8B 做 controlled counterfactual activation patching，研究空间位置、跨层可恢复性、legend 到文本位置的 handoff，以及柱高与坐标轴尺度是否可从不同 donor 组合。

500 张源图产生 5,932 个问题；图表使用无语义 pseudoword、1–3 个 series、4–6 个 category、从 0 起始的轴、5/10 刻度间隔。Qwen 渲染为 1344×1344，InternVL 为 448×448。正文的九种条件每种最后取 500 个问题，并保持两模型样本 ID 与干预元数据一致。

## 方法与指标

### 反事实构造

图像干预分别修改 y 轴尺度、目标柱高度、legend 映射、x-label；prompt 干预修改 category、series 或两者。柱高条件对同一对原图/反事实图定义三种 ROI：完整柱并集、只覆盖变化柱顶的对称差、以及不变柱体交集。这样可以在视觉 token 更少的情况下检验“变化证据”是否比大面积不变区域更关键（表 1，PDF 第 4 页）。

### 完整答案序列 restoration

作者用 teacher forcing 计算完整整数答案序列的 log probability，而不是只看第一个 token。令原始、反事实、patch 后对原答案与反事实答案的 margin 为 $M_o,M_c,M_p$，归一化恢复量为：

$$
R=\frac{M_p-M_c}{M_o-M_c}.
$$

$R=1$ 表示恢复完整 margin gap，$R=0$ 表示保持反事实偏好；不截断到 $[0,1]$。图像 ROI 在 projector 后图像 token 位置以及各语言层 residual 位置 patch；prompt 条件 patch 对应文本位置。作者明确将它解释为“原局部状态足以把反事实计算推向原答案”，不等于该位置是唯一必要证据。

Qwen 的视觉网格由 96×96 合并为 48×48，InternVL 由 32×32 合并为 16×16。主分析用 any-overlap；Qwen 另把命中 token 扩到不重叠 3×3 coarse 区域，作为边界敏感性检查而非最小因果区域。

## 主要结果

### 变化柱顶比不变柱体更有因果可恢复性

投影位置平均 restoration（表 2，PDF 第 6 页）如下：

| 设置 | 完整柱并集 | 变化柱顶 | 不变柱体 |
|---|---:|---:|---:|
| Qwen any-overlap | 0.910 | 0.783 | 0.328 |
| Qwen 3×3 coarse | 0.950 | 0.912 | 0.420 |
| InternVL | 0.994 | 0.936 | 0.490 |

变化柱顶的 token 数反而更少：Qwen any 为 21.8 对 53.2，coarse 为 47.0 对 97.6，InternVL 为 5.3 对 11.1。限制到变化 ROI token 数不多于不变 ROI 的样本，restoration 差仍为 0.449/0.480/0.438；chart-cluster bootstrap 与 chart-equal 估计方向一致。证据支持“内容变化位置比面积大的不变上下文更能恢复数值偏好”，但只在成功读数的合成柱图上成立。

### 不同证据的深度寿命不同

单层曲线显示 series/legend 相关状态更早失去局部可恢复性，柱高与轴尺度保持更晚。InternVL 中 series/legend 大约在 14–15 层下降，category/x-label 约第 19 层，axis/bar 约第 23–24 层。Qwen 也有 legend 早、定量证据晚的总体分离，但 x-label 与 prompt-label 时间更依赖架构。

Qwen 的轴尺度相对 half-life 为归一化深度 0.815/0.852，而柱 ROI 约 0.59–0.63；InternVL 中 axis/bar 更接近 0.657/0.686。作者因此没有宣称固定的“先量高度、后读尺度”通用顺序。扩大 ROI 大幅改变 restoration 幅度，但九种条件的层曲线平均相关为 0.995，说明空间范围对“多少信息”影响大于对“何时仍可局部恢复”的影响。

### legend 到文本状态的部分 handoff

作者先从视觉 legend 源位置 patch，再在候选 destination 做 reset。400 个 held-out 问题中，InternVL 无 reset 的 $R=0.910$，重置 prompt-series 后为 0.701，blocking effect 0.209；Qwen 从 0.967 降到 0.541，effect 0.426。重置 prompt-label、目标柱或匹配控制柱几乎不影响 InternVL，对 Qwen 也远小于 prompt-series（表 3，PDF 第 11 页）。这支持 prompt-series 状态是视觉 legend 影响输出的部分中介，而非唯一通路。

### 柱高与尺度可跨 donor 组合

2×2 factorial family 中，一个 donor 只改柱高，一个只改轴尺度，diagonal 同时改变。joint-cross 从两个不同 forward pass patch 两组状态，joint-coherent 从 diagonal 取两组状态。投影位置上 InternVL 两种 joint 的目标准确率均 0.996、restoration 都约 0.977；Qwen joint-cross 为 0.908/0.803，joint-coherent 为 0.996/0.867（表 6，PDF 第 14 页）。两模型都能组合分离来源的信息，但 Qwen 对 donor 上下文一致性更敏感。

## 局限与证据边界

- 评测条件要求原图与反事实端点均答对；factorial 还要求两模型四端点全对。结论描述成功读数样本，不覆盖失败病例。
- 图表为固定布局的合成竖柱图和整数；没有自然图表的 OCR 噪声、截断轴、注释或复杂样式。
- activation patching 展示局部状态的充分影响，不证明唯一必要性、真实自然因果路径或可以安全删除其余 token。
- ROI 粒度受视觉 token 网格和 merge 影响；coarse 扩张会改变幅度。
- 研究只涉及两种 VLM，模型间已显示 donor-context 敏感性差异。

## 对当前项目的影响

这篇论文给当前安全 token pruning 两个方法启发。第一，证据价值不能以 ROI 面积或 token 数衡量；变化很小的局部区域可能携带主要决策信息。第二，图像证据与文本/政策绑定的可恢复性随深度不同，剪枝监督应区分局部视觉状态、跨模态绑定状态和后续定量/语义整合状态。

可迁移的实验模板是：构造只改变安全相关局部因素的成对输入，在候选浅层 patch/删除该 ROI，观察 unsafe margin 的恢复或下降，并用非目标区域作 matched control。是否能从柱图读数迁移到开放世界安全内容是待验证假设；本论文不能直接证明政策因果充分视觉前缀存在，也不应把 restoration 当作 token importance 真值。

关联：[[LLM-Wiki/research/visual-token-pruning/region-rationale-guided-safety-token-pruning.md|区域理由引导安全剪枝]]；[[LLM-Wiki/research/visual-token-pruning/research-plan.md|当前政策条件剪枝路线]]；[[LLM-Wiki/experiments/20260914-dual-evidence-token-compression/README.md|双证据压缩实验设计]]。

## 证据定位与待验证项

- 数据、反事实与完整序列 restoration：§3–4、表 1，PDF 第 3–5 页。
- 空间 ROI、token 数控制与深度曲线：§5、表 2、图 1–5，PDF 第 5–8 页。
- handoff 与 reset-based mediation：§6、图 6–7、表 3，PDF 第 8–11 页。
- factorial recombination：§7、表 4–6、图 8，PDF 第 10–14 页。
- 限制与统计定义：Limitations、附录 B–C，PDF 第 14–33 页。
- TODO：在真实安全图文对上设计可控反事实；比较 patching、删除与遮挡；验证 margin 指标与 Guard 召回；跨模型/分辨率重复。均未执行。
