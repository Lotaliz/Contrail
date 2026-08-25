---
id: paper-note-chang-2023-stvit
type: paper-note
title: "Making Vision Transformers Efficient From a Token Sparsification View"
authors: ["Shuning Chang", "Pichao Wang", "Ming Lin", "Fan Wang", "David Junhao Zhang", "Rong Jin", "Mike Zheng Shou"]
year: 2023
venue: "CVPR 2023"
source_id: paper-chang-2023-stvit
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: [vision-transformer-token-pruning-basics]
created: 2026-08-24
updated: 2026-08-24
---

# Making Vision Transformers Efficient From a Token Sparsification View

## 书目信息与阅读范围

- 正式题目：*Making Vision Transformers Efficient from A Token Sparsification View*，CVPR 2023。
- 本地证据：`raw/papers/2023-chang-stvit.pdf` 与 `raw/papers/2023-chang-stvit-supplement.pdf`；均为 CVF 提供的 accepted-version PDF。
- 阅读层级：`deep-read`。已核对正文方法、训练/推理设置、Tables 1–9、补充材料架构/复杂度/语义分割/消融与理论分析；未执行代码复现，因此 `verification` 仍为 `source-checked`。
- 与项目的相关性：高。它不是“给 patch 打分后删除”的典型硬剪枝，而是用少量聚类中心式语义 token **凝聚并替换**大量 image token，正好揭示“token 数量减少”与“信息不可逆丢弃”之间的边界。

## 研究问题与作者假设

作者针对三项困难提出统一方案：预定义重要性分数会导致大幅精度损失；剪枝后的不规则空间分布难以用于局部窗口 ViT；大规模删除 token 会损坏位置与空间结构，妨碍检测、分割等密集任务（摘要、§1，pp. 6195–6196）。

作者的核心假设是：ViT 深层真正需要的是少量高层语义表示，而非始终维持完整规则网格；若自注意力能够从 image token 中恢复聚类中心，就能用少量 semantic token 替代大量 patch/image token。这个假设在正文以注意力可视化支持，并在补充材料 §A.7 的分离高斯簇假设下给出理论化分析，但该理论模型不是自然图像特征分布的直接证明。

## 方法：STViT

### 1. 基础模块与 STGM

1. patch embedding 与前若干浅层 Transformer 保持不变，先处理全部 image token $X\in\mathbb{R}^{N_i\times C}$，提取低层特征。
2. Semantic Token Generation Module（STGM）默认占用两个原有 Transformer 层。第一层用空间池化得到的初始中心作 query，以 image token 作 key/value；第二层继续聚合，并通过高斯初始化的 global cluster centers 引入全局语义（§3.1，Eqs. 1–3，pp. 6197–6198；Fig. 2a）。
3. STGM 不更新原 image token；生成 $N_s$ 个 semantic token 后，原 image token 被丢弃，后续层仅处理 semantic token。默认 STViT-DeiT 在 14×14=196 个 token 上运行 4 层 base、2 层 STGM，余下 6 层处理 4×4=16 个 semantic token（补充材料 §A.1，Table 1）。

### 2. 空间初始化与局部 ViT

对 $H\times W$ 特征图，作者划分 $w_s\times w_s$ 个区域，每区通过 intra-window mask 汇聚一个初始中心，再由 inter-window offset 调整中心，目标是兼顾局部语义与中心间差异（§3.1，Eqs. 4–5，p. 6198）。在 Swin 中，每个 7×7 局部窗口默认生成 3×3 个 semantic token，并用较大 key/value 窗口缓解局部视野限制；跨窗口连接通过更大的滑动窗口完成（§3.2，pp. 6198–6199）。

### 3. STViT-R：为密集任务恢复空间

STViT 的直接副作用是几乎丢失全部细粒度位置。STViT-R 用反向 cross-attention 让原分辨率 image token 以 semantic token 为 key/value 恢复表示（§3.3，Eq. 6，p. 6199），并把“全 token 层 → STGM → semantic-token 层 → recovery”组成 dumbbell unit，周期性压缩、计算和恢复。Swin-S 的代表配置在 Stage 3 串联三个各含 6 个 Transformer 层的 dumbbell units（§3.3，Fig. 2b）。

## 训练与推理流程

### 图像分类

