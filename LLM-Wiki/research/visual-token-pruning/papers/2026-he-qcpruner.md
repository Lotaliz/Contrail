---
id: note-2026-he-qcpruner
type: paper-note
title: "QCPruner: Query-Conditioned Population Coverage for Visual Token Pruning"
authors: [Shengli He, Yongchao Liang, Roumeng He, Junjie Zeng, Jiyuan He, Can Wu, Li Zheng]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-19990
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, training-free, vision-language-model, efficient-inference]
status: active
created: 2026-09-24
updated: 2026-10-13
---

# QCPruner：查询条件的视觉群体覆盖

## 书目信息与阅读边界

来源：[arXiv 2609.19990v1](https://arxiv.org/abs/2609.19990)，首次提交于 2026-09-17，许可为 arXiv non-exclusive distribution license。精读 22 页 PDF 的方法、四 backbone 主结果、成本、全部关键消融和附录校准；阅读原件：[PDF 原文](https://arxiv.org/pdf/2609.19990v1)。未运行代码或模型，数字均为作者报告。

用户从近期索引选中本文；本笔记复用 `paper-arxiv-2609-19990`，将 discovered / unverified 升为 deep-read / source-checked。

## 核心问题与执行位置

独立 relevance 排序容易重复保留相邻 patch；纯多样性/覆盖又可能忽略当前问题。QCPruner 将每个视觉 token 同时视为“需被覆盖的 target”和“可覆盖其他 target 的 representative”，用同一个查询效用在两侧加权，再以 facility-location 选择固定预算集合。

完整方法在 decoder 第 7 层输出后、进入第 8 层前剪枝。所有视觉 token 已经过 0–7 层，因此得到上下文化图文信号，但也支付了这些 dense decoder 层的成本。另设 QCPruner-Early 作为 decoder 前的纯视觉控制，它不使用完整方法的 query cues。

## 查询 anchor 与双 cue 效用

KeyBERT 从用户可见 prompt 抽最多 6 个 content unigram，只用来定位原 prompt 中的 token span；分词后保留所有匹配位置。若无匹配，回退到排除模板、special token 和视觉 placeholder 后的用户内容位置。该规则减少 system scaffolding 稀释，但引入外部 keyword extractor 和语言依赖。

在同一 decoder layer 内，方法计算两类 visual–anchor proxy：

- layer output hidden state 的最大余弦相似度；
- 每个 head 的 pre-softmax query–key scaled dot product 先平均，再对 anchor 取最大值。

两组视觉分数各自做 sample 内 min–max normalization，等权平均后再归一化得到 $u_i$。它们是模型内部相关性代理，不是 attention probability，也不证明因果证据使用。

## 双边加权的 facility-location

先用按 backbone 校准的 floor 收缩效用差距：$\widehat u_i=\rho+(1-\rho)u_i$。视觉 affinity 为非负余弦 $c_{ij}=[\cos(h_i^v,h_j^v)]_+$，边权为

$$
w_{ij}=c_{ij}\widehat u_i\widehat u_j.
$$

选中集合 $K$ 对 target $i$ 的覆盖是 $\max_{j\in K}w_{ij}$，总目标为

$$
F(K)=\sum_i\widehat u_i\max_{j\in K}c_{ij}\widehat u_j.
$$

target-side 效用决定哪些证据值得覆盖，representative-side 效用决定哪些 token 适合代表相似视觉内容。非负 max-coverage 使目标归一化、单调且次模，greedy marginal gain 具标准 $(1-1/e)$ 代理目标近似保证；这个保证不涉及下游准确率。

直接实现需要 dense $N_v^2$ affinity，最坏 selector 时间为 $O(KN_v^2)$。视频按帧独立选择固定配额，不做跨帧动态预算。

## 实验与主要结果

模型覆盖 LLaVA-1.5-7B（576 token）、LLaVA-NeXT-7B（最多 2,880）、LLaVA-Video-7B（64×169）和 Qwen2.5-VL-7B（1,296）。图像任务包括 VQAv2、GQA、VizWiz、ScienceQA-IMG、TextVQA、POPE、MME、MMBench EN/CN、MMVet；Qwen 与 video 使用各自任务组。Avg. Rel. 是任务分数相对 full model 的等权平均，不是平均准确率。

LLaVA-1.5 在 128/64/32 token 时为 99.3%/98.2%/96.1%，相对每档最强 complete-system baseline 高 1.4/2.2/2.2 点。32-token 时 QCPruner 在 GQA、MME、MMBench 等较强，但 VizWiz、POPE 或 MMVet 的单项并非都领先。Qwen 在 512/256/128 token 为 98.5%/96.7%/92.8%，相对该表最强 baseline 的差距为 0.1/4.2/9.9 点。LLaVA-Video 1024/10816 token 为 96.3%，对 FastVID 94.3%；但 FastVID 动态/全局分配，QCPruner 逐帧固定配额，只匹配总 nominal budget。

作者在同一环境复测 baseline，避免直接拼接他论文数字。hook 层在独立 MMStar 校准上选择：第 6→7 层与 9–11 层内部 consensus 的 Spearman/Jaccard 增幅最大；该 consensus 仍是同模型内部 proxy，不是独立 ground truth。utility floor 也用 MMStar/NExT-QA 单独校准，随后跨测试集冻结。

## 成本与消融

LLaVA-NeXT、320/2880 token、RTX 5880 Ada 上，unpruned 的模型轨迹为 32.8 TFLOPs、prefill 271.4 ms、POPE F1 86.5；QCPruner 为 11.1 T、127.5 ms、F1 88.4。相同预算 DivPrune 为 5.0 T、41.8 ms、F1 84.1，QCPruner-Early 为 5.0 T、40.6 ms、F1 84.4。完整 QCPruner 明确以更高保留率换取额外前 8 层与 dense selector 成本。prefill 已含 pruning hook，但不含 1.67 ms/sample 的 anchor 构造；cue、affinity、greedy 的独立耗时未全部拆开。

双边消融中，visual-only/target-only/representative-only/bilateral 在 Qwen-128 为 87.2/87.9/92.6/92.8，在 LLaVA-64 为 95.7/97.3/98.0/98.6。representative-side 是更强的单侧贡献，双边相对它的增益小且设置相关；Qwen-256 两者都为 96.7。受控 selector 比较中 QCPruner 超过 CDPruner-DPP 与 MMTok-style，但这些是固定上游信号后的 backend transplant，不能据此宣布完整系统普遍优于原方法。

## 局限与项目关系

作者明确承认：需要先运行多个 dense decoder 层，dense greedy selection 成本较高；跨层 transfer、grounding、多语言鲁棒性和更广失败分析仍待研究。另有以下边界：

- KeyBERT keyword 与英文 span matching 可能漏掉否定、关系、长政策条款或多语言信息。
- 按帧固定视频配额无法把预算转移到关键帧；utility floor 按 model family 校准，并非免校准。
- 单调次模保证只针对内部覆盖目标；query cues 仍可能错误，不能保证 OCR、小目标或安全证据充分。
- 方法在 LLM 中段剪枝，不节省视觉塔及早期 decoder；当前实现不是最高速度方案。

对当前 policy-conditioned Guard，本文是非常直接的 query-conditioned coverage 基线和新颖性近邻。可复用的是 target/representative 双侧政策效用与受控 selector 消融；需要改变的是把 KeyBERT anchor 换为政策条款/类别结构，并在 pre-ViT 或 early-ViT 获取低成本条件信号。任何“安全充分”主张仍需同图政策翻转、unsafe recall/FPR、token 干预和真实端到端计时。

## 证据定位与待验证项

- query anchor、双 cue 与融合：§3.2–3.3，图 1，式 (2)–(9)。
- 双边覆盖、次模性与 greedy：§3.4，式 (10)–(15)。
- 模型、预算、校准与主结果：§4.1–4.3，图 2、表 1–2。
- 成本与组件/selector 消融：§4.4–4.5，表 3–6；完整校准与 task-wise 表：附录 B–C。
- TODO：固定实现审查；selector/cue/decoder 分项时延；多语言/长政策 anchor；政策翻转、小目标和安全压缩测试。本轮均未执行。
