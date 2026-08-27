---
id: visual-token-pruning-multimodal-survey
type: synthesis
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-khare-2025-superserve, paper-wee-2025-pudding]
status: active
created: 2026-08-24
updated: 2026-08-26
title: 图文多模态模型 Token 剪枝：分类、生成与新挑战
synthesis_kind: literature-review
---

# 图文多模态模型 Token 剪枝：分类、生成与新挑战

## 结论先行

1. **是热门研究点。** 正式论文从 EMNLP 2022 的视觉编码器内文本指导选择、ACL 2023 的图文联合 pruning/merging，发展到 ECCV 2024 的 decoder 内 training-free pruning；2025 年 CVPR、ICML、ACL/EMNLP 同时出现多条独立路线，ACL 2026 又开始优化完整 layer-wise configuration。论文密度、会议分布和问题细化共同表明它已从零散技巧进入快速扩张期。
2. **但研究热度主要集中在 MLLM 的视觉 token 缩减，而不是所有模态的统一剪枝。** “联合剪视觉与文本”“生成过程中动态改变视觉证据”“多轮 cache 可逆更新”“硬件感知 P95 优化”仍不成熟。
3. **相比纯视觉，核心难题从‘哪个 patch 重要’变成‘哪个视觉证据对当前问题、未来生成和后续轮次都足够’。** 查询相关性、空间覆盖、多样性和未来可复用性相互冲突。
4. **分类结论不能直接迁移到生成。** 自回归模型还要处理 prefill/decode 分离、KV cache、输出长度、错误累积与幻觉；FLOPs 或 token ratio 无法独立说明用户可感知的加速。

## 调研范围与检索设置

- 时间截点：2026-08-24；核心追溯到 2022 年文本指导 VLP，重点覆盖 2023–2026 正式会议论文。
- 来源：ACL Anthology、ECVA/ECCV、CVF Open Access、PMLR/ICML；仅以正式论文与官方 proceedings 为主要证据。
- 关键词：`vision language token pruning`, `multimodal LLM visual token pruning`, `text-guided patch selection`, `visual token compression`, `prefill KV cache multimodal`, `multi-turn visual token pruning`, `Pareto pruning configuration`。
- 纳入：确实减少图像/视频/文本 token，且报告图文分类、检索、VQA、captioning、开放式生成或视频理解质量。
- 邻接但不作为核心：只改视觉编码器架构、只换 resampler/projector、纯文本 KV pruning、只压权重/注意力头、纯图像生成 DiT token reduction。
- 覆盖限制：不是穷举；2025–2026 论文数量快速增长，本页优先选取能代表机制演进、生成系统指标或反例的八篇。

## 从纯视觉到图文多模态：问题如何改变

### 纯视觉模型

选择信号主要来自图像本身和固定任务 head；分类通常只需维持一个全局判别结果，密集任务则强调空间对齐。token 生命周期基本止于视觉 backbone 输出。

### 编码式视觉语言模型

图像与文本经 cross-attention 或联合 encoder 融合。此时一个 patch 是否重要由文本决定；还可同时压缩图像与文本 token。TRIPS、PuMer 的主要成本在视觉编码器或 cross-modal encoder，任务多为检索、NLVR、VQA 与视觉蕴含。

### Decoder-only MLLM

视觉 token 经 projector 与 system/question tokens 一起进入因果 LLM。成本分为：视觉编码、prefill、每层 KV cache、自回归 decode。FastV、SparseVLM 在 LLM 内部剪，VisionZip/DivPrune 在 LLM 前剪；二者节省阶段和可用信号不同。

## 分类与生成任务的差异