- 数据：ImageNet-1K，1.28M 训练图像、50K 验证图像、1,000 类；训练与推理默认 224×224。
- 训练：DeiT/Swin 变体均从头训练 300 epochs，batch size 1,024，沿用原模型增强与正则化，不使用知识蒸馏。
- 输出头：最后一层 token 做 global average pooling，再接线性分类器；报告 single-crop Top-1。
- 效率测量：FLOPs 用 fvcore；throughput 在 V100、batch size 128 下测量。论文没有给出 batch=1 端到端时延、P50/P95 或 selector/recovery 的独立 wall-clock 开销。

以上均定位于 §4.1 Settings，p. 6199。

### 视频与密集任务

- 视频：ImageNet-1K 预训练的 Video Swin，在 Kinetics-400 训练；每帧生成 semantic token，4×3 views，速度用 FPS（§4.2；Table 6，pp. 6201–6202）。
- 检测/实例分割：ImageNet-1K 预训练的 STViT-R-Swin，Cascade Mask R-CNN 3× schedule，COCO 2017（§4.3；Table 5）。
- 语义分割：UperNet，ADE20K，240K iterations，多尺度推理；该任务只在补充材料报告（§A.4，Table 5）。

推理时不做反向传播；STGM 根据当前样本生成 semantic token，后续层在缩短的序列上运行。对于 STViT-R，恢复层会重新引入规则空间 token，因此密集任务的净收益取决于“压缩区间节省”能否覆盖生成与恢复成本。

## 实验设置、基线与指标

- 主干：DeiT-T/S/B（全局注意力）、Swin-T/S/B（局部窗口注意力）、Video Swin、LV-ViT-S。
- 任务/数据：ImageNet-1K 分类、Kinetics-400 视频分类、COCO 2017 检测与实例分割、ADE20K 语义分割。
- 对比方法：DynamicViT、IA-RED²、PS-ViT、TokenLearner、DGE、A-ViT、Evo-ViT、EViT 等；Table 4 明示部分方法不是标准 DeiT base，因此主要用相对基线精度差 $\Delta$ 比较。
- 指标：Top-1、FLOPs、throughput/FPS；COCO 的 box/mask AP；ADE20K 的 mIoU。

## 主要结果：作者主张与直接证据

| 场景 | 直接证据 | 可支持的结论 |
|---|---|---|
| DeiT 分类 | 16 semantic tokens 时，T/S/B Top-1 分别保持 72.2/79.8/81.8；FLOPs 均 -58%；throughput +101%/+105%/+110%（Table 1，p. 6200） | 在论文训练与测量设置内，强凝聚可保持分类精度并显著降低计算 |
| Swin 分类 | 每窗口 9 token 时，T/S/B Top-1 相对 +0.2/0.0/-0.1，FLOPs -24%/-25%/-25%；每窗口 4 token 则 -0.5/-0.6/-0.5（Table 2，p. 6200） | 局部 ViT 对 token 数更敏感；压缩预算不能直接照搬全局 ViT |
| STViT-R 分类 | Swin-S/B Top-1 均 -0.3，FLOPs -33%，throughput +30%（Table 3，p. 6200） | 恢复模块并未完全抵消分类效率收益 |
| 与剪枝方法比较 | DeiT-S/B 的 STViT 均报告 -58% FLOPs、相对基线 0.0 Top-1 损失（Table 4，p. 6201） | 在表内口径下优于所列方法；跨实现、公平训练和硬件一致性仍需复核 |
| 视频 | Swin-T/S 均 Top-1 -0.3、FLOPs -27%、FPS +25%（Table 6，p. 6202） | 方法可扩展至每帧 token 的视频分类 |
| COCO 密集任务 | STViT-R-Swin-S：box/mask AP 51.8/44.7 不变，backbone FLOPs -31%；B：52.2/45.2，较基线 +0.3/+0.2，FLOPs -32%（Table 5，p. 6202） | 周期性恢复足以在该检测框架中保留任务质量 |
| ADE20K 语义分割 | STViT-R-Swin-S/B mIoU 48.3/48.9，较基线 -1.0/-0.8；FLOPs 均 -31%（补充材料 §A.4，Table 5） | 像素级任务仍明显受细节损失影响，不能由 COCO 结果概括为“所有密集任务无损” |

## 消融、失败条件与边界

