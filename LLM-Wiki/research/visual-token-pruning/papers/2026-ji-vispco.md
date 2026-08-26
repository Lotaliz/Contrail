---
id: paper-note-ji-2026-vispco
type: paper-note
title: "VisPCO: Visual Token Pruning Configuration Optimization via Budget-Aware Pareto-Frontier Learning for Vision-Language Models"
authors: ["Huawei Ji", "Yuanhao Sun", "Yuan Jin", "Cheng Deng", "Jiaxin Ding", "Luoyi Fu", "Xinbing Wang"]
year: 2026
venue: "ACL 2026"
source_id: paper-ji-2026-vispco
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, budget-optimization, efficient-inference]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-26
---

# VisPCO: Visual Token Pruning Configuration Optimization

## 研究问题

VisPCO 不重新定义视觉 token 的 importance score，而是优化给定 selector 下的**逐层保留率配置**。设 Qwen2.5-VL 语言模型有 $L$ 层，配置为 $r=[r_1,\ldots,r_L]$；方法在 FLOPs 预算 $B$ 下，最小化完整模型 logits 与剪枝模型 logits 的 KL divergence（§3.1，Eq. 1–3）。作者用 Augmented Lagrangian、连续阈值松弛和 straight-through estimator 使离散 Top-k 选择可微（§3.1–3.2，Algorithm 1），并比较 single-layer、linear、exponential、p-sigmoid 与 multi-step pruning pattern（§3.3）。

## Qwen2.5-VL 实验方案

### 1. 模型与剪枝对象

| 项目 | 论文设置 | 定位 |
|---|---|---|
| 基础模型 | Qwen2.5-VL-3B；正式代码加载 `Qwen2.5-VL-3B-Instruct` | §4.1；官方实现 `main.py` |
| Transformer 层数 | 36 层；每层配置一个视觉 token retention ratio | Appendix C.1.3 |
| 原始预算 | 100% 约 3.56 TFLOPs | Table 1 |
| 主预算 | 90%、50%、10%；50% 是配置差异最大的核心区间 | §4.2，Table 1 |
| 底层 pruning rule | FastV、SparseVLM、FitPrune；VisPCO 只优化它们的层级配置 | §4.2，Table 1 |
| 训练参数 | 只训练轻量 ratio predictor，底座模型和 full-token teacher 冻结；KL 用于保留输出分布 | §3、Figure 2；官方实现 `main.py` |
| 输入分辨率 | Qwen2.5-VL 保留 native/dynamic resolution；作者认为这使其 Pareto frontier 优于固定缩放的 LLaVA/Gemma3 | §4.3，Table 3 后分析 |

论文没有给出精确 Hugging Face revision、processor 的 `min_pixels/max_pixels`、生成长度、解码参数或 chat template 版本；这些是复现实验前必须补齐的版本锁定项。

### 2. VisPCO 训练数据与预处理

- **来源：** 从 LLaVA-Instruct-150K 下采样 30K image–instruction samples（§4.1）。
- **动机：** 原始样本的图像面积分布长尾且偏向小图，导致 ratio predictor 在高分辨率图像上的预测 Pareto frontier 偏向低预算，与 empirical frontier 不一致（Appendix C.1.1）。
- **论文描述：** 将图像面积区间分箱，通过 stratified sampling，对稀少区间 oversample、密集区间 subsample，使各面积区间样本数近似一致（Appendix C.1.1，Figure 4）。这里平衡的是**图像面积分布**，不是对像素值做传统灰度直方图均衡。
- **当前官方代码的差异：** `dataset/uniform_image_area.py` 并没有按论文文字重采样样本，而是按面积分位数将每张图像 resize 到 $400\ldots1024^2$ 的近似均匀目标面积，保持长宽比并以 Lanczos 重采样。`run_training.sh` 当前还指向 `train_10000_uniform_area_single_image.json`，而非论文的 30K。故正式复现必须先决定以论文叙述还是当前代码快照为准，不能混用。
- **预算条件：** 当前数据加载器在样本间轮换 20 个预算点 $\{0.01,0.05,\ldots,0.95\}$；论文正文只说明 ratio predictor 读取视觉、文本 embedding 与预算 $B$，没有列出这一采样表。

### 3. Benchmark 选择

评测数据由 VLMEvalKit 提供，覆盖三个能力族、八个 benchmark（§4.1；Appendix C.1.2）：