| 决策维度 | 分类/检索/判别 | 生成/VQA/captioning/多轮 |
|---|---|---|
| 输出依赖 | 固定 head，一次前向 | 每个新 token 依赖视觉前缀和已生成前缀 |
| 相关性时间 | query 固定，可为每题重算 | 随生成步骤和新一轮问题变化 |
| 效率主项 | encoder/fusion FLOPs、throughput | vision encode + prefill/TTFT + decode + KV cache |
| 质量风险 | 决策边界、召回率 | 事实遗漏、幻觉、错误滚雪球、回答长度变化 |
| 位置要求 | 任务相关；分类相对宽松 | OCR、grounding、计数、视频时序可在开放式输出中突然需要 |
| 可接受策略 | aggressive per-query pruning 较可控 | 静态剪枝可能无法支持未来词或 multi-turn query |

## 新挑战详解

### C1：同一图像的重要 token 随文本变化

TRIPS 在视觉 backbone 内用文本指导选择；PuMer 在 cross-modal layers 用文本决定视觉 pruning；SparseVLM 只选视觉相关 text raters 为视觉 token 评分。它们共同支持“纯视觉重要性不足”。但 Wen et al. 的普通 VQA 复核显示，语言指导方法并不总优于 random/pooling；文本的价值是任务依赖，而非无条件成立。

### C2：当前查询相关性与未来可复用性冲突

文本条件化保留集适合单轮问题，却可能删除下一轮需要的区域。VisionZip 指出 multi-turn 会复用历史 KV，而上一轮文本相关 token 不一定与新问题相关（§4.3）。因此多轮场景需要 task-agnostic coverage、保留可恢复摘要，或在新 query 到来时允许重新编码/增量取回。

### C3：生成时“未来问题”未知

在自回归生成第一个 token 前，模型不知道后续解释、OCR 引用或推理链会需要哪些视觉证据。一次性 prefill 剪枝是假设“初始 prompt 足以定义整个输出的信息需求”；长答案和 chain-of-thought 可能违反该假设。当前八篇来源没有直接解决可逆、按生成步骤重新取回视觉 token 的机制。

### C4：多模态 token 不可随意同池合并

视觉、文本、system 与特殊 token 的 embedding 分布和功能不同。PuMer 明确采用 modality-aware merging，并在图像/文本模态内分别合并；这说明纯视觉 ToMe 式跨序列相似性不能无条件套到联合 token 序列。

### C5：attention score 同时含语义、位置和架构偏置

FastV/SparseVLM 用 attention 估计重要性，但 Wen et al. 发现 FastV 保留位置偏向序列后部；LLaVA-1.5-7B 保留 144 token 时 Random/Pooling 达 95.0%/96.4% 相对性能，FastV/SparseVLM 为 89.8%/93.5%（Table 1）。VisionZip 又显示视觉编码器的信息集中位置与 LLM 的文本相关位置可能错位（Table 5）。因此 attention 需要和空间覆盖、冗余/多样性联合校准。

### C6：空间定位、OCR、小目标与幻觉更脆弱

Wen et al. 在 RefCOCO 上保留约 22.2% token 时，所有方法均灾难性下降，SparseVLM 只保留原性能 4.8%；普通综合 benchmark 没有暴露这种失败。生成模型还可能用语言先验补写被删证据，形成语法流畅但事实错误的答案。因此必须把 grounding、TextVQA/OCR、计数、POPE/幻觉和小目标纳入评测。

### C7：视频/多图带来时空覆盖约束

视频 token 数更长，但少数短暂帧可能决定答案。SparseVLM 用 text-guided adaptive pruning + recycling；DivPrune 用 diversity coverage，在 2048/多帧 token 的高压缩下均优于 FastV。仍未解决的难题包括跨帧对象身份、事件边界和多图对照关系。

### C8：prefill 大幅变快，端到端未必同比变快

VisionZip 将 LLaVA-NeXT 7B prefill 从 218ms 降到 27.8ms（7.8×），但同一实验总时间只约 3×（Table 4）。DivPrune 视频实验 prefill 0.330→0.161s（约 55% faster），端到端 4.37→3.39s（约 22% faster）。输出长度、decode kernel 与压缩选择器会改变净收益。

### C9：动态长度、KV cache 与 batch 执行

