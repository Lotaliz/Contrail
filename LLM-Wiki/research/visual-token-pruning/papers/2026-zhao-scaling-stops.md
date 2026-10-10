---
id: note-2026-zhao-scaling-stops
type: paper-note
title: "Not All Error Yields to Scale: Where Scaling Stops in Vision-Language Inference"
authors: [Xinye Zhao, Yunkai Dang, Yunchen Wu, Wenbin Li]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-01640
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# Scaling Stops：视觉预算与主干容量的可分离响应

## 原件与阅读范围

用户在候选索引选中本文。精读 [arXiv 2610.01640v1](https://arxiv.org/abs/2610.01640v1) 的正文方法、结果，以及附录 A 的计数/解码协议、B 的拟合/留出/有界性/参数不确定性、E 的成本与配置选择。完整 HTML 原件见 [[LLM-Wiki/raw/papers/2610.01640v1.html]]；图表和公式以原文定位。未运行模型、拟合器或 Lean 证明，以下数字均为作者报告。

PDF 原件另见 [[LLM-Wiki/raw/papers/2610.01640v1.pdf]]（53 页）；完整文件已解析，关键图表与 HTML 数字交叉核查，SHA256 登记在同一 source_id 的 local_artifacts。

## 问题、模型与拟合

作者研究固定推理预算下应该增加语言主干参数还是视觉 token。它改变输入图像分辨率，保持公开 instruction-tuned 模型及其视觉 processor，不训练剪枝器。设语言主干参数为 $N$、实际进入主干的平均视觉 token 为 $R$，多选题错误率拟合为

$$L(N,R)=e_{\infty}+A N^{-\alpha}+B R^{-\beta}.$$

这一加性模型与乘性、带交互项、CES 和 p-norm 形式比较；“可分离”是被比较的经验模型，不是独立因果机制的证明。每个模型系列×benchmark 独立拟合；附录 B.1 对两轴用全局几何均值归一化，最小化配置级未加权 SSE，用 16 个初值的 Nelder–Mead 搜索指数，误差 floor 扫描 55 个值，非负幅度以约束闭式解求得。指数搜索范围为 $[0.05,10]$。

## 数据与主要证据

§2.2、附录 A：26 个 Qwen2.5/3-VL 与 InternVL2.5/3/3.5 模型，语言主干 1B–72B；HR-Bench、MME-RealWorld、TreeBench、V* Bench。输入长边共用 224、336、512、768、1024、2048 px，HR-Bench 另有 4096 px 的 8K 来源图；因此“8K 图像研究”不等于所有输入长边均设为 8K。650 个配置单元、536,781 条有效评测，BF16、零样本 greedy，多数运行最多生成 48 token，部分为 32；主指标为解析文本答案准确率。

- §2.4、图 3：pooled $R^2=0.898$；乘性模型 SSE 高 53.2%。带交互项把 SSE 从 1.221 降至 1.182，但 BIC 增 115.2。附录 B.5 的留出实验中，per-group 可分离与交互模型在内部配置的 RMSE 基本相同，不能概括为所有设定下严格优胜。
- §3、表 1、图 4：按有限配置轨迹平均准确率分为 Easy、Scaling Bound、Ceiling Bound；后者约 30.7%，高低计算四分位的正确选项概率只增 0.014。所谓 cognitive ceiling 来自有限模型范围和拟合 floor，不证明这些题目不能被更好的模型、训练或证据选择改善。
- §4、图 5、附录 B.7：InternVL 的 tiling 使 70.2% 问题在 224→2048 px 时 tile 数不变，token span 中位数仅 1.22×；九个视觉指数达到上限。QwenVL 的连续 resizing 暴露更宽 token 范围、视觉指数较稳定。因此 InternVL 的大指数不能直接当作精确的内在视觉效率常数。

## 配置选择与成本

§5.1 以语言侧 prompt FLOPs $2P_{\mathrm{LLM}}(R+T_0)$ 为预算，拟合 $C=\kappa N^pR^q$；pooled $p=1,q=0.77$。VPE 连续最优点平衡两轴单位预算的减错收益：

$$\frac{\alpha A}{p}(N^*)^{-\alpha}=\frac{\beta B}{q}(R^*)^{-\beta}.$$

在已有离散配置目录中，直接评估预测错误率比将连续最优点投影到最近配置更好。§5.2、附录 E.3 表 30：2,379 个 joint-holdout 决策中，direct selection 的平均/p90 regret 为 0.76/2.74 个百分点；projection 为 2.33/7.71，静态最大 token、最大主干、log-center 的平均 regret 为 4.09–7.56。projection 最差 regret 34.55，高于最大 token 基线的 27.00，不能保证每次选路更好。幅度接近零时 projection 回退到 direct selection。

附录 E.1 表 29：时延拟合 $R^2$ 在各系列仅 0.019–0.764，pooled 为 0.366，正文预算并非真实服务时延。加入重建的视觉成本后总体预算扩张方向保留，但个别选择与可行预算改变；其敏感性分析仍没有完整 preprocessing、通信和测量时延。

## 局限与项目判断

这是跨模型/分辨率的平均性能拟合，不是同一 backbone 内的 token 选择，也不是逐样本政策条件 router。不同模型的视觉塔、训练配方和 processor 均可能混杂参数轴响应；拟合存在边界指数、端点外推和样本难度异质性。附录 B.6 的有界模型保持大多数配置选择，但不能消除范围外外推风险。

**本项目判断：** C5 可以借鉴“直接在有限路线目录预测任务收益”和 held-out regret 评价，但应以同一 Guard 的逐路线任务损失与实测端到端成本构造 teacher；不能把本文 $N/R$ 指数或 cognitive ceiling 直接移植为政策预算规律。与 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]] 的关系是预算评价近邻；与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 的区别在于本文不设计查询条件子集。

TODO：固定 Guard/政策场景的路线收益预测、配对政策翻转、逐样本 regret 和真实时延；本轮未执行，不更新正式研究动机或创建新 concept。
