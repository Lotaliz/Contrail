---
id: note-2026-bercy-g2tm
type: paper-note
title: "Decoder-Agnostic Token Merging for Vision Transformers: A Systematic Study of G2TM"
authors: [Victor Bercy, Martyna Poreba, Michal Szczepanski, Samia Bouchafa]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-18279
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, token-merging, vision-transformer, semantic-segmentation]
status: active
created: 2026-09-20
updated: 2026-10-20
---

# G2TM：解码器无关的 ViT 早期 Token 合并

## 书目信息与阅读边界

来源：[arXiv 2609.18279v1](https://arxiv.org/abs/2609.18279)，首次提交于 2026-09-16。arXiv 页面将其标为早期 G2TM 工作的扩展版本，并列出 related-resource DOI `10.5220/0014267600004084`；该 DOI 不作为本预印本的身份 DOI。页面备注“to be published in CCIS”，本轮未独立核验正式出版状态，venue 仍记为 arXiv。

精读范围：27 页 PDF 的 §3–6、图 1–6、表 1–11；重点核对模块插入位置、训练/推理差异、解码器适配、ADE20K/ImageNet-1k/Cityscapes 结果及预训练敏感性。阅读原件：[PDF 原文](https://arxiv.org/pdf/2609.18279v1)。没有运行代码、训练模型或复现实验；以下结果均为作者报告。

## 问题与核心假设

多数 token merging 工作只在一种架构中验证，难以区分收益究竟来自合并机制本身还是特定 decoder。作者用 Segmenter、SETR、EoMT 的线性、Transformer 和卷积式 decoder 做系统比较，并进一步测试 ImageNet 分类。

核心假设是：若合并只依赖 ViT 浅层相邻 token 的特征相似度，合并行为应主要由 encoder 表征决定，而对下游 decoder 较稳定。实验支持了“同一 backbone、预训练和数据集内，token 数与合并尺寸跨 decoder 近似稳定”，但也显示阈值不能跨预训练配方或数据集直接迁移。

## 方法

### 单次浅层图合并

G2TM 只插入一次，位置是 ViT 第 1 或第 2 个 block 的 attention 与 residual 之后，而不是逐层反复合并（图 1，PDF 第 6 页）。对 $N$ 个 patch token 建立二维网格图，只计算每个 token 与右侧、下侧邻居的余弦相似度：

$$
\operatorname{cs}_{i,j}=\frac{t_i^\top t_j}{\max(\lVert t_i\rVert_2\lVert t_j\rVert_2,\epsilon)}.
$$

固定阈值 $\tau$ 删除低相似度边，然后用 BFS 找连通分量。每个分量内的 token 以无权平均融合成一个代表 token。设计依赖空间相邻性，因此不会直接合并远距离但语义相似的区域；同时它也没有文本或任务查询条件。

### 训练与推理路径

动态连通分量导致每个样本的序列长度不同。训练时为维持批处理，作者不真正缩短张量，而是在后续 self-attention 中屏蔽已并入代表的 token；经过剩余 encoder 后，把代表 token 复制回分量内原位置再交给 dense decoder。推理时 batch size 为 1，才物理删除被合并 token，最后按 decoder 需要恢复稠密网格（§3.5，PDF 第 9–10 页）。

Transformer decoder 可以在稀疏序列上继续计算并推迟 unmerge；需要卷积或上采样的 decoder 必须更早恢复。这解释了相同 encoder 合并量可跨 decoder 稳定，而端到端速度仍受 decoder 计算占比影响。

### 阈值课程

作者通常在第 1 层用较高阈值、在第 2 层用较低阈值，并通过阈值课程从弱合并逐步降到目标阈值。ADE20K 的最终阈值为第 1 层 0.95 或第 2 层 0.88；ImageNet 第 2 层为 0.86；Cityscapes 最佳设置为第 2 层 0.95。表 2 给出不同训练阶段的 epoch 分配。

## 实验与主要证据

### 设置

语义分割使用 ADE20K 512×512，覆盖 Segmenter、SETR 与 EoMT；补充 Cityscapes 768×768 和 1024×1024。分类使用 ImageNet-1k。指标包括 mIoU/Top-1、fvcore GFLOPs、剩余 token 数、合并分量平均尺寸，以及单张 NVIDIA A100-80GB、batch size 1 的中位 FPS（§4.4，PDF 第 11 页）。除 EoMT 预训练消融外，分割 encoder 使用 AugReg 初始化。

### ADE20K 与 decoder 稳定性

表 3（PDF 第 13–14 页）显示，同一 SETR-B backbone 的 Naive/PUP/MLA decoder 在第 2 层设置下分别剩余 622/630/628 个 token，支持合并统计对 decoder 不敏感。Seg-L + Mask Transformer 从 52.3 mIoU、14.9 FPS、400.08 GFLOPs变为：

- 第 1 层合并：52.0 mIoU、20.4 FPS、284.58 GFLOPs；
- 第 2 层课程合并：50.3 mIoU、26.0 FPS、210.96 GFLOPs。

这给出一个保真与吞吐的可调折衷，但不是“无损”。作者总结：选择合适的第 1/2 层设置时，ADE20K 多数模型可将 mIoU 下降控制在 2 点内，GFLOPs 降低 22%–47%，吞吐最高提高 74%。

轻量模型暴露了 FLOPs 与实测速度的差异。Seg-T 的 GFLOPs 从 10.65 降至 7.06/6.57，但 FPS 从 174.1 降至 164.1/160.7；合并开销超过后续 attention 节省。作者据此将可见吞吐收益限定在原模型约低于 100 FPS 的设置，而不是把计算量下降直接等同于加速。

### 分类、数据集与预训练敏感性

ImageNet 表 4（PDF 第 15 页）中，ViT-B 在第 1 层合并时 Top-1 保持 84.8，FPS 由 88.0 提高到 101.6；ViT-L 第 2 层从 86.2/31.6 FPS 变为 85.5/44.8 FPS。ViT-T/ViT-S 即使 GFLOPs 下降，FPS 仍下降，重复了轻量模型的开销边界。

预训练是明显失败条件。EoMT-L 使用 AugReg 时，第 2 层合并从 52.3 降到 52.2 mIoU；换成更强的 DINOv2 初始化后，基线为 58.1，但相同配置降到 49.3。作者发现 DINOv2 的相邻 token 余弦集中在 0.99–1.0，使阈值失去区分力；将合并移到第 3 层、阈值 0.90 后恢复到 56.7（表 9、图 6，PDF 第 20–21 页）。因此“decoder agnostic”不能扩展成“表征分布 agnostic”。

Cityscapes 从 768 提升到 1024 分辨率时，同一数据集上的阈值仍可工作；但从 ADE20K 切换到 Cityscapes 必须重新调参。证据更支持“每个预训练配方和数据集校准一次”，不支持跨域固定阈值。

### 消融与定性边界

比例注意力在 ImageNet 上影响很小，在 ADE20K 上一致伤害 mIoU（表 5–6）。把 merged token 的面积当作重要性先验不适合小物体与边界必须保真的 dense prediction。off-the-shelf 合并在分类上较可行，在大多数分割模型上需微调补偿（表 7–8）。定性图显示大面积均匀区域更易合并，但论文没有用小目标召回或最坏区域指标量化这一结论。

## 作者主张、证据与局限

论文充分支持：G2TM 的 token 数和分量尺寸在给定 encoder、预训练与数据集下跨多类 decoder 近似稳定；大中型 ViT 上早期单次合并可同时减少 GFLOPs 并提高 batch-1 吞吐；分类比分割更容忍合并。

证据不足以支持：阈值无需校准、所有架构都会加速，或相似 token 一定语义冗余。主要边界包括：

- 需要任务训练或微调的路径才是主要分割结果；训练时并未真实缩短 batch 张量。
- 相似度分布会随预训练配方剧烈变化，DINOv2 是直接反例。
- 实测速度仅为 A100、batch 1、视觉模型任务；没有 MLLM prefill、生成、KV cache 或并发服务结果。
- 没有文本条件、策略条件或安全证据约束；平均 mIoU/Top-1 无法保证小区域恶意证据保留。

## 对当前项目的影响

G2TM 是当前 Wiki 中“完整视觉塔之前真实缩短 token 序列”的直接近邻：插在第 1/2 个 ViT block 后，符合浅层压缩的位置要求。它适合作为无文本、局部相似度驱动的 early-encoder merging 基线，并提供两个必须纳入实验设计的反证：轻量模型 FLOPs 下降可不加速；强预训练特征过度同质时相似度阈值会失效。

对安全项目的迁移仍是待验证假设。可比较“纯局部相似度合并”与“政策/文本条件的证据选择”，重点测小型有害区域、OCR 字符、跨分辨率阈值迁移和 unsafe 漏报；不能把连通分量的空间连贯性称为安全充分性。该笔记补充机制与基线，不修改正式 motivation。

关联：[[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md|浅层视觉编码器剪枝与解释性]]；[[LLM-Wiki/research/visual-token-pruning/token-merging-landscape.md|视觉 Token 合并方法比较]]；[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]。

## 证据定位与待验证项

- 插入位置、图构造、阈值、连通分量与训练/推理差异：§3、图 1–2，PDF 第 6–10 页。
- 训练设置、阈值课程、速度口径：§4、表 2，PDF 第 10–11 页。
- decoder 比较与 ADE20K 结果：§5.1、表 3，PDF 第 12–15 页。
- 分类、比例注意力、off-the-shelf 与预训练失败：§5.2–5.4、表 4–9，PDF 第 15–21 页。
- 数据集/分辨率迁移与结论：表 10–11、§6，PDF 第 21–23 页。
- TODO：固定代码 revision；核查 CCIS 正式出版；在 MLLM 视觉塔内复现 batch/吞吐；安全小目标与最坏样本评测。均未在本轮执行。
