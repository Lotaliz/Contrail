---
id: paper-note-shen-2025-numerical-pruning
type: paper-note
title: "Numerical Pruning for Efficient Autoregressive Models"
authors: ["Xuan Shen", "Zhao Song", "Yufa Zhou", "Bo Chen", "Jing Liu", "Ruiyi Zhang", "Ryan A. Rossi", "Hao Tan", "Tong Yu", "Xiang Chen", "Yufan Zhou", "Tong Sun", "Pu Zhao", "Yanzhi Wang", "Jiuxiang Gu"]
year: 2025
venue: "AAAI 2025"
source_id: paper-shen-2025-numerical-pruning
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, model-compression, training-free, efficient-inference]
status: active
related: []
created: 2026-08-28
updated: 2026-08-28
---

# Numerical Pruning for Efficient Autoregressive Models

## 一句话总结

该方法是一种基于少量校准样本的、无需反向训练的结构化剪枝：先把“保留哪些 attention head / MLP channel”松弛为连续 mask，通过 Newton 法最小化校准激活上的线性层输出重构误差；再全模型统一排序并生成耦合结构 mask；最后利用带等式约束的最小二乘闭式解，把被删通道的输出贡献重分配到保留权重中。

## 问题与剪枝对象

论文面向 decoder-only autoregressive Transformer，希望同一方法同时适用于语言生成模型 LLaMA 和离散图像 token 自回归模型 LlamaGen。与非结构化权重稀疏不同，它删除能直接缩小 dense matrix 形状的结构（§1、§3.1，pp. 20418–20420）：

- **Attention**：同一个 mask 联动删除 `W_Q/W_K/W_V` 的输出列和 `W_O` 的对应输入行，即整 attention head 或 head 内通道；实际全局选择以整 head 为单位。
- **MLP**：同一个 mask 联动删除 up/gate projection 的输出列和 down projection 的对应输入行，即 FFN intermediate channel。
- 数值重要性只在两个“汇合/输出”矩阵上计算：attention 的 `W_O` 与 MLP 的 `W_down`；得到 mask 后再传播给上游耦合矩阵（Fig. 1、§3.1）。

这里的行/列取决于论文采用的 `XW` 记法：被 mask 的是输出投影矩阵 `W` 的输入维，也就是 `W` 的行；它对应前级 QKV/up/gate 的输出列。

## 剪枝算法

### Step 1：收集局部校准问题

对每个 `W_O` 或 `W_down`，记录校准输入 `X ∈ R^{N×D}` 和权重 `W ∈ R^{D×D'}`。二值 mask `M ∈ {0,1}^D` 作用于 `W` 的每一行，目标是在给定保留数量 `r=(1-ρ)D` 时最小化输出重构误差（Eq. 1–2、§3.2，pp. 20420–20421）：

```text
min_M  1/2 · ||XW - X diag(M) W||²_F
s.t.   1ᵀM = r
```

作者先给出误差上界：若 `||X|| ≤ R`，被删比例为 `ρ`，则单个输出列的误差不超过 `ρR||W[:,i]||`（Lemma 1；正式证明见 Appendix D.2, Lemma 9）。这个 bound 主要用于说明剪枝率、输入尺度和权重范数共同决定误差；真正的排序分数来自下面的连续优化，而不是直接使用该上界。

### Step 2：连续 mask 与 Newton numerical score

将二值 `M` 松弛为 `z ∈ [0,1]^D`，并把固定保留数约束改写为二次罚项（Eq. 3）：

```text
min_z  1/2 · ||XW - X diag(z)W||²_F
       + λ/2 · (1ᵀz-r)²
```

令

```text
A = (WWᵀ) ⊙ (XᵀX)
```

则梯度与 Hessian 为（Eq. 6–7）：

```text
g(z) = A(z-1) + λ(1ᵀz-r)1
H    = A + λ11ᵀ
```

Algorithm 1 从任意 `z₀∈[0,1]^D` 出发，迭代

```text
z ← z - H⁻¹g(z)
```

论文通常运行约 50 次，并把最终 `z_j` 作为第 `j` 个通道的 **numerical score**；分数越小越优先删除。单层复杂度写为 `O(TD³)`，主要来自 Newton step 中的矩阵求逆/线性求解（§3.2、§3.5）。

#### 如何理解这个分数

