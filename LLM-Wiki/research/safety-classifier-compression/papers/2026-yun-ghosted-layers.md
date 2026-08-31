---
id: paper-note-yun-2026-ghosted-layers
type: paper-note
title: "Ghosted Layers: Unconstrained Activation Alignment for Recovering Layer-Pruned LLMs"
authors: ["Vincent-Daniel Yun", "Junhyuk Jo", "Sai Praneeth Karimireddy", "Sunwoo Lee"]
year: 2026
venue: "arXiv preprint (v2)"
source_id: paper-yun-2026-ghosted-layers
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, model-compression, structured-pruning, training-free, efficient-inference]
status: active
related: [paper-note-men-2025-shortgpt, paper-note-zhong-2025-blockpruner]
created: 2026-08-31
updated: 2026-08-31
---

# Ghosted Layers

## 一句话结论

论文把“剪掉若干 Transformer 层以后如何恢复”改写为剪枝边界上的多输出线性最小二乘：用原模型的边界前后激活估计一个无结构约束的稠密矩阵，在不训练主干的条件下显著降低 PPL 并恢复部分通用问答准确率。它证明的是**通用 LLM、离线校准、固定剪枝方案下的边界修补有效性**，没有证明安全 Guard 的决策边界、长尾危害召回或生成阶段时延得到保持。

## 书目信息与材料

- arXiv: 2605.15491v2；2026-05-15 首次提交，2026-06-07 修订；正文标注 `Under Review`。
- 本地原件：[[LLM-Wiki/raw/papers/2026-yun-ghosted-layers.pdf]]；25 页，CC BY 4.0。
- 官方代码：https://github.com/daniel-eai/ghosted_layers_official_repository/ 。代码仓库是基于 LinearPatch 的最小复现，不等同于本地复现实验。

## 研究问题与核心假设

层剪枝不仅减少计算，还会让第一个保留层收到它从未训练处理过的隐藏状态。对连续删除区间 $\mathcal B=\{\ell^*,\ldots,\ell^*+n-1\}$，原模型边界关系为

$$
X_{post}=X_{pre}+\Delta,
$$

而直接剪枝模型只传递 $X_{pre}$。论文的核心假设是：对一个固定剪枝边界，缺失更新 $\Delta$ 可以由 $X_{pre}$ 的单个线性映射在小规模无标签校准集上充分近似；只要直接最小化该边界误差，就能恢复较多下游能力。（§3.1，Eqs. 1–3，pp.3–4）

## 方法：无约束边界激活对齐

### 1. 收集成对边界激活

在**未剪枝原模型**上运行校准语料，用 forward pre-hook 分别记录首个被删层的输入 $X_{pre}$ 与首个保留层的输入 $X_{post}$，按 token 展平为 $\mathbb R^{TD\times C}$，再计算 $\Delta=X_{post}-X_{pre}$。（§3.2.1，p.4）

### 2. 闭式求解修补矩阵

目标是

$$
W^*=\arg\min_W\|X_{pre}W-X_{post}\|_F^2.
$$

令 $W=I+M$，等价于用 $X_{pre}$ 回归缺失残差：

$$
M^*=X_{pre}^{\dagger}\Delta,\qquad W^*=I+M^*.
$$

正文给出截断 SVD 形式，奇异值阈值为 $10^{-6}\sigma_{max}$；实现采用 float64 正规方程

$$
(X_{pre}^{\top}X_{pre}+\epsilon I)M=X_{pre}^{\top}\Delta,
$$

其中 $\epsilon=10^{-6}$，两个 $C\times C$ 累积量可以流式构造。（§3.2.2、Appendix H，Eqs. 4–7/A15–A16，pp.4, 24–25）

### 3. 在剪枝边界插入一次稠密映射

推理时计算 $x_{new}=xW^*=x+xM^*$。连续删层区间放一个矩阵；非连续删除时每个断裂区间各放一个。矩阵可作为 hook 插入，不训练原模型参数。（§3.2.3、Figure 2、Eq. 8，pp.3–4）

### 与 LinearPatch 的理论关系

LinearPatch 使用 $W_{LP}=HDH^\top$，固定 Hadamard 基下的对角缩放，因此必为对称矩阵；Ghosted Layers 直接搜索全部 $C\times C$ 线性算子。论文证明后者是相同激活对齐目标的最小范数无约束解，并报告 $M^*$ 的反对称分量范数占 LLaMA-3.1-8B 与 DeepSeek-R1-Distill-LLaMA-8B 的 46.9%/47.7%。（Theorem 4.1、Figure 3、Appendix A，pp.5, 13–14）

需要更精确地理解其“子空间”表述：固定 $H$ 时 $HDH^\top$ 实际只有 $C$ 个自由度，是对称矩阵空间中的更小子空间；论文用“受限于对称空间”说明不可表达反对称分量是成立的，但 $C(C+1)/2$ 只是包含它的对称空间维数，不是该参数化本身的自由度。