| 能力族 | Benchmark | 论文使用意图 | 规模/特点（论文附录） | 主要脆弱点 |
|---|---|---|---|---|
| 视觉问答 | A-OKVQA | 视觉 + 外部常识/世界知识 | 1,145 questions | 对知识与生成解析敏感 |
| 视觉问答 | VizWiz | 低质量真实图像鲁棒性 | 4,319+ image-question pairs；盲人用户拍摄 | 模糊、异常视角、不可回答样本 |
| 视觉问答 | SEEDBench | 综合场景、实例、空间与推理 | 14,232 multiple-choice questions，9 个维度 | 多能力平均可能掩盖切片退化 |
| 多模态推理 | MMBench | 感知、推理、知识的客观题 | 20 个能力维度 | 版本、语言 split 与 answer extraction 需固定 |
| 多模态推理 | MME | 14 个感知/认知子任务 | existence/count/position/OCR 等 | 论文改用正确数/总数，不是常见原始总分 |
| 图表/OCR | ChartQA | 图表读取与数值推理 | 2,000+ human-written questions | relaxed accuracy 口径需由 VLMEvalKit 版本确认 |
| 图表/OCR | OCRBench | 场景、手写、文档、多语言 OCR | 多类文字识别与推理 | 官方分数与百分比换算需锁版本 |
| 图表/OCR | TextVQA | 读取场景文字后回答 | 1,000 OpenImages images | VQA soft score/答案规范化需锁版本 |

**选择逻辑：** 八个任务同时覆盖普通 VQA、知识推理、低质量图像、OCR 与图表，因此适合检验配置是否只对一种视觉分布有效。但没有定位、hallucination、多图、视频或长生成任务，不能证明配置对这些场景也有效（Limitations）。

### 4. 配置搜索与评测协议

#### Empirical Pareto frontier

- 对 36 层分别从 $\{0.01,0.06,0.11,\ldots,0.96,0.99\}$ 采样 retention ratio，共评估 700 个配置（Appendix C.1.3）。
- 每个配置完整运行八个 benchmark；性能为八项“accuracy”的无权平均，成本由 Appendix A 的 Transformer FLOPs 公式计算。
- 用标准 Pareto dominance 提取 nondominated configurations（Appendix C.1.3，Eq. 57–58）。700 配置约需 48+ GPU hours，用来充当 empirical frontier ground truth，而不是 VisPCO 日常训练成本。

#### VisPCO 与基线

- Table 1 中**未加 VisPCO**的各行，是满足预算的多个采样配置的均值 ± 标准差；论文没有披露每个预算/方法的样本配置数。
- 搜索效率比较包括 VTW、G-Search、ATP-LLaVA、MADTP、AIM 和 Random-40/80/160（§4.2，Table 2）。Table 2 只评 MMBench、SEED、TextVQA，并在约 2.20T FLOPs 附近比较。
- 跨模型实验用 FastV、50% budget，在 A-OKVQA、MMBench、TextVQA 三项上比较 LLaVA-v1.5-7B、Gemma3-4B、Qwen2.5-VL-3B（§4.3，Table 3）。
- pattern 消融在 50% budget 比较 single-layer 与 linear/exponential/p-sigmoid/multi-step（§4.4，Table 5）；作者进一步指出低于 50% 时 multi-step 优势更明显。

### 5. 优化配置与硬件

论文 §4.1 给出的 single-layer 默认值为 $\lambda=100,\epsilon=0.01,\alpha=2,\beta=0.5,\sigma=10,T=0.1$，AdamW、lr $4\times10^{-4}$、batch size 16，硬件为 8×NVIDIA H20 96GB。

但 Appendix Table 6 对 Qwen2.5-VL-3B + FastV/SparseVLM/FitPrune 给出 $\lambda=100,\alpha=5,\epsilon=0.005,\beta=0.5,\sigma=10,T=0.1$、lr $10^{-4}$、batch 16。当前 `run_training.sh` 又使用每卡 batch 2 × 8 卡（global batch 16）、seed 42、BF16、lr $10^{-4}$、`alpha=5`、`epsilon=0.01`、`sigma=100`、linear kernel 和最多 1000 epochs。三处并不完全一致，应以实验配置文件的实际日志为最终证据，而不能只写“遵循论文默认值”。

## 指标与结果分析

### 任务质量