视觉 token 被删除后，所有层的 KV cache 可缩小；但不同样本保留数会造成 padding、分桶和 kernel 利用率问题。Wen et al. Table 7 显示相似 token 数/FLOPs 的 FastV、SparseVLM、MustDrop 总时长不同。现有论文很少报告 batch=1 P95、多 batch 或跨 GPU/NPU 的尾延迟。

### C10：层位置与预算是独立优化问题

PuMer/TRIPS 已观察“越早减越快、越晚减越稳”；VisPCO 进一步显示在 50% 中等预算下，不同配置可相差最多 19 个百分点，并通过 Pareto search 改善多种 base pruning rules。说明“选什么 token”和“何时/剪多少”应分开建模。

### C11：Token 与主干双自适应放大批次异构

若再为每个请求选择不同 Transformer 层/子网，系统同时面对可变序列长度和可变执行图。Orca/Sarathi-Serve 说明批内工作量不均会导致等待与 stall，Brainstorm 说明 sub-tensor dynamic dispatch 需要专门抽象，Apparate/SuperServe 说明请求级路径选择还要与 SLO 和在线质量反馈协调。对 Guard，最小可行方案应将连续选择量化为少量 `(token bucket, backbone path)` profile，并验证 profile 数量、组批等待和安全质量之间的 Pareto 面。

## 技术路线图

1. **文本指导视觉编码器：** TRIPS。最早利用 query，但需架构耦合和端到端训练。
2. **跨模态联合压缩：** PuMer。视觉 pruning + 图像/文本模态内 merging，适合 encoder-style VLM。
3. **LLM 层内 training-free pruning：** FastV、SparseVLM。可复用跨模态 attention，节省后续 blocks/KV，但已支付浅层 prefill 成本。
4. **LLM 前 task-agnostic compression：** VisionZip、DivPrune。一次处理、利于 multi-turn/cache；依赖视觉信息覆盖和多样性。
5. **剪枝 + 信息回收：** PuMer、VisionZip、SparseVLM。高压缩下比纯删除更稳。
6. **配置与预算优化：** VisPCO。研究从单一 selector 转向 Pareto layer schedule。
7. **反思与基准重构：** Wen et al. 强制引入 random/pooling、空间覆盖、真实 latency 与训练感知压缩。

## 统一比较

| 方法 | 模型/任务 | 压缩位置与信号 | 训练 | 代表结果 | 关键边界 |
|---|---|---|---|---|---|
| TRIPS, EMNLP'22 | ALBEF式 VLP；检索/VQA/NLVR | vision backbone；text-guided，低分融合 | 需预训练/微调 | 20.89G、343/s、11ms；性能与强基线相当 | 架构耦合；仅 4M 预训练对 |
| PuMer, ACL'23 | ViLT/METER；检索/VQA/VE/NLVR | cross-modal layers；文本指导视觉剪枝 + 模态内合并 | 微调 + distillation | 1.74–2.07× throughput，显存 -38%至-51%，性能 -0.4至-0.9 | cross-modal encoder 轻时端到端收益有限 |
| FastV, ECCV'24 | LLaVA/QwenVL/Video-LLaVA；caption/VQA | LLM layer $K$；received attention | 免训练 | LLaVA-13B layer2 后删 50%，FLOPs -45%，四任务均分近似不变 | 空间位置偏置；高压缩/定位脆弱 |
| VisionZip, CVPR'25 | LLaVA/Mini-Gemini；图像/视频/多轮 | LLM 前；视觉 attention dominant + merging | 免训练或微调 projector | 2880→160：prefill 7.8×、总时间约 3× | 不减 vision encoder；task-agnostic 与单题相关性可能冲突 |
| DivPrune, CVPR'25 | 多种 LLaVA；image/video generation | LLM 前；max-min diversity | 免训练 | 视频约 14.1% TFLOPs，prefill -55%、E2E -22% | 距离计算有开销；不使用 query |
| SparseVLM, ICML'25 | LLaVA/Qwen2-VL/Video-LLaVA | LLM 多层；text raters + adaptive ratio + recycling | 免训练 | LLaVA 576→192：99.1%相对性能，latency 57.82→36.50ms | 需访问 attention；统一复核中并非总胜 random |
| Wen et al., Findings ACL'25 | LLaVA/Qwen2-VL；VQA/grounding/haystack | 评测/分析 | — | Random/pooling 在约 2/3 普通 benchmark 胜部分复杂方法；RefCOCO 均严重失败 | 不是新的通用 selector；覆盖模型仍有限 |
| VisPCO, ACL'26 | Qwen2.5VL/LLaVA/Gemma3 | layer-wise ratio Pareto search | 约 1h search/training | 50% budget 下显著恢复质量，TTFT/throughput近似不变 | 主要单图；优化仍以 FLOPs budget 为主 |