## 实验设置

- **模型**：主表为 LLaMA-3-8B、LLaMA-3.1-8B、DeepSeek-R1-Distill-LLaMA-8B；附录扩展到 LLaMA-2-7B、OLMo-2-7B、Qwen3-14B。（§5.1、Appendix E）
- **剪枝标准**：LLM-Streamline（连续区间）、ShortGPT 与 Shortened LLaMA（可非连续）；7/32、11/32 为主，Qwen3 使用 13/40、15/40。（§5.1、Tables 2–3/A6）
- **恢复基线**：Prune&Comp、ReplaceMe-LS/Cos、LinearPatch-Diag/Rotate；均为作者归类的 training-free 方法。（Table 1、Appendix B.2）
- **校准**：主要使用 C4 训练集随机 128 条、每条 2,048 tokens；算子估计实际说明为最多 32 batches/65,536 tokens。校准规模消融为 16/32/64/128 条；另以 WikiText-2 复核语料敏感性。（§5.1、Table 4、Appendices A.2/C/F/H）
- **质量指标**：WikiText-2、C4、PTB PPL；九个 zero-shot commonsense QA 的简单平均准确率。（§5.1）
- **效率**：单张 NVIDIA A40 48GB，FP16；prefill 3 次 warmup + 10 次计时，`use_cache=False`；报告平均时延和 `torch.cuda.max_memory_allocated()` 峰值。（Table 5、Appendix G）

## 关键结果与证据强度

### 通用问答恢复

在 LLM-Streamline 7/32 剪枝下，Ghosted Layers 的九任务平均准确率为：LLaMA-3-8B 60.10、LLaMA-3.1-8B 60.01、DeepSeek-R1-Distill-LLaMA-8B 57.80；相应最强对手分别为 ReplaceMe-LS 59.45、59.68、57.33。主表 11/32 时作者方法仍是平均分最高，但对最强恢复基线的优势只有 1.53–2.00 点，且若干单任务低于基线。（Table 2，pp.7–8）

这支持“平均恢复更好”，不支持“每个任务都更好”。例如 LLaMA-3.1-8B 7/32 时 Ghosted Layers 的 ARC-C 43.00、OBQA 37.20 与 RTE 68.59，分别低于某个恢复基线的 43.52、37.80 与 71.48；11/32 时 RTE 69.68 低于 LinearPatch-Diag 的 71.84。论文没有报告多种子方差或显著性检验。

### PPL 改善更显著

LLaMA-3.1-8B + LLM-Streamline 7/32 的三语料平均 PPL 从未修补的 2398.41 降至 27.81；ReplaceMe-LS 为 35.69，LinearPatch-Rotate 为 66.06。11/32 时 Ghosted Layers 为 74.01，对应 ReplaceMe-LS 204.07、LinearPatch-Rotate 252.52。作者方法在 Table 3 的多数模型 × 剪枝标准 × 比例组合中给出最低平均 PPL。（Table 3，pp.8–9）

该结果同时显示一个边界：即使恢复幅度很大，7/32 的 27.81 仍明显差于 dense 8.50，11/32 的 74.01 更远；“recovering”不是恢复到原模型等价质量。

### 校准数据、模型与微调消融

- LLaMA-3.1-8B 7/32 中，16→32 条校准序列使平均准确率 59.31→60.01；32→128 基本饱和（60.01→60.04），但平均 PPL 仍从 27.81 降到 25.89。（Table 4/A3，pp.9, 16–17）
- 把 C4 换成 WikiText-2 后，作者报告六个模型/剪枝比例设置中平均准确率变化不超过 0.36 点；但只比较了两个通用英文语料，不能推出对安全域或多语言域不敏感。（Appendix F、Table A7，pp.19, 22）
- 只微调边界算子、冻结主干并用 5,000 条 C4 做 top-100-logit KL 蒸馏时，Ghosted Layers 在四个 7-layer 设置中平均准确率略高于微调后的 LinearPatch，PPL 优势更大。（Appendix D、Tables A4–A5，pp.17–19）

### 效率

LLaMA-3.1-8B 7/32、序列 2,048、batch 1 时，dense/纯剪枝/Ghosted Layers prefill 分别为 362.6/287.3/291.9 ms，峰值激活显存为 100.0%/81.6%/82.0%；即相对 dense 为 1.24× 加速，修补矩阵只吃掉一小部分剪层收益。11/32 时为 247.6 ms、1.46×、71.5%。（Table 5，p.9）Appendix G 的长度/批量网格表明其时延与融合后的 LinearPatch 接近测量噪声。（Tables A8–A9，pp.23–24）

