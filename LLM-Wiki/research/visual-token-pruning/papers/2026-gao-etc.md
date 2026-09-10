---
id: note-2026-gao-etc
type: paper-note
title: "ETC: Extreme Token Compression via Task-aware Visual Information Distillation in VLMs"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation]
source_id: paper-gao-2026-etc
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-09
---

# ETC: Extreme Token Compression via Task-aware Visual Information Distillation in VLMs

来源：[arXiv 2606.00543v2](https://arxiv.org/abs/2606.00543)；精读范围：§1–5、附录 A.1–A.2、图 1–4、表 1–10。未运行代码或复现实验。

## 问题、假设与目标

论文认为，极端视觉 token 压缩不应只保留输入特征的几何相似性，而应保留给定文本条件下完成任务所需的信息。§3.1 将压缩导致的额外任务损失写为

$$
\Delta_{task}=H(Y\mid Z,T)-H(Y\mid V,T)=I(Y;V\mid Z,T),
$$

其中完整视觉 token 为 $V$，文本为 $T$，压缩 token 为 $Z$，输出为 $Y$。当 $Y\perp V\mid(Z,T)$ 时，$Z$ 是关于任务输出的条件充分统计量。这个结论给出理想标准，但不证明论文构造的训练代理已达到充分性。

## ETC 如何压缩与重构视觉特征

### 1. 构造任务加权的重构目标

论文在选定的 LLM 层取完整视觉 hidden states $X_v\in\mathbb{R}^{N_v\times D}$。它对所有注意力头和文本 token 的 text-to-image attention 求平均，得到视觉 token 分数 $S_i$，再做 min-max 归一化。§3.2 的目标为

$$
\widehat X=X_v\odot(1-\alpha+\alpha\widetilde S).
$$

默认 $\alpha=0.6$，所以最低分 token 仍保留 40% 的幅值。它不是只重构被注意力选中的 token，而是对完整的 $N_v\times D$ 表征做软加权。附录 A.1.2 在固定注意力的局部近似下给出 attention 与 value norm 相关的误差上界；原文也明确指出，这不等价于完整重计算条件下的因果归因。

### 2. 用少量压缩 token 预测稠密目标

ETC 引入 $M\ll N_v$ 个可学习压缩 token。训练用 MLP 解码器根据 $(Z,T)$ 预测 $\mu(Z,T)\in\mathbb{R}^{N_v\times D}$，即从少量压缩 token 恢复与完整视觉序列同形状的任务加权 hidden states。§3.3 将目标分布写成逐维高斯：

$$
q(\widehat X\mid Z,T)=\prod_{n,d}\mathcal N(\widehat X_{n,d};\mu_{n,d}(Z,T),\sigma_d^2),
$$

并最小化

$$
\mathcal L_{VID}=\sum_d\left[
\frac{1}{2\sigma_d^2}\sum_n(\widehat X_{n,d}-\mu_{n,d})^2+N_v\log\sigma_d
\right].
$$

$\sigma_d$ 是按通道学习、跨样本共享的方差。因此这里的“变分信息蒸馏”在实现上是带可学习通道不确定性的稠密回归；它降低难以重构通道的权重，但仍依赖高斯、同方差和逐元素误差假设。总损失为任务交叉熵加 $\lambda\mathcal L_{VID}$。

### 3. 压缩发生在执行图的哪里

§3.5 的输入是 `[V; Z; T]`，并使用瓶颈 attention mask：压缩 token $Z$ 可读取完整视觉 token $V$，文本 token 只能读取 $Z$。监督默认放在最终 LLM 层；表 8 显示最终层优于输入层和中间层。

推理时，视觉塔仍产生完整 $V$，LLM prefill 仍让 $Z$ 聚合 $V$；prefill 后才从 KV cache 删除原视觉 token，后续解码只保留 $Z$ 和文本。因此“1 visual token”表示生成阶段只留下一个压缩 token，不表示视觉编码器或整个 prefill 从一开始只处理一个 token。训练期 MLP 解码器用于辅助监督，推理期不需要执行重构。

## 训练、数据与实验设置

- §4.1 使用 LLaVA-v1.5-mix665k，骨干为 LLaVA-1.5-7B 与 Qwen3-VL-2B；视觉塔冻结，训练跨模态 projector 与 LLM。
- 附录表 10：LLaVA 做全量微调，Qwen 使用 rank-8 LoRA，训练 1 epoch；默认 $M=1$、$\alpha=0.6$、$\lambda=10^{-5}$。
- 基线覆盖 FastV、VisionZip、PruMerge、DivPrune 等 token 剪枝/合并方法；指标覆盖通用 VQA、OCR、科学问答、幻觉和 referring expression。
- 表 1–2：Qwen3-VL-2B 在 4/2/1 个压缩 token 下，相对 full-SFT 平均性能分别为 95.68%/94.02%/93.15%。
- 表 3：RefCOCO 的 1-token 结果为 18.73/37.72，完整 token 为 20.78/41.48，说明定位细节仍有损失。
- 表 4：1024→1 token 时，论文报告 KV cache 223.54→10.44 MB、CUDA latency 203.05→114.13 ms、FLOPs 2.98→1.37T；没有单独报告视觉塔、prefill、标签首 token 或 Guard 场景的时延。
- 表 7：无重构/MSE/VID 在 SQA 上为 82.94/84.13/84.43，在 MME 上为 1333.89/1741.05/1838.02，在 QBench 上为 49.70/50.50/53.70，支持稠密重构辅助目标有效，并支持通道不确定性优于普通 MSE。
- 表 9：MLP 解码器优于 Q-Former 与插值；附录图 4 显示 SQA 在约 8 token 后趋于饱和，而 TextVQA 在 32–64 token 仍改善。

## 局限与证据边界

1. 条件充分统计量是理论目标；attention 加权 hidden state 只是可训练代理，未证明对安全证据充分。
2. 重构目标来自 LLM 后层，完整视觉塔和完整视觉 token prefill 已经发生，不能降低视觉编码器主体时延。
3. 论文速度收益混合了 prefill、KV cache 与自回归生成；短输出安全分类可能远小于开放式生成收益。
4. 稠密逐元素重构可能把容量用于背景 token；对小面积文字、隐喻组合和多区域关系的最坏组召回没有验证。
5. 附录 A.2.6 承认极端 1-token 压缩会丢失细粒度信息。

## 对视觉+文本安全判别的迁移价值

### 可直接迁移：训练目标，价值高

可把 ETC 的训练期解码器改成“安全充分性恢复器”：令浅层、固定预算 token 预测完整模型在安全判别相关层的表征、logit、证据区域或多标签风险状态。推理时删除恢复器，保留原模型结构中的浅层退出与固定 $K$ token。相比普通 MSE，它提供三个可直接复用的要素：文本/策略条件化、任务加权稠密目标、按通道不确定性加权。

### 不宜直接迁移：现有执行图，价值低

原实现必须先得到完整视觉 token 并让其进入 LLM prefill，无法实现本课题所需的“视觉编码器前段就减 token、减深度”。对只输出安全标签或少量解释 token 的模型，缓存收益也可能不足以抵消压缩机制。

### 推荐改造

训练时运行完整教师路径，在视觉塔第 $d$ 层建立学生出口并压成固定 $K$ token；训练期恢复器同时预测：

1. 教师的安全 logit 与校准置信度；
2. 安全证据加权的后层视觉表征；
3. 在剪枝前后最易翻转的反事实区域和 hard-negative 关系。

推理时只执行前 $d$ 层、轻量打分/聚合器和原有语言判别头。这样保留 ETC 的“任务充分性蒸馏”，同时把压缩点前移到真正能减少视觉塔 FLOPs 的位置。主要创新不能只写成 attention-weighted reconstruction；需要证明对复杂安全样本的 worst-group recall、遗漏证据上界或自适应升级策略有效。

## 复现实验与未决项

- TODO：在固定输出长度下拆分视觉塔、选择器、LLM prefill、首 token 和完整响应的 P50/P95 时延。
- TODO：比较普通 MSE、ETC-VID、logit KD、关系/Gram 对齐和安全证据加权恢复。
- TODO：分别测小目标、OCR、跨区域关系、图文冲突、隐喻/梗图及越狱提示的召回。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与研究判断分开；未通过本地实验验证。