## 是否“热门”：证据与限定

### 支持“热门”的证据

- **跨会议连续出现：** EMNLP 2022 → ACL 2023 → ECCV 2024 → CVPR/ICML/ACL 2025 → ACL 2026。
- **2025 年出现多条独立机制：** attention relevance、视觉 dominant token、diversity、recycling、configuration search、benchmark critique，而非同一方法的小改版。
- **研究问题开始二阶化：** 从“能否删 token”转向 multi-turn、视频、真实 latency、空间偏置、random baseline 和 Pareto schedule，通常是领域进入活跃阶段的信号。

### 限定

- 热点主要属于**高效 MLLM/VLM 推理**，不是所有多模态研究的中心问题。
- 大量工作仍是 training-free visual-token heuristic；真正联合优化图文 token、生成轨迹和硬件执行的研究较少。
- 方法排名尚不稳定：2025 的独立复核表明复杂 selector 可能弱于 random/pooling，说明领域“热门但未成熟”。

## 证据支持的研究缺口

1. **当前 query 与 multi-turn/future-generation 的统一保留目标。** PuMer/SparseVLM 支持 query relevance，VisionZip 直接展示多轮失效；满足多来源门槛。
2. **重要性、冗余、多样性与空间覆盖的联合建模。** SparseVLM/FastV 与 Wen/DivPrune/VisionZip 形成支持与反证；满足门槛。
3. **生成系统指标进入预算搜索。** VisionZip、DivPrune、Wen et al. 均显示 prefill/FLOPs 与 E2E 不同比例；VisPCO 尚以 FLOPs 为主要预算，满足门槛。
4. **精确定位、OCR 与幻觉的安全边界。** RefCOCO 严重失败、TextVQA proxy misalignment、POPE 差异共同支持；满足门槛。
5. **联合视觉—文本 token 剪枝。** PuMer 是明确代表，但多数新 MLLM 论文只减视觉 token；目前属于候选缺口，尚需更系统检索。

## 面向当前课题的建议基线

1. 架构：一个 encoder-style VLM（ViLT/METER 类）+ LLaVA-1.5/NeXT + 一个 Qwen2.5VL 变分辨率模型。
2. 方法：Random、uniform pooling、FastV、VisionZip、DivPrune、SparseVLM；配置层加入 VisPCO 或小规模 grid search。
3. 任务：普通 VQA/分类 + TextVQA/OCR + RefCOCO + POPE + Visual Haystack + multi-turn + 视频短事件。
4. 生成指标：accuracy/CIDEr/EM 之外，报告事实一致性、幻觉、输出长度和回答拒绝率。
5. 系统指标：vision encode、TTFT/prefill、decode tokens/s、E2E P50/P95、KV/peak memory、selector 开销；固定输入/输出长度做受控对照。

## 相关页面

- 概念入口：[[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]。
- 纯视觉基础：[[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|视觉 Transformer 与 Token 剪枝基础]]。
- 项目总览：[[LLM-Wiki/research/visual-token-pruning/overview.md|视觉模型 Token 剪枝总览]]。
- 证据缺口：[[LLM-Wiki/research/visual-token-pruning/gaps.md|视觉 Token 剪枝证据缺口]]。