这是**prefill 单次 forward**证据，不包含自回归 decode、KV-cache、吞吐、P95、端到端请求、模型权重常驻显存或多并发 serving；不能直接转写成 Guard 在线 SLO 结论。

## 作者主张、直接证据与我的判断

| 层级 | 内容 |
|---|---|
| 作者主张 | 无约束线性算子在与 LinearPatch 相同的一次稠密矩阵乘成本下，更充分地修复层剪枝造成的边界激活错配。 |
| 直接证据 | 闭式最小二乘推导；反对称分量分析；六个骨干、三类剪枝准则、PPL/九项 QA、校准规模/语料/微调与 A40 prefill 网格。 |
| 支持程度 | 对“校准集内最小二乘目标最优”和“所测通用任务平均表现优于训练自由基线”支持较强；对“恢复完整模型能力”仅部分支持。 |
| 综合判断 | 该方法应被视为**选择层之后的恢复器**，而不是新的剪枝重要性指标。其优势最大处是把低成本边界对齐从受限参数化提升到完整线性回归；其风险是用通用 token 分布的均方重构替代任务判别边界。 |

## 局限、失败条件与复核疑点

1. **无安全或分类专测**：全部核心质量证据是通用 PPL 与 commonsense QA 平均准确率；没有 fixed-FPR recall、worst-group、校准、越狱或多模态危害证据。
2. **平均激活 MSE 可能掩盖稀有方向**：最小二乘优先拟合高方差、高频 token；稀有危害、低 margin 或决策头依赖的小子空间可能被平均目标牺牲。
3. **并非严格“无开销”**：作者准确证明的是与融合 LinearPatch 的算子成本相同，而不是相对纯剪枝零开销；Table 5 显示额外矩阵乘确实降低了少量 speedup 并增加显存。
4. **校准依赖**：需要访问未剪枝模型并保存/累积边界统计；$C=4096$ 时单个 FP16 稠密矩阵约 32 MiB，多个非连续边界会线性累加参数、GEMM 与 hook 管理成本。
5. **数值表述需谨慎**：ridge 正规方程在 $\epsilon>0$ 时一般不是 Moore–Penrose 最小范数解，只是在该实验满列秩、很小正则下得到近似相同下游结果；Table A10 检验的是指标近似等价，不是矩阵逐元素相等。
6. **实验统计不足**：QA 无多种子/置信区间；效率只给单卡均值；未报告闭式求解的离线时间、CPU/GPU 峰值或多边界总成本。
7. **论文内部可复核问题**：正文称主 QA 表跨“四个”骨干，但 Table 2 实际列三种；Figure 3 文字写“all two backbones”且 Appendix A.2 又称三种；Appendix D 说 fine-tuned LinearPatch 可离开对称子空间，但若仍只优化 $D$ 则不成立，需结合实现确认究竟微调融合矩阵还是受限参数。

## 与当前安全判别压缩课题的关系

### 可直接复用

- 在 ShortGPT、BlockPruner 或任务对齐剪层之后，把每个删除区间配一个 Ghosted Layer，作为“零主干训练”的恢复基线。
- 边界对齐模块可与安全任务选择标准解耦：前者负责恢复一般表示，后者仍用安全损失、fixed-FPR 与长尾切片选择层。
- 流式累积 $X^\top X$ 与 $X^\top\Delta$ 适合在不保存所有 token 激活的情况下构造恢复器。

### 不能直接外推

- **Hypothesis**：把普通最小二乘改成风险加权最小二乘（危害样本、低 margin、worst-group 加权），或联合蒸馏 Guard logits，可能比 C4 无权对齐更能保持安全边界。
- **TODO**：在同一层集合、同一真实 P95 时延预算下比较 `pruned only / LinearPatch / Ghosted Layers / risk-weighted Ghosted`，报告 macro-F1、unsafe recall、fixed-FPR recall、AUPRC、ECE、worst-category、prefill/decode、峰值显存。
- **TODO**：分别测试连续与非连续剪层；后者的多个 $C\times C$ 补丁可能抵消结构化剪枝收益。

## 最小复现清单

1. 固定官方 v2、代码提交、模型 checkpoint revision、C4 样本 ID 与 tokenizer。
2. 先复现 LLaMA-3.1-8B、LLM-Streamline [23,30)、7/32、32×2048 tokens、float64 累积、$\epsilon=10^{-6}$。
3. 同时保存边界训练误差、独立校准误差、矩阵条件数、$\|M_{sym}\|_F$ 与 $\|M_{asym}\|_F$，避免只看下游平均分。
4. 复核 SVD 与 solver 的矩阵差、离线求解成本和精度，而不只复核最终 PPL。
5. 在 Guard 数据上预注册高风险切片与 latency 口径；没有本地运行前，`verification` 保持 `source-checked`。
