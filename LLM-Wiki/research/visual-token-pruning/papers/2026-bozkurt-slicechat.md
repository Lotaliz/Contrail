---
id: note-2026-bozkurt-slicechat
type: paper-note
title: "SLICEChat: Progressive In-Encoder Token Pruning for Whole-Slide Pathology Language Models"
authors: [Ali Kerem Bozkurt, Baris Cem Bakay, Ibrahim Kulac, Cigdem Gunduz-Demir, Erkut Erdem, Aykut Erdem]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-24894
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
status: active
created: 2026-09-24
updated: 2026-09-24
---

# SLICEChat：病理全切片图像的编码器内渐进剪枝

## 书目信息与阅读边界

来源：[arXiv 2609.24894v1](https://arxiv.org/abs/2609.24894)，首次提交于 2026-09-21，许可为 CC BY 4.0。精读 15 页 PDF 的方法、三阶段训练、主表 1–8 与计算比较；本地原件：[[LLM-Wiki/raw/papers/2609.24894v1.pdf]]。未运行代码或模型，所有结果均为作者报告。

用户从近期索引选中本文；本笔记复用既有 `paper-arxiv-2609-24894`，将 discovered / unverified 升为 deep-read / source-checked。

## 问题与方法定位

病理 WSI 在诊断分辨率下会产生数千甚至上万 patch token。已有 slide-level MLLM 常在完整 slide encoder 之后再压缩，因此编码器仍处理长序列。SLICEChat 把剪枝插入由 Mamba 与 Transformer 组成的 slide encoder 内部，使后续编码层和 LLM 都看到逐步缩短的序列；这是本文相对 post-hoc WSI 压缩的关键差别。

输入 WSI 被切成无重叠 patch，由冻结的 CONCH v1.5 编码。每个 stage 含三个 Vision Mamba block 和一个 Transformer block；Mamba 负责超长序列传播，Transformer 在逐渐变短的序列上做全局交互。patch 按 row-major 顺序进入编码器，Transformer 使用原始二维坐标的 2D mixed RoPE。

## 渐进语义与区域剪枝

除最后一个 stage 外，每个 Transformer 后插入轻量 router，共五次剪枝。第 $l$ 个 router 用 $m$ 个可学习 query 与该层 token key 做 cross-attention，并对 query 维求均值得到 token 分数；实验固定 $m=1$。给定最终 keep rate $\rho$，每层使用 $k=\rho^{1/L_p}$，令序列长度按 $N_{l+1}=\lfloor kN_l\rceil$ 几何收缩。示例中 4,785 个 token 经五次剪枝变成 957 个，默认最终保留率为 0.2。

作者没有独立删除最低分 token，而是把 patch 坐标临时按 Hilbert 曲线排序，枚举长度等于本层删除量的连续窗口，移除分数和最低的窗口。Hilbert 顺序只用于构造空间连续的候选区域；保留 token 随后恢复 row-major 顺序。这使删除区域更紧凑，但也意味着一次操作必须删除一个固定长度的连续 Hilbert 区间，未提供跨多个离散病灶的最优覆盖保证。

复杂度收益有两处：后续 slide-encoder stage 处理更短序列，最终 LLM 的视觉—视觉 self-attention 从 $O(N^2)$ 降为 $O(\rho^2N^2)$。CONCH patch 编码仍完整执行，早期 stage 也先处理较长序列。

## 三阶段训练与多模态对齐

1. **MAE 预训练**：关闭 pruner，在 11,410 张无标签 TCGA WSI 上训练 hybrid slide encoder；评测 WSI 从该集合移除。
2. **语言监督剪枝**：冻结 slide-encoder backbone 与 PubMedBERT，只更新 attention pooling、pruner 和文本投影。保留 token 的 slide 表征与报告文本做 CLIP 对比学习；pruner auxiliary head 也对同一文本目标优化，使高分 token 支持 slide–text 对齐。
3. **MLLM 对齐与指令微调**：把压缩后的 token 经两层 MLP 投影到 Qwen2.5-VL-7B，并保留其二维坐标用于 M-RoPE；caption 与 VQA 混合训练 projector 和语言模型。

训练成本并不轻：slide encoder 的 MAE 为 4×H200、30 epochs；语言监督阶段为 4×H200、20 epochs；MLLM 阶段为 8×H200、3 epochs。因此方法属于训练参与的编码器内剪枝，不能归入 training-free 插件。

## 实验与主要结果

SlideBench 训练集含 4,181 张 WSI、175,734 个 VQA 对；WSI-Bench 含 9,836 张 WSI、167,425 个 VQA 对。SlideBench 的 TCGA/BCNB overall accuracy 为 79.84/59.09，优于表中最佳 slide-level baseline 的 76.51/54.04。WSI-Bench overall Precision/Relevance 为 0.607/0.776，表中最佳 baseline 为 0.538/0.760。开放式评测原协议的 GPT-4o 端点不可用，作者统一换成 Gemini 3.8 Flash judge，这使结果与原始 WSI-Bench 数字不能直接横比。

在同为 11,948 patches、A100 的比较中，SLICEChat 峰值显存 15.054 GiB、时延 2001 ms；WSI-LLaVA 为 15.048 GiB、1775 ms。因此表 4 支持“第二低时延、相近最低显存”，不支持摘要/结论中的“最低时延”字面说法。作者还说明为另外两种方法整合了预处理脚本，计时实现并非完全原生。

与 DivPrune、PruMerge 的 SlideBench 比较中，SLICEChat overall 为 79.84/59.09，高于 76.58/52.90 与 78.14/57.55。区域删除相对独立 score-based 删除把 TCGA overall 从 78.75 提到 79.84，BCNB 从 59.03 提到 59.09，后者差距很小。keep-rate 消融中 0.2 最好；0.1、0.3、0.5 与 1.0 都较低，说明选择性压缩在该训练配方中也起正则化作用，但不能据此推出任意 WSI 或任务都“越剪越准”。

## 局限与项目关系

- 结果集中在病理 WSI，依赖 CONCH、TCGA 报告监督和大规模分阶段训练；迁移到通用图像或安全 Guard 未验证。
- router 使用一个 learned query，监督来自 slide caption，不是运行时用户问题或政策条件；它学习通用病理语义重要性。
- Hilbert 连续窗口提高空间连贯性，但可能同时删掉窗口内的局部关键证据；正文未报告病灶级召回、最坏样本或校准误差。
- 端到端比较只给一个典型 WSI、batch/hardware 口径有限，且完整 patch encoder 成本仍在。
- 论文没有独立 limitations 小节，表格与摘要/结论的“最低时延”存在表述不一致。

对当前项目最有价值的是“剪枝与编码交替”及“保持二维位置”的直接先例；它进一步削弱“只要把剪枝移到视觉塔内部就新颖”的说法。可迁移假设是用政策条件替代 caption-supervised router，并把区域连续性作为候选约束；但安全任务必须额外检查小目标、文字和违规证据被整块删除的尾部风险。

## 证据定位与待验证项

- 架构、router、几何 keep schedule 与 Hilbert 区域：§3.1–3.3，图 1–3，式 (1)–(9)。
- 三阶段训练与坐标处理：§3.3–3.4，图 4，式 (10)–(12)。
- 数据、主结果与计算：§4.1–4.2，表 1–4。
- 剪枝器、区域、keep rate 与 backbone 消融：§4.3，表 5–8。
- TODO：固定代码版本核对；含 patch encoder/preprocessing 的多 WSI 时延分布；区域级关键证据召回；安全 Guard 迁移。均未在本轮执行。