1. **初始化缺一不可。** DeiT-S 仅 spatial、仅 global、两者结合的 Top-1 为 79.4、78.7、79.8；把 global center 当 learned position 加入 key 得 79.7（Table 7，p. 6202）。
2. **更深 STGM 不一定更好。** 2/3/4 层对应 79.8/79.5/79.6 Top-1，FLOPs 1.91/1.97/2.03G（Table 8，p. 6202）。
3. **压缩位置有精度—计算折中。** STGM 从 layers 3–5 移至 8–10，Top-1 从 79.3 升至 80.3，但 FLOPs 从 1.56G 升至 3.30G；10–12 又回落到 79.8（补充材料 §A.6，Table 6）。
4. **位置编码基本无益。** learned/conditional/relative/no position 在 DeiT-S 为 79.6/79.7/79.8/79.8；Swin-T 为 81.5/81.4/81.3/81.5（补充材料 Table 7）。
5. **恢复仍不等于保真。** 去掉 dumbbell unit 后 box/mask AP 从 51.8/44.7 降为 51.4/44.4；复用旧 semantic token 为 51.6/44.5（Table 9，p. 6202）。语义分割更直接暴露高频和像素细节损失。
6. **任务目标冲突。** LV-ViT 的 token labeling 强调位置对应，而 STViT 强调高层凝聚，36 token 时仍有 -0.6 Top-1（补充材料 §A.3，Tables 3–4）。
7. **工程证据有限。** throughput 仅来自 V100、batch=128；没有多硬件、batch=1、端到端 latency、峰值显存或能耗报告。作者“无部署开销”的表述不能由这些数据充分推出。
8. **理论外推有限。** 补充材料 §A.7 在良好分离的高维高斯簇、充分样本等假设下分析注意力恢复中心；它解释机制可能性，不证明真实 ViT token 必然满足条件。
9. **来源异常。** 补充材料 §A.2 在定义 image-token 数为 $N$、semantic-token 数为 $M$ 后写出“$N\ll M$”；结合全文 196→16 与公式语境，应为排版笔误。本文只记录异常，不替来源静默改写。

## 复杂度解释

补充材料 §A.2 给出全局注意力对 image token 的复杂度 $4NC^2+2N^2C$，FFN 为 $8NC^2$；semantic token 把 $N$ 换成更小的 $M$。因此 token 数下降同时减少注意力的二次项和 FFN 的线性项。STGM 自身含 cross-attention 的 $MN$ 项，所以理论 FLOPs 下降不会自动等于真实时延下降，仍须计入数据布局、窗口操作、kernel 和恢复模块。

## 论文结论与本文判断的分离

- **作者主张：** 少量高层 semantic token 可替代大量结构化 image token，并在全局/局部 ViT、视频与部分下游任务上取得更优效率—精度折中。
- **直接证据支持：** ImageNet、Kinetics-400 与 COCO 的表内结果支持该主张在指定模型和训练协议内成立；ADE20K 显示“密集任务普遍无损”不成立。
- **本文综合判断：** STViT 更适合作为“token 凝聚 + 可恢复表示”的架构级基线，而不是任意预训练 ViT 上的无训练剪枝器。它对入门读者最重要的启示是：应先问 token 承载什么信息、任务是否需要空间对齐，再决定删除、合并、凝聚或恢复。
- **未验证假设：** 若把 STViT 的预算选择改为目标硬件时延约束，可能改善实际部署收益；当前论文没有对此提供证据。

## 与已有概念和项目的关系

- 基础阅读：[[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|视觉 Transformer 与 Token 剪枝基础]]。
- 项目定位：[[LLM-Wiki/research/visual-token-pruning/overview.md|视觉模型 Token 剪枝研究总览]]。
- 与 ToMe 的关系：二者都避免“只删除不保留”，但 STViT 需训练语义中心和架构改造，ToMe 是相似 token 的推理期合并基线。
- 对后续实验的影响：统一测试应分别报告分类与密集任务、batch=1 时延与 batch throughput，并把 STGM/recovery 的开销单列。

## 待验证问题

- 官方实现能否在同一 V100 与现代 GPU 上复现 Table 1 的 throughput 增益？
- batch=1、动态 shape、TensorRT/ONNX 等部署环境中，STGM 与 recovery 的净开销是多少？
- COCO 小目标增益是否跨检测器、随机种子与训练 schedule 稳定？
- 能否通过保留高频残差、边界 token 或多尺度恢复缩小 ADE20K 的 mIoU 缺口？