- Table 1 的 full Qwen2.5-VL-3B 八项平均为 78.1。
- 50% budget 下，FastV sampled configurations 为 $63.1\pm9.5$，FastV + VisPCO 为 71.5；SparseVLM 为 $64.5\pm8.4\rightarrow71.8$；FitPrune 为 $65.4\pm7.9\rightarrow72.2$。
- 90% budget 的收益只有约 0.4–0.9 个平均点；10% budget 只有约 1.3–2.0 点。论文据此认为 50% 中等预算是配置优化最重要的区间（§4.2）。
- Table 3 只在 A-OKVQA/MMBench/TextVQA 三项上，Qwen2.5-VL-3B 的随机配置均值为 $67.7\pm10.1$，VisPCO 为 77.3；这与 Table 1/4 的八项平均不可混用。

### 系统效率

Table 4 在单张 NVIDIA H20 上报告：

| Qwen2.5-VL-3B | Budget | TTFT | Throughput | 八项平均 |
|---|---:|---:|---:|---:|
| Full | 100% | $83\pm3$ ms | $18\pm2$ tokens/s | 78.1 |
| FastV | 50% | $74\pm2$ ms | $20\pm3$ tokens/s | 63.1 |
| FastV + VisPCO | 50% | $76\pm3$ ms | $20\pm2$ tokens/s | 71.5 |

VisPCO 的价值是**在近似相同硬件成本下恢复被错误配置损失的质量**，不是比同预算 FastV 再显著提速。论文没有披露 latency batch、输入/输出长度、warm-up、重复次数、P95、峰值显存或 selector wall-clock，因此 Table 4 只能支持有限的平均硬件结论。

### 指标口径问题

1. 论文把八个 benchmark 的结果统一写成百分比并做无权平均；只有 MME 明确说明改为 correct/total 并归一化到 $[0,1]$。ChartQA、OCRBench、TextVQA 的具体 VLMEvalKit evaluator/version 未写明。
2. 不同 benchmark 的 score 不是天然同质，“八项平均 + KL proxy”可能偏向样本多、解析稳定或语言先验强的任务；需要同时报告逐任务差值和 worst-task drop。
3. Table 1 的 50% budget 标题仍印为约 3.56 TFLOPs，与 100% budget 相同，疑似排版错误；复现时应从逐层 token 数重新计算 FLOPs，不能抄该数值。
4. Table 1 的 `± std` 来自不同采样配置，不是训练 seed 或样本置信区间；不能据此判断 VisPCO 的统计显著性。

## 官方实现核对（访问于 2026-08-25）

官方仓库：<https://github.com/JHW5981/VisPCO>。

- 当前代码确认底座 checkpoint 为 Qwen2.5-VL-3B-Instruct，只解冻 `predict_pruning_ratio`，full-token teacher 冻结，并使用 BF16 与 seed 42。
- 当前公开脚本包含大量占位路径，训练数据规模、面积平衡算法、$\sigma/\epsilon$ 等与论文不完全一致；公开评测脚本默认只跑 ratio 0.5 并读取自定义 JSON。
- `processor` 的 pixel 上限参数存在默认值、help 文本和被注释更新函数之间的不一致。因此本笔记将论文方案与当前代码快照分开记录，不把代码默认值倒推为论文事实。
- 这些差异意味着现有公开仓库更适合作为实现起点，而不是无需补充配置即可一键复现 Table 1–5 的完整 artifact。

## 作者局限与本地判断

- 作者局限：主要是单图任务；尚未验证多图/视频；kernel 是结构化参数族，未来可探索更灵活的 non-parametric 或 input-adaptive pattern（Limitations）。
- 本地判断：VisPCO 的核心贡献是配置优化，不是 selector 质量。小规模测试应固定 FastV importance rule，只比较相同 FLOPs 下的 layer schedule，否则 selector 与配置效应会混杂。
- 本地判断：先复现 Table 3 的三任务子集比直接跑八任务更合理；必须保留 OCR/TextVQA，因为 Qwen2.5-VL 的动态分辨率使 pruning configuration 与图像面积强耦合。

## 对实验的影响

已设计但未执行的小规模验证：[[LLM-Wiki/experiments/20260825-vispco-qwen25vl-small/README.md|Qwen2.5-VL-3B 上的 VisPCO 小规模配置优化测试]]。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
- [[LLM-Wiki/research/visual-token-pruning/comparison.md|统一维度比较]]
