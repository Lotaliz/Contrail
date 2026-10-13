---
id: note-2026-jiang-vcola
type: paper-note
title: "V-CoLA: Vision Token Compression with Linear Attention"
authors: [Hao Jiang, Yiru Mao, Tianpeng Bu, Hao Zhou, Hongtao Duan, Wang Jing, Bowen Xu, Xin Chen, Lulu Hu, Bin Yang, Yongliang Tao, Minying Zhang]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-11251
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-13
---

# V-CoLA：混合线性注意力的状态读出、合并与深层退出

## 原件与阅读范围

用户选择精读。[arXiv 2610.11251v1](https://arxiv.org/abs/2610.11251v1)，论文许可为 arXiv perpetual non-exclusive license；完整 HTML 原件见 [HTML 原文](https://arxiv.org/html/2610.11251v1)。精读 §1–4、§7，图 2–8、表 1–10，附录 A 的并行实现、C 的成本分析、D 的长回答/小目标/端到端计时。未运行模型或代码，所有效果是作者报告。

另保存 [完整 PDF](https://arxiv.org/pdf/2610.11251v1)（16页），全页解析；视觉核查第16页表8–10，与HTML的预算和E2E数字一致，PDF哈希登记于同一来源。

## 问题、信号与执行位置

§2 图 2–4：FastV/DART 的浅层 softmax attention 或特征相似度在 Qwen3.5 混合架构上不再稳定优于随机剪枝。作者以 Gated DeltaNet 的固定矩阵状态解释这一现象；有限精度状态容量界描述单个递归状态的信息损失，不能直接证明包含残差和周期性 softmax 层的完整模型丢失了相同语义。

§3.1–3.2 式 6–8：长期重要性是末状态 $S_L$ 对当前 key/value 的重建相似度，$R_t^{imp}=1-\psi(S_Lk_t,v_t)$；短期独特性是 token 写入前后，对附近伪查询读出的余弦距离变化。二者以 $R_t=(1-\lambda)R_t^{imp}+\lambda R_t^{uni}$ 混合，默认 $\lambda=0.1$，窗口 $(w_1,w_2)=(0,4)$。这不是问题条件效用监督，也不是政策相关性评分。

§3.3 式 9–10：沿序列按累计重要性划分近似等质量的连续区间，每段按 score softmax 加权合并，温度为 1；高重要性密度区域获得更细粒度。附录 A 用扩展 DeltaRule 一次计算多组旁路查询，累计质量分段和聚合采用并行矩阵操作，避免逐 token 暴露状态。

§3.4、§4.1：默认在 **LLM 第 1 层末**压缩，之后到第 24 层退出视觉 token。attention 基线则在首个 softmax 层取分数。视觉塔仍完整运行。作者对齐的是**跨层平均保留率**，不能把表中 50% 直接当成退出前的保留率：附录 D 表 9 的 matched 工作点是无退出时 48.39%，有退出时前段 65.22%。早退出收益包含将深层预算移给浅层的作用。

## 结果与消融

§4.1–4.2 表 1：Qwen3.5-9B，A100，lmms-eval 的 MME/MMBench/GQA/ScienceQA/TextVQA/POPE/VizWiz/MMStar。完整平均 880 个视觉 token；平均保留 50%/25%/12.5% 时，归一化平均性能为 99.5%/94.8%/88.0%。这是各任务相对性能汇总，不是准确率；12.5% 时 TextVQA 从 83.2 降至 46.0，平均值不能掩盖 OCR 的明显退化。

表 4–6：单独长期项较默认混合分数弱，前向四-query 窗口较单 query 好；去掉合并或早退出均有损失，但 early-exit 消融包含跨层预算重分配，不能只归因于退出本身。表 7 扩展到 Qwen3.5-27B/InfiniteVL，优势并非每个任务都成立。附录 D 表 8，MMDU 总分 66.6→65.4（12.5%）；表 9，191 个 V*-Bench 样本中单独第 24 层退出为 74.87，完整为 75.92，第 12 层退出为 73.30，支持保留中间层证据。

## 效率口径

表 2 是 **LLM prefill**：2K 输入时 269→145/88/61 ms，8K 时 1034→542/289/168 ms，最大 6.15×。表 3 的 8K adaptive merging 为 0.86 ms；四查询 DeltaRule 135.1→35.1 ms 是算子对照，不能当成整体加速。

附录 D 表 10 给出不同平台的完整分解：Jetson Thor、INT4 TensorRT、2K 视觉输入、32 输出 token；ViT 固定 243.3 ms，decode 固定 778.6 ms，E2E 在 12.5% 时 2254.9→1301.5 ms（1.733×），压缩开销已包含在 prefill。故论文大数字主要指 prefill；不能外推为 decode 或本项目短答案 E2E 的同等加速。A100 主表的 batch/同步/重复统计说明仍不足，真实批处理需另核验。

## 项目判断与待验证项

关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-sun-adavskip.md|AdaVSkip]] 和 [[LLM-Wiki/research/visual-token-pruning/papers/2026-kang-when-text-matters.md|When Text Matters]]。V-CoLA 删除/合并序列，AdaVSkip 跳过模块计算；两者的 cache 与成本边界不同。

**本项目判断：** 混合架构需要重新审计重要性信号和 token–layer 工作量；末状态重建与短期变化可作诊断，尚不能代替 Cx 的全局/条件局部真实收益标签。当前 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|Cx]] 面向编码前预算与单框，本文既没有 policy flip/Guard 召回评测，也不节省视觉塔。§7 明确尚未覆盖纯 Mamba/全线性架构。

TODO：核验不同层视觉退出后的位置、每层 KV/递归状态和 decode 路径；对齐退出前 token 数与跨层平均成本；记录 TTFT、decode、选择器和短政策 Guard E2E。本轮不新建 concept、不更新正式 motivation。
