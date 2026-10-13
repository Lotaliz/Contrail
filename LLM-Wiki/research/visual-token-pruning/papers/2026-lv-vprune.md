---
id: note-2026-lv-vprune
type: paper-note
title: "VPRune: Efficient Training-free Pre-LLM Visual Token Pruning"
authors: [Guangchuan Lv, Dianxing Shi, Dingjie Fu]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-24485
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, training-free, efficient-inference]
status: active
created: 2026-09-24
updated: 2026-10-13
---

# VPRune：视觉多样性、信息回灌与位置保持

## 书目信息与阅读边界

来源：[arXiv 2609.24485v2](https://arxiv.org/abs/2609.24485)，v1 首次提交于 2026-09-21，v2 更新于 2026-09-22；许可为 CC BY 4.0。精读 5 页全文、表 1、图 1–4、组件消融与端侧效率；阅读原件：[PDF 原文](https://arxiv.org/pdf/2609.24485v2)。未运行代码、模型或设备测试，结果均为作者报告。

## 方法定位

VPRune 是 projector 后、LLM 前的 training-free 压缩器，面向 FastVLM-1.5B 的 256 个视觉 token。给定保留比例 $b$，保留 $K=\operatorname{round}(bN)$ 个 token。方法把紧预算退化归结为三点：文本相关性过度集中、直接丢弃导致互补信息损失，以及 compact 后连续重编号破坏 RoPE 空间距离，并依次用 VDS、STR、PPR 处理。

### VDS：去除文本偏置的 DPP 多样性

CDPruner 式条件 DPP 核可写为 $\widetilde L=D_rLD_r$，其 log-determinant 包含视觉多样性项与文本相关性的加性偏置。VDS 去掉 $D_r$，只最大化 $\log\det(L_S)$，用 greedy MAP 选择视觉上多样的集合。该设计在作者的紧预算实验中优于文本引导，但它完全忽略当前问题，因此不应外推为一般情况下 query-free 一定更好。

### STR：把删除 token 回灌到最近保留 token

每个删除 token 按余弦相似度分配给最相似的保留 token；组内以温度 $\tau$ 做 softmax 权重，随后更新

$$
\widetilde x_j=(1-\gamma)x_j+\gamma\sum_{i\in G_j}w_{ij}x_i.
$$

默认 $\gamma=0.3,\tau=0.1$。STR 不增加 LLM token 数，但改变被保留 token 的特征；因此“选择原 token”与“信息融合”必须分开描述。相似度分组可能把语义相近但空间不同的细节混在一起，正文没有 provenance 或局部证据恢复评测。

### PPR：compact 序列、非连续 position ID

保留 token 恢复原 raster 顺序，并将位置设为 $p_i=N_{prefix}+q_i$；后续文本从 $N_{prefix}+N$ 起算。物理序列仍只有 $K$ 个 token，空洞只存在于 position ID 中，不会重建长度 $N$。这直接针对 RoPE 重编号失真，是当前项目中值得保留的强基线。

## 实验与结果

冻结 FastVLM-1.5B，图像 pad 到 $1024\times1024$，在 GQA、TextVQA、POPE-adv、500 样本 AI2D-lite 与 ChartQA 上评测；greedy decoding、batch 1。与 CDPruner、VScan、FastV、HiPrune、VisionZip、FlashVLM 对比。

在删除 20%/40%/70% token 时，VPRune 的五任务归一化平均保持率为 99.47%/98.14%/94.87%，均为表中最高。70% 删除时 TextVQA 66.36、ChartQA 66.00；第二高分别为 57.87 与 54.36，优势主要来自文字/结构密集任务。POPE-adv 多个方法已接近 full baseline，提升很小。

30% 保留的累计消融显示：移除文本相关性、加入 PPR、再加入 STR 均提高 GQA/TextVQA；$\gamma=0.3$ 在所测两任务上最好，过大回灌会退化。图 3 只给曲线/柱图，没有多 seed 或不确定性。

效率在 Qualcomm QCS8550、CPU-only、batch 1 上测量。30% 保留时 LLM prefill 从 9.88 s 降到 6.13 s，下降 38%。端到端 TTFT 的 full baseline 为 25.551 s；10% 保留时为 20.365 s，仅下降 20.30%，显示视觉塔与选择器等固定成本限制全链收益。30%/60%/80% 保留时 TTFT 分别下降 14.97%/8.82%/4.02%。

## 局限与项目关系

- 只在一个 1.5B 模型、五个 benchmark、单一 CPU 平台上验证，外部效度有限。
- VDS 主张来自紧预算 FastVLM；缺少 query 类型分层，不能证明文本条件普遍有害。
- AI2D 使用 500 样本子集；无多 seed、置信区间、代码审查或跨模型结果。
- PPR 需要目标 LLM 支持自定义非连续 position ID；兼容性和 kernel 开销未系统评估。
- 方法在 projector 后执行，不节省视觉塔；DPP、相似度矩阵和回灌的独立时间未列表报告。

对当前政策条件 Guard，VPRune 提供三个可拆基线：视觉 diversity-only 选择、context residual 式信息回灌、原坐标 position ID。它也构成反证：不能只用文本相似度排序，但这不足以否定政策条件；应比较 policy-conditioned coverage 与纯视觉 VDS，并单独测 PPR/STR 对 unsafe recall 和文字证据的贡献。

## 证据定位与待验证项

- 三个退化来源与整体路径：§1、图 1–2。
- VDS、STR、PPR：§3.1–3.4，式 (1)–(5)。
- 数据、预算、基线：§4.1；主结果：表 1、§4.2。
- 组件与 $\gamma$：图 3、§4.3；QCS8550 时延：图 4、§4.4。
- TODO：官方实现与 position-ID 路径核查；selector-inclusive 分项计时；全量 AI2D、多模型、多 seed；安全 Guard 压缩翻转。本轮均未执行。
