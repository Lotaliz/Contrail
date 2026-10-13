---
id: note-2026-wang-trevs
type: paper-note
title: "TReVS: Integrating Textual Relevance and Visual Saliency for Efficient Vision-Language Model Token Pruning"
authors: [Jing Wang, Zhiping Wu, Dongdong Ren, Youfang Han, Wei Zhao, Wenbin Li]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-37581
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, training-free, vision-language-model, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-13
---

# TReVS：两阶段保留查询证据

## 原件与阅读边界

用户从候选索引选择本文。原文为 [arXiv 2609.37581v1](https://arxiv.org/abs/2609.37581v1)，arXiv non-exclusive distribution license；完整 HTML 原件见 [HTML 原文](https://arxiv.org/html/2609.37581v1)。核对全部方法 §3–4、实验 §5、图 2–5 和表 1–5。未检查实现或运行模型；数字均为作者报告。

PDF 原件另见 [PDF 原文](https://arxiv.org/pdf/2609.37581v1)（9 页）；完整文件已解析，关键图表与 HTML 数字交叉核查，SHA256 登记在同一 source_id 的 local_artifacts。

## 执行位置与选择规则

作者指出两阶段剪枝的首阶段如果仅按视觉显著性删 token，后面的 query-aware decoder 无法恢复已删证据。TReVS 不改模型参数，在**完整视觉塔和 projector 后、LLM 前**做第一次筛选，再在第八个 LLM 层之后做第二次筛选（§4、§5.1）。它不节省前端视觉编码，不能视为 pre-ViT 方案。

第一阶段以倒数第二 ViT 层的 CLS attention 均值作视觉显著性；对 projected visual tokens 和输入文本 token embeddings 的 cosine 取正部分，再按文本位置做 RMS，得到文本相关度。两种分数独立以 median/MAD 标准化、负值截零及温度缩放，默认视觉/文本温度 1.4/1.0。融合为

$$s_i=\max(\hat s_i^v,\hat s_i^t)+\lambda\sqrt{\hat s_i^v\hat s_i^t},\qquad\lambda=1.$$

先取 top-$K_r$ pivot，再从剩余 token 用 cosine-distance FPS 补 $K_d$ 个多样性 token，默认 $K_r:K_d=3:1$。这种 token embedding 匹配没有显式句法、否定或关系建模，不能预设它理解复杂政策组合。

第二阶段先对每个 attention head 的 text→vision 权重计算视觉位置方差，再对文本位置取平均，保留方差最高的一半 heads；视觉 token 分数是在这些 heads 平均后、对文本位置取最大 attention，取 top-$K_2$。默认 $K_1:K_2=3:1$，所以首阶段保留更多输入，再在主干内缩减。

## 原文分析与结果

§3.2 在 1,000 张有两个不同问题的 TextVQA 图像上，以两问 attention 的 $1-\cos$ 衡量 text sensitivity；高方差 head 子集平均更敏感，早期层还有位置偏置。这是支持启发式的经验关联，attention 集中或对问题变化不等于答案证据充分。

§5 的三个 backbone：LLaVA-1.5-7B（576 视觉 token）、LLaVA-NeXT-7B（2,880）、Video-LLaVA-7B（2,048）；图像使用 GQA、ScienceQA-IMG、TextVQA、POPE、MME、MMBench 英/中，视频使用 TGIF/MSVD/MSRVTT-QA。

- 表 1 在 LLaVA-1.5 平均预算 128/64/32 时相对平均性能为 98.8/96.5/92.8%；32 档 DivPrune 90.4、VScan 91.5、DUET-VLM 91.6。RelAcc 是逐 benchmark 相对 full 的平均，不是原始准确率。
- 表 2 高分辨率平均预算 320/160 时 RelAcc 为 96.6/93.0；GQA 仍落后最佳方法 0.5/0.6 个百分点。作者提出高方差 heads 偏向稀疏细节、可能损失全局关系；这是解释假设，未独立证明。
- 表 3 视频 136 平均 token 时保持 99.0%；TGIF 略高于 full，但 MSVD/MSRVTT 均略低，不能说每项性能保持不变。
- 表 4 的 32 档四任务消融为 CLS+all heads 91.8、TReVS 首阶段+all heads 92.7、再选高方差 heads 93.2。该聚合只覆盖 TextVQA/MMBench/GQA/POPE，与表 1 的任务集合不同，不是 92.8 与 93.2 的矛盾。

## 计时和复现缺口

§5.4 表 5 在 RTX 4090、POPE、LLaVA-1.5 按样本报告：full 的 total/prefill 为 126.5/72.7 ms，32 档为 88.9/33.5 ms，约 1.4×/2.2×；KV cache 从 321.1→49.7 MB。64→32 的 prefill 几乎不再降低（33.7→33.5），表明极限预算收益受早期层或额外开销限制。

这些表以“平均 retained token”匹配预算，不能把 32 当作每层或最终 $K_2$ 恒为 32；复现仍需核对整数 $K_1/K_2$ 和层数加权口径。原文没有充分拆出 RMS/FPS/head selection 开销，也未完整给出 batch、warmup、同步、解码长度分布和 kernel 选择。POPE 短输出的 E2E 不能替代长回答或多样本服务测试。

## 与项目和已有方法的关系

与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 相比，它更早引入 projected-text 匹配，后段以 head 方差排序，未优化集合级 query-conditioned coverage；与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]] 相比，文字条件没有进入视觉塔的早期计算。二者不能仅凭删除率作同速比较。关联概念为 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]。

**本项目判断：** 可以作为完整视觉特征可用时的 training-free 政策条件 baseline，并用于验证“只用视觉 saliency 会不会丢掉政策指定证据”。迁移到 C5 的单局部框/低清 router，需要重新验证文本条件成本、同图政策翻转、关系/否定、小目标与 unsafe recall；本文没有这些安全保证。本轮不增加新 concept 或正式 gap。
