---
id: note-2018-burns-women-snowboard
type: paper-note
title: "Women also Snowboard: Overcoming Bias in Captioning Models"
tags: [paper-note, research, vision-language-model, multimodal-safety]
source_id: paper-burns-2018-women-snowboard
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-14
updated: 2026-09-14
---

# Women also Snowboard: Overcoming Bias in Captioning Models

来源：[arXiv 1803.09797v4](https://arxiv.org/abs/1803.09797)；本地原件：`LLM-Wiki/raw/papers/1803.09797v4.pdf`。本笔记核对正文 §1–4、公式 (1)–(6)、Tables 1–3、Figures 1–4 与补充材料；未复现实验。

## 问题与核心判断

论文研究图像描述模型如何把训练集中的性别—场景共现放大：例如模型可能依据 snowboard、kitchen、umbrella 等上下文，而不是人的外观，生成 man/woman。作者的目标不只是减少错误，还要求预测 “right for the right reasons”。

最重要的算法澄清是：**Equalizer 没有在训练时把 attention map 直接拟合到 person mask。** 它把人工认可的证据区域做成反事实干预，通过输出分布损失间接迫使模型依赖该区域；Grad-CAM 与滑窗遮挡 saliency 只在评测时检查模型是否真的指向人。

## 方法

基础模型是 InceptionV3 图像编码器加 LSTM captioner。标准描述损失为：

$$
L_{CE}=-\frac{1}{N}\sum_{n=1}^{N}\sum_{t=1}^{T}\log p(w_t\mid w_{0:t-1},I).
$$

作者使用 COCO person segmentation 构造掩码 $M$：适合判断性别的像素取 0，其余取 1；$I'=I\odot M$ 因而抹去人区域，并用图像平均像素填充。两项新损失互补。

### Appearance Confusion Loss

在原标注词为性别词的位置，对遮挡图 $I'$ 要求 female 词集合和 male 词集合的总概率相等：

$$
C(\tilde w_t,I')=\left|\sum_{g_w\in G_w}p(\tilde w_t=g_w\mid w_{0:t-1},I')-\sum_{g_m\in G_m}p(\tilde w_t=g_m\mid w_{0:t-1},I')\right|,
$$

$$
L_{AC}=\frac{1}{N}\sum_{n=1}^{N}\sum_{t=1}^{T}\mathbf{1}[w_t\in G_w\cup G_m]C(\tilde w_t,I').
$$

实验主体只用 $G_w=\{\text{woman}\}$、$G_m=\{\text{man}\}$。对遮挡图的非性别词仍施加普通交叉熵，让模型继续描述可见物体，又避免 dog、frisbee 等词的表征依赖性别。

### Confident Loss

原图证据存在时，作者不简单提高性别词 CE 权重，而优化正确性别与相反性别的概率比。以 woman 标签为例：

$$
F^W(\tilde w_t,I)=\frac{\sum_{g_m\in G_m}p(\tilde w_t=g_m\mid w_{0:t-1},I)}{\sum_{g_w\in G_w}p(\tilde w_t=g_w\mid w_{0:t-1},I)+\epsilon}.
$$

$F^M$ 对称定义，$L_{Con}$ 只在相应性别词位置取对应项。这个比值只要求正确性别压过错误性别，并未强迫性别词压过 person，因此保留了不确定时输出中性词的通道。

最终目标为：

$$
L=\alpha L_{CE}+\beta L_{AC}+\mu L_{Con},
$$

论文实验设置 $\alpha=\mu=1,\beta=10$（§3.4）。

## 训练、数据与评测

- 数据为从 COCO captions 挖出的 MSCOCO-Bias，以及各取 500 张 man/woman 图的 MSCOCO-Balanced。标签来自描述者用词，不能解释为人的自我认同或生物性别（§2、§4.1）。
- person segmentation 同时用于训练遮挡和评测 “right reasons”；论文指出其他数据可用 person detector 代替（§4.1）。
- 所有模型从训练 100 万步的 Show and Tell 初始化，再在 MSCOCO-Bias 训练 50 万步并微调视觉表征（§4.3）。
- 主要对照为普通微调、训练集重采样平衡、性别词 CE 上调，以及分别移除 ACL/Conf 的消融（§4.4）。

## 主要结果与证据边界

- Table 1：Equalizer 在 Bias/Balanced 集上的性别误判率为 7.02/8.10，Baseline-FT 为 12.83/19.30；完整模型优于任一单损失消融。分布迁移时的提升更明显。
- Table 2：女性图错误率由 Baseline-FT 的 34.11 降到 12.99；男女 Correct/Incorrect/Other 分布的 Jensen–Shannon divergence 由 0.121 降到 0.018。但男性正确率也从 75.05 降至 59.02，模型更多输出中性词。
- Table 3：在 ground-truth caption 条件下，性别词 Grad-CAM pointing-game 的总体命中率从 37.0 提升到 47.5，滑窗遮挡 saliency 从 42.8 提升到 53.7。这支持“更依赖 person 区域”，但最高点命中不是完整因果忠实性证明。
- 标准 caption 质量有代价：METEOR 从 25.2 降到 24.3（§4.5）。低人工一致性样本上模型更保守；至少 3/5 标注者提及性别时，三类准确率优于其他模型（Figure 3）。
- 补充材料显示遮挡测试仍不理想：完整模型在 masked images 上预测 man:woman 比约 1.98，而理想值是 1。这说明 loss 降低但没有消除先验。

## 局限

1. 人工 mask 表达的是设计者认可的证据；衣着是否适合推断性别取决于应用规范，作者明确要求人类判断。
2. 只有二元对称的 man/woman 概率结构；它不能直接外推到多标签、不互斥、严重不均衡的安全类别。
3. 遮挡可能产生分布外纹理，且人区域可能同时遮掉动作、持物与其他任务证据。
4. Pointing game 只检查最大响应点，不能证明全部决策信息都来自合理区域，也不能排除模型继续使用背景。
5. 论文研究 caption correctness/fairness，不研究 token 预算、真实延迟或安全漏报。

## 对安全 Token 剪枝的可迁移结论

可迁移的不是“person mask”本身，而是**双环境约束**：证据存在时判别应有充分 margin；证据被移除时，模型不应继续靠背景保持同样的危险判断。对安全 Guard，应把二类概率相等改写为标签条件的必要性、无关区域不变性与可拒判性，详见 [[LLM-Wiki/research/visual-token-pruning/region-rationale-guided-safety-token-pruning.md]]。