- `XᵀX` 表示校准激活方向及通道相关性；
- `WWᵀ` 表示输入通道在所有输出维上的权重相关性；
- Hadamard 积 `A` 因而同时考虑“该通道是否被激活”和“其权重贡献能否被其他相关通道替代”；
- 这比单独使用 weight norm 或 activation norm 更接近局部输出重构目标。

### Step 3：从通道分数形成全局结构 mask

对 attention，第 `h` 个 head 的分数为其 `D_h` 个通道分数的均值（§3.3, Eq. 8）：

```text
score_head(h) = mean(z_attn[h·D_h : (h+1)·D_h])
```

MLP 直接保留每个 intermediate channel 的 `z_mlp`。随后把所有层的 attention-head score 和 MLP-channel score 放进一个全局集合统一排序。

由于删除一个 attention head 同时缩减 Q、K、V、O 四个矩阵，而删除一个 MLP channel 缩减 up、gate、down 三个矩阵，作者把 head score 乘以 `α=4D_h/3`，试图校正两类结构对应的参数量差异；低于全局阈值的 head/channel 被删除（Eq. 8、§3.3）。

全局排序的意义是允许不同层采用不同稀疏率，而不是给每层机械删除相同比例。

### Step 4：闭式 weight compensation

仅做 mask 会产生输出误差，因此论文只对发生**行剪枝**的 `W_O` 和 `W_down` 更新保留权重；对于上游列剪枝矩阵，输出列已被置零，修改其他列无法恢复该列，所以不做补偿（§3.4，pp. 20421–20422）。

设 `M_p` 的列是被删行位置的 one-hot vector，`W_p=M_pᵀW` 是将被删除的权重行。求扰动 `ΔW`：

```text
min_ΔW ||XΔW||²_F
s.t.   M_pᵀΔW + W_p = 0
```

约束保证被删除行在 `W+ΔW` 中严格为零；目标则要求其余权重的改动在校准输入上尽量不改变层输出。Theorem 3 给出闭式解（Eq. 11）：

```text
ΔW* = -(2XᵀX)⁻¹ M_p
       [M_pᵀ(2XᵀX)⁻¹M_p]⁻¹
       M_pᵀW
```

若 `XᵀX` 不满秩，则用 `(2XᵀX+γI)⁻¹` 做 dampening（Remark 5）。该步骤本质上是结构化、等式约束版本的 OBS/最小二乘重构；只用前向校准数据和线性代数，不做梯度微调。

## 可执行伪代码

```text
输入：预训练模型、校准样本、目标剪枝率 ρ

1. 前向运行校准样本，缓存每层 W_O、W_down 的输入 X。
2. 对每个 W_O/W_down：
   a. 构造 A=(WWᵀ)⊙(XᵀX)。
   b. 用 Newton step 求连续 mask z。
3. Attention：把每 D_h 个 z 平均为 head score；
   MLP：直接使用 channel score。
4. 对 head score 做 4D_h/3 缩放，与全部 MLP score 全局排序。
5. 按阈值选择待删 head/channel，并把 mask 同步传播到：
   - Q/K/V 列和 O 行；
   - up/gate 列和 down 行。
6. 对每个被行剪枝的 O/down 矩阵，求 Eq. 11 的 ΔW*；
   保留行加入补偿，删除行保持为零。
7. 物理删除对应矩阵维度，导出更窄的 dense 模型。
```

## 实验设计与结论

### 设置

- **语言模型**：LLaMA-1 7B/13B/30B/65B，LLaMA-2 7B/13B/70B，LLaMA-3 8B/70B。
- **图像模型**：LlamaGen-XXL 1.4B 与 LlamaGen-3B，ImageNet 384×384。
- **校准**：语言实验使用 WikiText2 training set 的 128 个样本；对所有方法保持相同校准数。图像实验按论文描述为每个 ImageNet 类别生成 128 张图像用于 numerical score 和 compensation（§4.1）。
- **基线**：LLM-Pruner、SliceGPT、FLAP；图像实验主要比较 FLAP。
- **指标**：WikiText2/PTB/C4 PPL；七项 common-sense zero-shot accuracy；MMLU/GSM8K；图像 FID/sFID/IS/Precision/Recall；A100 GPU memory 与 generation speed（§4.1–4.4）。

### 主要结果

