---
id: note-2026-wang-stacktok
type: paper-note
title: "StackTok: Accelerating VLMs Inference with Budget-Adaptive Visual Token Selection"
authors: [Zhenbin Wang, Lei Zhang, Lituan Wang, Wei Huang, Yan Wang, Zhenwei Zhang]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-16841
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, vision-language-model, visual-token-pruning, budget-optimization, training-free, efficient-inference]
status: active
created: 2026-09-16
updated: 2026-09-16
---

# StackTok

## 书目信息与阅读边界

来源：[arXiv 2609.16841v1](https://arxiv.org/abs/2609.16841)，首次提交于 2026-09-15；四川大学作者团队。当前仅核实 arXiv 预印本身份，未确认会议录用。[官方代码](https://github.com/wongzbb/StackToK)已公开，代码为 Apache-2.0，论文为 CC BY 4.0。

精读范围：正文问题设定、§Method 全部子节、§Experiments、主表 1–3、附录 A 的覆盖性质与参考曲线证明，以及附录 B 的评测协议、表 A1–A5。本地原件：[[LLM-Wiki/raw/papers/2609.16841v1.pdf]]，11 页。PDF 部分文本存在重叠/重复，正文结合官方 HTML 核对，附录表格核对 PDF。未运行代码、模型或复现实验；以下数字均为作者报告。

用户于 2026-09-16 指定精读，将已有近期候选升级为 deep-read / source-checked，沿用原 source_id，不重复登记。

## 问题背景

高分辨率使视觉前缀膨胀：LLaVA-1.5 的 $336\times336$ 图像为 576 个视觉 token，LLaVA-NeXT 多 crop 可达 2,880 个。长前缀增加 LLM 的 prefill 与内存成本。

作者将既有选择方法分为两类：查询相关性优先会保留被询问的细节，却可能丢失场景上下文；覆盖/多样性优先能代表整张图，却可能把有限预算用在无关区域。MMTok 用固定加权目标 $R(S)+\alpha C(S)$ 统一两者，但同一权重无法随查询、已选集合大小和当前状态改变优先级。

StackTok 的核心不是新的注意力模块，而是改变两个代理信号的关系：**相关性是目标，视觉覆盖是随集合大小校准的支撑条件**。积木最大悬挑仅是设计类比，不应视为算法具有物理稳定性保证。

## 方法设计

### 执行位置与输入

在完整视觉编码器和 projector 运行之后、LLM 推理之前选择 token；无训练、无新增参数、无 token 重建或合并。输入包括视觉塔特征 $X\in\mathbb R^{n\times d_v}$、projector 后特征 $Z\in\mathbb R^{n\times d}$ 和 LLM 输入 embedding 层产生的查询词向量 $Q\in\mathbb R^{m\times d}$。查询并非经过 LLM 上下文化的隐藏状态。

候选集合 $U$ 排除 padding，但全部编码位置仍作为 affinity 的被覆盖对象。给定外部预算 $K$，严格保留 $k=\min(K,|U|)$ 个原 token，最后恢复原空间顺序，将对应的 $Z$ 行送入 LLM。**budget-adaptive 指给定预算下的策略适配，不是自行预测预算或学习 STOP。** 它不节省完整视觉塔/projector 的计算。

### 1. 两个 facility-location 代理

对向量做 $\ell_2$ 归一化，然后以余弦相似度构造行 softmax：

$$
A^{qv}_{ij}=\frac{\exp(\bar q_i^\top\bar z_j/\tau_t)}{\sum_\ell\exp(\bar q_i^\top\bar z_\ell/\tau_t)},\qquad
A^{vv}_{ij}=\frac{\exp(\bar x_i^\top\bar x_j/\tau_v)}{\sum_\ell\exp(\bar x_i^\top\bar x_\ell/\tau_v)}.
$$

二者是 embedding affinity，不是模型 attention。对任意 $p$ 行非负矩阵定义：

$$
F_A(S)=\frac1p\sum_{i=1}^p\max_{j\in S} A_{ij},\qquad
R(S)=F_{A^{qv}}(S),\quad C(S)=F_{A^{vv}}(S).
$$

空集合的覆盖为零，空查询时 $R=0$。每个查询词或原视觉 token 都由已选集中最能代表它的 token 提供覆盖；新增候选 $s$ 的边际收益为：

$$
\Delta F_A(s\mid S)=\frac1p\sum_i[A_{is}-\max_{j\in S}A_{ij}]_+.
$$

最大值缓存可增量更新，边际收益随集合扩大递减。这里的 $C$ 是**视觉表示几何覆盖**，不是空间均匀覆盖、像素覆盖，更不是安全证据召回率。

### 2. 按集合大小建立覆盖参考，再用熵调节目标

先执行覆盖优先的贪心链 $G_t=G_{t-1}\cup\{\arg\max_s\Delta C(s\mid G_{t-1})\}$，只保留各大小的数值 $C_t^{ref}=C(G_t)$，不直接使用参考链选出的集合。

查询—视觉 affinity 的平均归一化熵决定目标严格程度：

$$
\bar H=\frac{1}{m\log n}\sum_i\left[-\sum_jA^{qv}_{ij}\log A^{qv}_{ij}\right],\quad
\beta=\operatorname{clip}(\bar H,\beta_{min},\beta_{max}),\quad
\theta_t=\beta C_t^{ref}.
$$

低熵表示查询 affinity 集中，降低覆盖要求；高熵表示分布弥散，提高覆盖要求。但作者也提醒：高熵可能只是图文对齐弱，不等于问题真的需要全局理解。空查询退化为纯覆盖；单 token 情况单独处理。

附录证明非负 facility-location 为归一化、单调、次模函数；覆盖贪心参考满足 $C_t^{ref}\ge[1-(1-1/t)^t]\mathrm{OPT}_t\ge(1-1/e)\mathrm{OPT}_t$。这是**参考贪心链的近似保证**，参考数值是可实现的近似尺度，不是最优覆盖上界；不能外推为最终 StackTok 集合的相关性最优或覆盖可行性保证。

### 3. 覆盖缺口门控的交替选择

当前已选 $t$ 个 token 时，计算 $d_t=[\theta_t-C(S_t)]_+$：

- $d_t=0$：主要按 $\Delta R$ 选，$\Delta C$ 作次级判据。
- $d_t>0$：主要按 $\Delta C$ 选，$\Delta R$ 作次级判据。
- 主要收益全部为零则回退到次级收益；两者均饱和时用确定性 tie-break 填满预算。

每次加入后更新两组最大值缓存，再重新判断门控。非空查询的第一步因 $\theta_0=0$ 而相关性优先。

重要边界：这是“当前支撑不足时优先修补”的启发式，**不是强制每个前缀满足 $C(S_t)\ge\theta_t$ 的硬约束**。一次覆盖选择最大化当前目标下的缺口修补，但目标在集合增大后也会升高，不能保证立即追上。

### 4. 高分辨率跨 crop 共享预算

每个 crop 独立构造 affinity、参考曲线及熵门控，先提名本地最优候选 $s_c^*$；全局分配器在提名者之间比较 $h_c=\Delta R_c(s_c^*)+\Delta C_c(s_c^*)$，把下一枚 token 分给收益最高的 crop。只更新获胜 crop 的提名，其余缓存复用。

相比均匀配额，这能随各 crop 的边际饱和情况动态分配总预算。注意：虽然本地选择不再固定加权相关性与覆盖，**跨 crop 分配仍使用 $R+C$ 的和**；全局只比较本地提名者，并非扫描所有候选求统一约束最优。没有每个 crop 至少保留若干 token 的硬下限。

### 5. 可选保持支撑的 swap

预算填满后，可在相同基数下将一个已选 token 换成未选 token。要求 $J=R+C$ 严格相对改善，并满足：

$$
J(S')>(1+\varepsilon_{sw})J(S),\qquad C(S')\ge\min\{\beta C_r^{ref},C(S)\}.
$$

原集合已达目标时允许覆盖下降到目标；未达目标时不允许进一步降低覆盖。利用每行 top-2 affinity 计算删除影响。严格改善与有限集合保证终止，但不等于全局最优。自动 refinement 仅在本地集合不超过 16 个 token 时做一轮，因此不能把它视为所有常规预算结果的主要原因。

### 实现与成本

附录 B：默认 $\tau_t=0.02,\tau_v=0.2$，Qwen 的 $\tau_t=0.01$；$\beta\in[0.3,0.9]$，$\varepsilon_{sw}=10^{-6}$。LLaVA 提取 content-bearing keywords；Qwen 使用 question-prefixed 文本，查询预处理会影响 affinity 和熵。

affinity 构造时间 $O(n^2d_v+mnd)$、内存 $O(n^2+mn)$；参考链和交替选择合计 $O(ku(n+m))$，在相应规模假定下为 $O(kn^2)$。多 crop 采用各 crop 的局部平方成本之和；训练免费不代表选择开销免费。

## 实验设置与主要结果

模型：LLaVA-1.5 7B/13B、LLaVA-NeXT 7B/13B、Qwen2.5-VL 7B。十个不同基准的并集包括 GQA、MMBench、MME、POPE、ScienceQA-IMG、VQAv2、TextVQA、MMMU、SEEDBench、OCRBench；并非每个模型都测十项。

LLaVA 在九项基准上用 lmms-eval，对比 FastV、SparseVLM、VisionZip、DivPrune、MMTok；VisionZip 的微调版本另列，不作为 training-free 排名口径。LLaVA-1.5 预算 192/128/64，NeXT 共享预算 640/320/160；Qwen 动态分辨率按原 token 数保留 20%/10%/5%。

Avg 为各基准“剪枝得分/完整模型得分”的平均百分比，**不是平均准确率**。原始指标量纲不同。

| 模型 | 预算（从左到右） | StackTok Avg（%） | MMTok Avg（%） |
|---|---|---|---|
| LLaVA-1.5 7B | 192 / 128 / 64 | 98.99 / 98.03 / 96.66 | 98.70 / 97.84 / 96.58 |
| LLaVA-1.5 13B | 192 / 128 / 64 | 98.96 / 97.72 / 96.54 | 98.75 / 97.53 / 96.46 |
| LLaVA-NeXT 7B | 640 / 320 / 160 | 98.97 / 97.51 / 95.26 | 98.78 / 97.32 / 95.18 |
| LLaVA-NeXT 13B | 640 / 320 / 160 | 98.53 / 96.68 / 95.21 | 98.27 / 96.49 / 95.13 |
| Qwen2.5-VL 7B | 20% / 10% / 5% | 95.79 / 89.80 / 80.00 | 94.58 / 88.52 / 78.98 |

定位：主表 1、3；附录表 A1（PDF 第 10 页）。Qwen 的 Avg† **仅计 GQA、MMBench、MME、POPE、TextVQA 五项，排除 ScienceQA 和 OCRBench**，与 LLaVA 的九项平均不可直接横比。

作者在每个测试的模型—预算设置中取得 training-free 选择器的最高平均保持率；但 LLaVA 对 MMTok 仅提高 0.08–0.29 个百分点，Qwen 提高 1.02–1.28 个百分点，无多 seed 或置信区间支持显著性判断。单项不全面领先：如 LLaVA-1.5 7B、64 token，MME 为 1702.47，低于 MMTok 的 1714.85。

摘要亮点：NeXT-7B 用 160/2880（约 5.6%）token，保持 95.26% 的基准平均性能。这既不是 95.26% 准确率，也不是 18 倍实测加速。

紧预算的 OCR 是明显失败边界：Qwen OCRBench 从完整模型 83.80 降到 59.78 / 43.68 / 30.73；TextVQA 从 77.72 降到 71.00 / 64.52 / 56.52。OCRBench 又未计入 Avg†，仅看平均值会高估文本细节的保留能力。

## 消融证据

| LLaVA-1.5 7B 选择变体 | 192 token | 128 token | 64 token |
|---|---:|---:|---:|
| StackTok | 98.99 | 98.03 | 96.66 |
| 对所有阶段使用最终预算目标 | 98.70 | 97.58 | 96.05 |
| 固定 $\beta=0.5$ | 98.88 | 97.92 | 96.54 |
| 仅相关性 | 98.10 | 96.75 | 94.20 |
| 仅覆盖 | 98.15 | 96.95 | 94.55 |
| 每预算调优的固定加权目标 | 98.85 | 97.93 | 96.60 |

定位：主表 2、附录 A2。主要收益来自结合相关性与覆盖；按集合大小的参考目标比“一开始就用最终目标”更好。熵校准仅提升约 0.11–0.12 个百分点；对充分调优的固定加权目标只提升 0.06–0.14 个百分点，不能夸大门控的性能幅度。

NeXT-7B（640/320/160 token）动态 crop 分配为 98.97/97.51/95.26，均匀分配为 98.55/96.95/94.40，初始收益比例分配为 98.72/97.20/94.85，紧预算下动态分配收益更明显（附录 A3）。swap 在 8/16 token 时由 84.8/90.4 提高到 85.2/90.7（A4）；64 token 的三个 $\beta$ 区间结果 96.54/96.66/96.49（A5），只是小范围敏感性检查。

## 作者结论、优点与局限

作者结论：相关性目标与预算校准支撑的不对称设计，在已测设置下比相关性优先、覆盖优先和固定权重结合更好；动态 crop 分配改善高分辨率紧预算质量。

直接证据支持：无需重新训练即可缩短 LLM 视觉前缀，同时在多模型、多预算上保持较高任务得分；目标大小校准和动态 crop 分配有相应消融支持。

个人审查：

- 标题强调 Accelerating，但正文和附录没有报告 wall-clock speedup、TTFT、吞吐、selector-inclusive latency 或硬件条件；只有预算—任务分数及理论选择成本。因此本论文证明的是压缩质量，不足以证明端到端实际加速。
- 二次 affinity 与多步贪心本身有成本；完整视觉编码器/projector 已支付，不能归类为 pre-encoder 或 early-encoder pruning。
- 代理覆盖和查询熵没有判别正确性或因果证据保证；门控不是硬覆盖约束，参考链的理论保证不属于最终交替集合。
- 对最强近邻的平均增益很小，未报告统计不确定性；单项有退步，OCR 在极限预算下降严重。
- 未测试安全 Guard 的漏报、政策条件证据、对抗背景、视频或跨预算安全一致性；不外推安全可靠性。

## 对当前项目的候选启发（未验证）

可作为完整视觉塔后、训练免费的相关性—覆盖选择基线，特别用于检验双证据选择是否真的优于充分调优的固定权重和门控，而不是只优于纯相关性。当前项目以浅层安全充分视觉前缀为主线，StackTok 的执行位置并不实现该部署目标。

迁移假设：可尝试将视觉几何支撑替换或补充为政策条件证据组支撑，并用必要性干预检验被保护内容是否真的改变安全判定；但不能直接把 $C$ 或 $\beta$ 称作安全召回约束。需要单独测尾部漏报、OCR/小目标证据、crop 零配额，以及完整视觉塔与选择器计入后的端到端成本。此处仅记候选，不修改正式动机或主方案。

关联：[[LLM-Wiki/research/visual-token-pruning/overview.md|项目主线]]；[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|实测时延基线与复现口径]]；[[LLM-Wiki/research/visual-token-pruning/papers/2018-burns-women-also-snowboard.md|Equalizer：反事实区域约束]]；[[LLM-Wiki/experiments/20260914-dual-evidence-token-compression/README.md|双证据压缩实验设计]]。

## 证据定位与待验证项

- 背景、积木类比与近邻区别：Introduction、Related Work、图 1。
- 特征位置、affinity、facility-location、参考与熵、门控：Method 前四小节、图 2；覆盖理论：附录 A。
- 多 crop 提名、共享分配、swap、复杂度：Method 后三小节。
- 数据、模型、指标、主结果与组件消融：Experiments、表 1–3。
- 预处理/温度/阈值、Qwen 口径及 OCR、补充消融：附录 B，PDF 第 10–11 页，表 A1–A5。
- TODO：固定版本代码核对与复现；各预算 selector/vision/prefill/decode 分项计时；公平调优 MMTok；多 seed 不确定性；安全任务迁移。均未在本轮执行。
