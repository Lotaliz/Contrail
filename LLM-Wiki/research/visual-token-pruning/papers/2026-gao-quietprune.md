---
id: note-2026-gao-quietprune
type: paper-note
title: "QuietPrune: Query-Guided Early Token Pruning for Vision-Language Models"
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
source_id: paper-gao-2026-quietprune
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-10-20
---

# QuietPrune

来源：[CVPR 2026 官方页](https://openaccess.thecvf.com/content/CVPR2026/html/Gao_QuietPrune_Query-Guided_Early_Token_Pruning_for_Vision-Language_Models_CVPR_2026_paper.html)及本地官方 PDF `LLM-Wiki/raw/papers/2026-gao-quietprune.pdf`。本轮精读 §1–6、Figures 2–7、Equations (1)–(16)、Tables 1–2；未运行代码或模型。

## 问题与关键假设

主流 VLM 在视觉塔完成后或 LLM 层内才剪视觉 token，无法减少此前的 ViT 计算。作者在 Qwen3-VL/InternVL3 上的 profile 显示，ViT 在多数配置中占 prefill latency 的 50% 以上，小模型高分辨率时可超过 75%（§1，Figure 2，pp. 3553–3554）。因此 QuietPrune 把选择前移到 ViT 内部。

早剪的困难是尚未发生正常的图文融合，纯视觉 saliency 可能保留前景却删除问题真正询问的数字、背景或小区域；同时 Qwen-VL/InternVL 常在 projector 前后以相邻 $2\times2$ token merging 缩短视觉序列，任意散点删除会破坏这种空间结构假设（§1、§3，Figures 3、5，pp. 3554–3557）。

## 方法流程

QuietPrune 只删除视觉 token。所谓 query-guided/joint 是让文本 query 进入视觉塔参与选择，并非剪除文本 token。完整流程包含三个模块（§4，Figure 4，p. 3556）。

### 1. Text-to-Vision adapter 与 `[Q-CLS]`

普通 projector 将视觉特征从视觉空间映射到 LLM 文本 embedding 空间。QuietPrune 将其组件顺序反转，构造轻量 text-to-vision adapter，把 query embeddings 映回视觉空间，再池化为一个 `[Q-CLS]` token。该 token 被 prepend 到视觉 token 序列，与图像 token 一起进入 ViT self-attention（§4.1，p. 3556）。

若 projector 线性层为 $Y=WX+b$，对应 adapter 用

$$
W^*=W^{-1},\qquad b^*=-W^{-1}b.
$$

非方阵或不可逆矩阵使用 Moore–Penrose 伪逆并通过 SVD 求解；LayerNorm 用 $\gamma^*=1/\gamma,\ \beta^*=-\beta/\gamma$ 近似反演；GELU 直接保留（Equations 7–12，pp. 3556–3557）。这些逆变换只是初始化，adapter 仍需少量训练。

### 2. 用 `[Q-CLS]` attention 评价视觉 token

将 `[Q-CLS]` 与 $N$ 个视觉 token 组成 $X\in\mathbb{R}^{(N+1)\times d}$，执行正常 ViT attention：

$$
Q=XW_Q,\quad K=XW_K,\quad V=XW_V,
$$

$$
A=\operatorname{softmax}\left(\frac{QK^T}{\sqrt d}\right),\qquad O=AV.
$$

使用 $A$ 中 `[Q-CLS]` 指向各视觉 token 的 attention 作为 query relevance。这个 attention 已在 ViT forward 中产生，不需要额外的图文 cross-attention 前向（§4.2，Equations 13–15，p. 3557）。

### 3. $2\times2$ 半结构化分组剪枝

空间相邻的 $2\times2$ 视觉 token 构成不可分割 group；group 分数是四个成员 relevance 的平均值。高分 group 整组保留，低分 group 整组删除。这样保留后的网格仍与 Qwen/InternVL 后续 $2\times2$ merging 对齐，避免非结构化删除使一个 merge cell 的 token 来自不连续位置（§4.2，Figure 5，p. 3557）。

论文在 ViT 总深度的 $1/4$、$1/2$ 与 $3/4$ 三个位置执行剪枝；每次按当前 group relevance 删除比例 $R$ 的视觉 token。训练时 $R=25\%$，测试时无需重训即可调整 $R$（§5.1，p. 3558）。

### 4. 被删信息聚合

被删除视觉 token 不完全丢弃，而是按 relevance $a_i$ 加权成一个 compact token：

$$
x_m=\sum_i a_i x_i.
$$

最终把该聚合 token 与保留的视觉 token 拼接后送入 LLM。论文称只新增一个 token，额外时延可忽略（§4.3，p. 3557）。

### 5. Self-distillation 训练

冻结原 VLM，仅训练 text-to-vision adapter。未剪模型作为 teacher，剪枝模型作为 student；目标为 teacher/student logits 的 KL divergence 加 student 对 ground truth 的 cross-entropy：

$$
\mathcal{L}_{total}=\mathcal{L}_{distill}(Y_s,Y_t)+\mathcal{L}_{ce}(Y_s,Y_{gt}).
$$

训练数据从 LLaVA-Instruct、ShareGPT4V、ChartQA、ScreenQA、SynthDoG、MultiVQA 混合池随机采样 10K，约占组合数据的 0.8%；单张 A100 约训练 40 分钟（§4.4、§5.1，pp. 3557–3558）。

## 实验与消融

模型为 InternVL3-1B、Qwen3-VL-4B、InternVL3-8B；基准为 MMBench、MMStar、MMMU、HallusionBench、AI2D 与 OCRBench；时延在单张 A100、standard eager-mode attention 下测量（§5.1，p. 3558）。比较使用 LLM 部分平均视觉 token 剪枝率 $R^*$ 对齐不同层级方案，而不是简单比较某一层的瞬时 token 数。

在平均剪枝率 50% 时，Qwen3-VL-4B 的 QuietPrune 相对准确率为 95.7%，prefill latency reduction 为 33.1%；InternVL3-1B/8B 分别为 98.5%/42.1% 和 97.4%/49.3%（Table 1，p. 3559）。官方摘要所称“最高 19.0%”指相对最佳 late-pruning 对照的额外 latency-reduction 百分点，而非 QuietPrune 相对未剪模型的绝对上限。

50% 剪枝率消融显示（Table 2，p. 3560）：

- semi-structured 相对 unstructured 将 InternVL3-1B/Qwen3-VL-4B 的相对准确率从 81.20%/78.36% 提高到 98.45%/95.71%；
- query-guided 相对纯视觉 saliency 提高 4.11/5.94 个百分点；
- inverse initialization 相对随机初始化提高 3.25/2.94 个百分点；
- redundant-token aggregation 再提高 0.50/0.84 个百分点。

## 证据边界与当前项目判断

- 论文没有剪文本 token；文本只是经 adapter 形成 `[Q-CLS]`，后续原始 query 仍正常进入 LLM。
- 剪枝是三处预设层位置和统一比例 $R$，并非根据每个样本难度动态预测预算。
- relevance 本质仍来自 attention，没有因果 sufficiency、反事实删除或安全漏报约束。
- $2\times2$ group 与 Qwen/InternVL 的视觉合并结构强相关；迁移到不同 patch merge 或动态分辨率实现时需重新定义 group 和位置编码。
- 论文报告平均通用基准、相对准确率与平均 prefill latency，未报告 fixed-FPR、P95、危害长尾、归因忠实度或压缩诱发攻击。

对安全 Guard，QuietPrune 是“policy/query 前移到 ViT”的直接强基线。仅将 query 替换为安全政策不足以构成新意；可研究的增量是样本级风险预算、OCR/小目标/关系覆盖、被删证据充分性、unsafe-to-safe flip 与低置信回退。

关联：[[LLM-Wiki/research/safety-classifier-compression/text-guided-visual-token-pruning.md]]；[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]。