- LLaMA-1/2/3 的大部分模型、数据集和剪枝率上，论文方法获得最低 PPL；高剪枝率优势尤其明显。例如 LLaMA-7B 50% 时 WikiText2 PPL 为 11.66，FLAP 为 21.89（Table 1）。
- common-sense 结果提升较小：LLaMA-7B 20% 时平均准确率 58.79，FLAP 为 58.58，仍明显低于 dense 63.25（Table 2）。这说明更好的局部重构/PPL 不必然等比例转化为下游能力保存。
- LlamaGen-3B 10% 时 FID 为 3.97，优于 FLAP 的 7.57；随着比例提高，图像质量仍快速下降，但该方法退化较慢（Table 3）。
- Fig. 5 在 A100、64-token 输入上验证结构化 dense 缩窄确实降低显存并提高 tokens/s，但正文没有给出统一的精确 speedup 数字。
- calibration-size ablation 显示 128、512、1024 样本差异较小（Fig. 4）；短序列 128-token 实验仍优于基线（Table 4/10）。

## 关键评价与算法边界

### 优点

1. **剪枝结构可直接部署**：head/channel 删除形成更小 dense GEMM，不依赖稀疏 kernel。
2. **分数有明确局部目标**：不是经验幅值，而是最小化校准激活上的输出重构误差。
3. **显式利用跨通道相关性**：`(WWᵀ)⊙(XᵀX)` 能识别可由其他通道替代的方向。
4. **恢复成本低于微调**：128 个样本、闭式补偿，不需要反向传播。
5. **任务覆盖较广**：同一结构应用于语言与离散图像自回归模型。

### 数学与实现上的疑点

1. **有限罚项不与等式约束严格等价**：论文称 Eq. 3 与固定 `1ᵀz=r` 的问题等价，但有限 `λ` 只是软约束；只有采用拉格朗日约束或 `λ→∞` 才严格满足目标保留数。
2. **Algorithm 1 未投影到 `[0,1]`**：初始化在区间内，但 Newton update 后没有 clip/project；论文未说明如何保证最终 numerical score 仍满足 box constraint。
3. **目标是二次函数**：`H` 与 `z` 无关，若可逆，一次精确 Newton step 已到无约束二次问题的驻点；“通常约 50 次”的必要性和数值求解细节没有解释。
4. **全局 sparsity 定义不完全透明**：head 与 MLP channel 删除的参数量不同，乘 `4D_h/3` 只改变排序，不能自动保证最终实际参数/FLOP 剪枝率精确等于给定 `ρ`。
5. **复杂度较高**：逐层 `O(TD³)` score 与 `O(D³)` compensation 对 70B 模型不是轻量操作；论文称与 SparseGPT 同阶，但没有系统报告 pruning wall-clock、峰值内存或数值稳定性。
6. **组件归因不足**：实验没有系统比较“无 compensation”“局部分层 vs. 全局排序”“Newton score vs. 简单 closed-form/幅值”等关键消融，难以精确量化每个组件的独立贡献。

### 迁移到 Guard 的证据边界

论文没有安全分类、越狱检测、固定 FPR recall 或 worst-category 风险实验。它提供的是一种通用结构化候选生成器；若用于 Guard，应把 `X` 换成安全校准分布，并将最终 mask 用 unsafe recall、fixed-FPR recall、AUPRC、校准误差和对抗样本复核，而不能只依赖 PPL 型局部重构误差。

## 与已有方法的关系

- [[LLM-Wiki/research/safety-classifier-compression/papers/2024-an-flap.md|FLAP]]：两者都是前向校准 + 结构化 pruning + compensation；FLAP 用 activation fluctuation 和均值 bias 补偿，本方法用二次重构优化和闭式 weight compensation。
- [[LLM-Wiki/research/safety-classifier-compression/papers/2023-ma-llm-pruner.md|LLM-Pruner]]：LLM-Pruner 以任务损失的 Taylor/Fisher 梯度评估耦合结构，需 backward 并常用 LoRA 恢复；本方法只优化局部线性层输出，不需要任务梯度。
- [[LLM-Wiki/research/safety-classifier-compression/papers/2024-sun-wanda.md|Wanda]]：Wanda 的 `weight×activation` 更便宜，但主要是权重级稀疏；Numerical Pruning 显式建模通道相关性并输出硬件友好的 head/channel 结构。

## 来源

- AAAI 正式页面：https://ojs.aaai.org/index.php/AAAI/article/view/34249
- arXiv：https://arxiv.org/abs/2412.12441
- 本地原文：`LLM-Wiki/raw/papers/2025-shen-numerical-pruning.pdf`（arXiv v1）
