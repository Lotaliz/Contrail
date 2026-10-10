---
id: note-2026-jeong-refit
type: paper-note
title: "Adaptive Visual Token Reduction for Accelerated Image Understanding"
authors: [Seyoung Jeong, Jong Pil Yun, Sang Jun Lee]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-09252
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

# ReFIT：指令相关窗口重塑与裁图内 token 细化

## 原件与阅读范围

[arXiv 2610.09252v1](https://arxiv.org/abs/2610.09252v1)，arXiv perpetual non-exclusive license；完整原件见 [[LLM-Wiki/raw/papers/2610.09252v1.html]]。精读完整 §1–4、式 1–6、图 1–2、表 1–4。全文可访问，但公开稿的训练/预算细节不足；这里的 deep-read 表示完成全文分析，不表示可以据此完整复现。未运行实验。

另保存 [[LLM-Wiki/raw/papers/2610.09252v1.pdf|完整 PDF]]（5页），全页解析并视觉核查第3页表1及RWR/ITR说明。HTML/PDF的主要结果一致；参考文献编号不同，笔记使用稳定章节/表号定位。

## 方法和训练边界

§2、图 1：先对输入图像做多分辨率视觉编码与投影，形成二维 token 网格和窗口；指令 embedding 投影到共享空间。RWR 用逐指令 token 的最大视觉相似度再对指令取平均，为窗口打分。按高分窗口的空间分布水平或垂直合并 **2–4 个相邻窗口**，适应长文字/表格结构；再从原图裁取、重新编码相关区域。这不是首次视觉编码前的单次选择。

§2.3：ITR 在重编码后的 token 上计算与指令的 cosine，相似度经温度 softmax 后加权求和，再做 min–max 归一化。RWR 的 top-2 区域内 token 被标记为 Protected，其他 token 按 relevance 分为 Retained/Removed，最终紧凑序列送入 LLM。

§3.1：LLaVA-NeXT-Vicuna-7B 的 vision encoder、projector、LLM 冻结，仅优化新增模块。**原文未完整给出**训练数据规模/标签/损失、优化配置、ITR retained 阈值、窗口扩展的确定规则、最终 token 数和各基线 matched 预算协议。不能将示意流程补成作者未写的可复现算法。

## 数据、结果与反例

表 1：InfoVQA/SPDocVQA/MPDocVQA 用 ANLS，GQA 用准确率；基线含 random、ToMe、FastV、Pdrop、SparseVLM、PinPoint。ReFIT 在 MPDocVQA 为 0.4125、27.91 T FLOPs，vanilla 为 0.3758、50.01 T；GQA 为 0.7669、14.94 T，vanilla 为 0.7598、30.39 T。这里的 GQA 原始得分不可与其他论文不同 split/protocol 的数值直接排序。

表 2：PinPoint 基础的四任务为 0.3024/0.6472/0.3866/0.7608；RWR+ITR 为 0.3189/0.6638/0.4125/0.7669，两组件各有增益。表 3 并非每项都是 RWR 最好：random multi-window 的 SPDocVQA ANLS 为 0.6643，高于 0.6638；InfoVQA region accuracy 也更高。表 4 ITR 对文档任务与 random/connected 的差距很小，GQA 差距较大；缺重复运行、误差区间和匹配成本，不能由这些小差异断言机制优势稳健。

## 效率与当前项目的关系

文章仅报告 FLOPs，没有 wall-clock、TTFT、decode、显存或服务吞吐，也没有清楚分解初次多尺度编码、裁图重编码和选择器的 FLOPs。**作者的计算量降低不等于已证明部署加速。** 对信息密集文档的优势也不能直接推广到政策 Guard。

关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-niu-evivit.md|EviViT]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-han-foveated-compression.md|Foveated Compression]]。EviViT 在视觉层中重读，本文先编码再裁图重编码；Foveated Compression 在一次完整编码后恢复已有 native token，不再读取像素。

**本项目判断：** RWR 的横/纵扩展可供 Cx 单框形状候选参考，Protected 区域可作证据保护对照，但本文的多区域与语义相关性并未验证 Cx 的政策条件收益、单框充分性或局部 0/8/16 配置。TODO：先核验模块监督和代码，再做同框同预算对照、只打乱 selector 政策、完整前端/E2E 计时；当前证据不足以据此改变主方案或建立新 concept。
