---
id: visual-token-pruning-comparison
type: synthesis
title: "训练参与视觉压缩：统一比较与最近邻审查"
tags: [research, visual-token-pruning, multimodal-safety, knowledge-distillation]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-gu-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-liao-2026-vtc-bench, paper-cai-2024-matryoshka-mm, paper-yang-2025-visionthink, paper-zhang-2026-security-pitfalls-token-compression, paper-chen-2025-safewatch, paper-liu-2025-guardreasoner-vl, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap, paper-zong-2022-self-slimmed-vit, paper-feng-2026-em-kd, paper-cho-2026-restore, paper-chen-2026-otprune, paper-liao-2026-resadapt, webpage-an-2026-adaalloc, paper-arxiv-2610-01640, paper-arxiv-2610-00757, paper-arxiv-2609-39134, paper-arxiv-2609-37581, paper-arxiv-2609-37123, paper-arxiv-2609-34861, paper-arxiv-2610-11251, paper-arxiv-2610-09313, paper-arxiv-2610-09252, paper-arxiv-2610-07987, paper-arxiv-2610-07729, paper-arxiv-2610-04225, paper-zheng-2025-safety-attention-heads, paper-wang-2025-sasa, paper-zou-2025-shiftdc, paper-chen-2025-safeptr, paper-arxiv-2609-27988, code-hf-2026-qwen3-vl-modeling, paper-arxiv-2610-13263]
status: active
created: 2026-09-08
updated: 2026-10-13
---

# 方法比较

## 2026-10-13：SheafPrune的图排序、预算条件与部署边界

来源：[[LLM-Wiki/research/visual-token-pruning/papers/2026-ma-sheafprune.md|SheafPrune精读笔记]]（v1全文，含附录A–S；作者结果，未复现）。本文的场景是图片问答；先完成视觉编码，再在语言模型入口按指定预算删除token。预算条件让同一选择器支持多种保留数量，尚不负责判断每张图需要多少预算，也不产生一个局部框。

| 比较轴 | 原文证据 | 对当前Cx的含义／本项目判断 |
|---|---|---|
| 分数来自哪里 | 文字—视觉关系与视觉先验经图传播、邻居数修正后排序；均匀初始分数RA88.19%，完整89.39%（表2/10，10%保留） | 图结构贡献更明确；“政策进入模型”与“政策改变了有效证据”仍要分开验证 |
| 预算是谁决定 | 外部给定保留率，选择器接收该条件；同一训练权重覆盖七种预算（附录C/M） | 可参考预算条件，不能代替全局/条件局部收益预测 |
| 执行成本 | 完整ViT和投影后一次物理删除；仍需完整两两相似度矩阵（附录G/J） | 不节省视觉塔；小图和单框Cx的成本结构不同 |
| 质量与调参 | 主表逐点选择delta；验证集选择规则未明确，未提供固定delta的全网格部署曲线（附录M/O） | 对照应预先固定或用明确验证集选择参数，不能把性能上沿当无需调参结果 |
| 效率 | LLaVA-NeXT保留10%时prefill5.15×，decode66.5→67.3 token/s；没有完整答案E2E时延（表9、附录K） | 需分开选择器、视觉塔、prefill和decode，不能直接外推政策Guard收益 |
| 证据分布 | 10%保留时GQA网格覆盖0.417，随机0.500；无显式覆盖约束（表13） | 图分数不能保证空间覆盖或安全证据，也不天然给出可解释单框 |

与已有CDPruner的关系是问题相关性与冗余的共同主题，但子集选择机制不同，本文没有实测CDPruner；与QuietPrune相比，剪枝位置更晚且不省视觉塔。只增加有出处的比较，不改变Cx方法、实验状态、概念或正式motivation。

## 2026-10-10：安全内部表征与政策预算的分工

新增 [[LLM-Wiki/research/visual-token-pruning/cx-policy-safety-representation-pruning.md|安全表征分支调研]]，用任务、输入、信号、层位置、预算、训练、基线、指标、成本和边界比较两种思路。SAHs/SASA/ShiftDC 是安全/危险内部表征的近邻；SafePTR/SAP 已做生成安全相关 token 干预；SafeWatch 已做政策 Guard 剪枝。新增三篇仅略读，未运行代码或声称已证实 Cx 效果。

综合判断：当前 Cx 与分辨率动作对应更直接，政策条件证据保留更可能形成安全专属解释，但原生早期 ViT 不读政策，探针分类信息也不等于 token 因果贡献。离线完整 Guard 贡献→在线便宜政策读出可作为选择器假设，收益组成仍为 NLL＋标签不一致。新增方法不规定数据规模/范围、执行步骤或门控。

用户新自适应实验运行中，实际配置与结果尚未核验；下文同日“未运行”保留为此前方法提出时的历史状态。

## 2026-10-10：第二批近期论文的执行位置与单框反证

下表对应用户选择的七篇全文，效果均为作者报告，未本地复现。当前Cx为逐样本全局/至多单局部、政策条件、实际分辨率预算；下列不同任务和工作负载的最大加速不做横向排名。

| 论文 | 决策与执行 | 对Cx有用的机制/控制 | 关键限制 |
|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-jiang-vcola.md|V-CoLA]] | LLM第1层后合并，第24层退出 | 跨层token工作量与混合架构状态信号 | 全ViT；平均保留率含退出；prefill6.15×而Jetson E2E1.733× |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md|SAP]] | 被剪token交换；decode逐head改attention | 同长度背景恢复、注意力干预与utility对照 | 生成拒答ASR；未评adaptive攻击；KV恢复/计时口径不完整 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-shi-small-objects-safe-zoom.md|小目标/安全放大]] | 多次native crop/tiling/zoom调用 | 同像素变token、同几何变context、crop对插值 | R/M条件期望召回界；单框不覆盖；并非内容安全或E2E加速 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-jeong-refit.md|ReFIT]] | 初次多尺度ViT后裁图重编码，再ITR | 水平/垂直窗口形状、top-2保护 | 多区域；模块训练/阈值未充分报告；仅FLOPs |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-feng-visionweave.md|VisionWeave]] | 全ViT后每块fine4/coarse1 | 同样本coarse数不变的空间打乱；入调度前layout | image-only router；大规模训练并改LLM；2.30×是长视频并发吞吐 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-han-foveated-compression.md|Foveated Compression]] | 全ViT后九格选一格恢复native | 同预算九动作、并列赢家、随机/固定/缩放/oracle | learned69.61弱于19.82%整图70.99；question无显著增益；不主张E2E |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhu-flashgaze.md|FlashGaze]] | ViT前像素Drop/Merge/Keep | 预算上限与selector完整计时；多尺度DP | 第一帧豁免；无policy；长视频batch1 SDPA TTFT非短图E2E |

**本轮综合判断：** Foveated直接说明“有单高清区oracle headroom”和“轻量selector能兑现收益”需要分别证明；保留整图缩放与随机/固定框，不能只比均匀强压缩。VisionWeave的shuffled routing固定每样本预算，适合隔离“选在哪里”；其大规模后训练又不能当轻量路由效果。小目标论文区分原像素与token容量，但保证依任务/分布单调性和覆盖，不能自动用于政策Guard。SAP面向拒答，若迁移抑制危险证据到检测模型可能增加漏报，这仍是待验证假设。

对 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|Cx]] 的新增比较轴是强缩放、实际配置的oracle regret、并列监督、selector-only政策干预、匹配预算的位置控制和像素来源控制；本轮不修改当前方案、concept或正式motivation。


## 2026-10-10：双重要性规划的结构对照

当前自适应方法称为 Cx。v2 仅保留方法结构：代价由 NLL＋标签不一致组成，全局/局部各三档，局部包含零档；不规定数据使用或执行协议。条件局部收益用于表达 Cx mixed 路线的增量价值，局部-only 效用表达独立充分性，两者不直接互换。

用户最新假设见 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md]]，未运行实验。固定同一 Guard、实际配置库、预览与单框，对比配置 CE 分类器、单总收益 MLP，以及两个有独立监督的收益 head。两个量按“先升级全局、再加入局部”定义；局部 head 依赖全局预算和语境，总和等于相对参考的路线收益。该可追溯分解是项目设计，不是唯一对称因果贡献。

已有 VIP-Router 支持离线效用回归方向，When Text Matters 支持 attention 对照实际区域干预的审计方向；它们没有验证本页全局/条件局部收益曲线的政策 Guard 效果。原始 attention/激活与真实预算收益、像素使用分别评估，不能用归一化 attention 比例直接确定总预算。

## 2026-10-10：近期追踪精读的预算与证据边界

以下比较来自本次六篇原文阅读，所有效果为作者报告，未在 C5 复现。保留当前逐样本全局/单局部预算方案，不据通用 VQA 结果承诺政策安全收益。

| 论文 | 决策与执行位置 | 最有价值的对照 | 计时或证据边界 |
|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhao-scaling-stops.md|Scaling Stops]] | 跨 backbone/分辨率配置；经验误差律 | joint-holdout direct selection regret | 语言侧 FLOPs；latency 拟合不稳定 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-guan-video-evidence-indexing.md|Video Evidence Indexing]] | 低清 preview 后目标级选高清帧；两次调用 | 目标列表与按目标预算解耦、移除 Evidence Set | 单次评测；最终 answering checkpoint 也改变；无完整 E2E |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-yan-fata.md|FATA]] | 输入扰动后 full/压缩两路 | 明确 SR/CER/CBR 条件与 shared denominator | 主实验重建 N 槽位；跨模型改变 threat model |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-trevs.md|TReVS]] | post-encoder query relevance＋第八层后筛选 | 高方差 heads 与 pre-LLM 文字 cue 的独立消融 | 平均 token 预算；POPE 4090 短回答，非 pre-ViT |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-niu-evivit.md|EviViT]] | 中间视觉层多区域重新编码＋坐标 bridge | 固定 crop 数量/尺寸/预算只变位置；question shuffle | 默认 2–3 crop；人工 trace；部分设置 latency 退化 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-kang-when-text-matters.md|When Text Matters]] | post-encoder reserve＋decoder midpoint 重选 | 同 token 轨迹换 final score；匹配 token–block workload | End-to-end 为 GPU-ready TTFT；task evaluation 无 KV cache |

项目判断：可复用的是配置 regret、selector-only 政策置换和匹配像素位置控制；不同 token 数、层位、前端成本、decode cache 或任务集合下的最大加速数字不做统一排名。

## 2026-10-10：Cx 逐样本预算模块的近邻

当前用户不锚定 5%，先考虑 batch=1、全局＋至多一个局部框。详细机制和待验证协议见 [[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md|逐样本分配方案]]。

| 机制 | 可迁移设计 | 需要保留的边界 |
|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-liao-resadapt.md|ResAdapt]] | 编码前图文 allocator、实际分辨率动作、一次最终调用 | 视频为主，图像迁移不均；不外推其时延 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md|VIP-Router]] | 共享 preview＋候选预算条件＋离线质量/成本标签 | 给定保留率选策略；Group A 筛选，不能照搬到未过滤 Guard |
| [[LLM-Wiki/research/visual-token-pruning/papers/2024-cai-m3.md|M3]] | 多预算共享模型、最小正确配置 oracle | 完整视觉编码后池化，没有实现可部署预算预测器 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-yang-visionthink.md|VisionThink]] | 高低清可解性标签、逐样本升级基线 | 多轮额外调用，OCR 类时延可能退化 |
| [[LLM-Wiki/research/visual-token-pruning/adaalloc-project-screening.md|AdaAlloc 项目页]] | 全局覆盖与局部细节的预算问题形式 | 仅项目页发现；固定总预算、长视频，不用于支持安全效果 |

项目判断：优先少量实际 $(K_g,K_l,b)$ 配置和最小充分配置 CE 预算头；联合区域代价评分、连续 RL 和级联分别作为后续/对照。适配效果均为假设，不能将上述论文结果当作 C5 新测量。

下表中的代码状态是本轮核查结果，不代表论文没有代码。相同 token 数不代表相同时延；训练样本、GPU 小时和可训练参数须同时匹配。新论文详见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md]]。

| 方法 | 任务/输入 | 选择信号与位置 | 预算 | 训练需求 / 结构 | 数据、基线与指标 | 效率口径 / 局限 | 代码 |
|---|---|---|---|---|---|---|---|
| EPIC | 通用图文理解 | 复用 DART/FastV/Random，层位置可渐进 | 多预算 | SFT+渐进 KL，同主干 | LLaVA-665K；多种压缩/无蒸馏消融；10 基准 | 表 2 为 POPE CUDA 总时间，非安全时延 | 作者仓库已定位，未运行 |
| TBD | 视频问答 | LLM 前 FlashVID 等，selector 不训练 | 固定保留预算 | LoRA+可靠答案蒸馏 | Video-178K；LoRA-only/多压缩模块；4 基准 | 训练完整教师仍昂贵；无 Guard 召回约束 | 官方可用实现未核实 |
| ViCO / ViR | 通用图文、OCR | patch 网格压缩，损失比监督 router | 256/64 per patch | 一致性后训+额外 ViR | SFT/OCR/VQA；Flash 对原版均分 | 表 17 非安全子群；不能代替输入 resize 时延 | 原文入口，未运行 |
| DualSpeed | MLLM 训练 | 插件式剪枝，fast/slow 模式 | 压缩/完整 | 双模式、自蒸馏、mode isolator | LLaVA 系列；剪枝训练/推理比较 | 核心是训练墙钟；full-path 失配需检查 | 作者仓库已定位，未运行 |
| ETC | 图文问答/grounding | 任务加权 hidden state 的 VID 稠密重构，LLM 瓶颈 | 1/2/4 压缩 tokens | 学习 token；训练期 MLP decoder，推理移除 | LLaVA/Qwen3；通用 VQA、RefCOCO | 完整视觉塔与完整 token prefill 仍执行；短标签时延收益未证 | 官方来源，未运行 |
| SiT / FRD | 纯视觉分类 | TSM 软聚合；训练期 RTSM 恢复稠密 token | 多 stage | 逐 block token MSE+logit KD；推理移除 RTSM | ImageNet；vanilla ViT/LV-ViT | 最接近少 token→完整特征恢复；非安全/VLM | 官方代码，未运行 |
| EM-KD | 通用 MLLM | Hungarian 匹配不等长视觉 token | 教师/学生不同 token 数 | 视觉词表 reverse KL+图文 affinity Smooth L1 | 多理解/解析基准 | 不重构全部教师位置；训练匹配开销不进入推理 | 未运行 |
| OTPrune | 通用 MLLM | 零均值高斯二阶统计、Wasserstein 代理与 log-det 覆盖；不做特征重构 | 固定原 token 子集 | training-free，Gram+Cholesky 贪心 | 11 个多模态基准 | 完整视觉塔已执行；均匀且文本无关；selector-inclusive latency 未报 | 官方来源，未运行 |
| RESTORE | 通用 MLLM | 位置保持、注意力校准和 anchor merging | 多保留率 | 推理期校准，不做教师 feature KD | LLaVA/Qwen 系列、多基准 | TextVQA merging 暴露高频细节稀释 | 官方代码，未运行 |
| VisCo | 通用图文理解 | 内在自编码、分层 memory KV | 多种紧凑预算 | 共享主干，改变 memory 执行 | 三主干、六基准 | 不改主干不等于不改执行协议 | 未核实 |
| ET-Prune | OCR 密集图文 | 问题相关、区域保护、熵密度；中层 | 动态下限 | 无训练 | TextVQA/OCRBench；多 selector | 单次评测点估计，早段成本未省 | 未核实 |
| OOD-VTP | 生成拒答/幻觉 | 语言空间距离；选定层 | 剪枝率 | 无训练 | SafeBench/MM-SafetyBench/CHAIR | 拒答不是 Guard 检出，需补良性 FPR | 作者仓库已定位，未运行 |
| Evidence-RL | 证据密集视觉推理 | 局部干预支持差，训练期 | 不研究压缩预算 | GRPO，无在线审计 | 九基准、证据/干预消融 | 无额外审计不等于短输出 | 未核实 |
| Att-CoT | 多步视觉推理 | 视觉 attention+承诺时序，训练期 | CoT 长度非视觉预算 | 辅助 SFT，同架构 | CLEVR/ChartQA 等及遮挡测试 | CoT decode 仍需计费 | 未核实 |
| EfficientVLM | 通用 VL | 先蒸馏，后按模态做结构/神经元剪枝 | 6V/3T/3X 等 | 紧凑学生，改变整体模型规模 | VQA/NLVR/检索/描述 | 报告 2.2x；非 Guard、非输入 patch 联合压缩 | 未运行 |
| Patch Slimming | 纯视觉分类 | final→early 的 top-down patch 影响 | 分层 patch 预算 | 微调既有 ViT | ImageNet 等 | FLOPs 降低不等于 VLM 判定时延 | 未运行 |
| METR | 纯视觉分类 | 多出口压力使早期 `[CLS]` attention 可用于删 token | 多层 reduction | 训练多出口+自蒸馏；推理保留 reduction | 标准视觉基准 | 已直接覆盖“早层任务压力+token reduction” | 未运行 |
| FastVLM | 通用 VLM | 新 FastViTHD 编码器，以输入分辨率控制 token | 多分辨率 | 换视觉 backbone 并训练 | 多项 VLM/OCR 基准 | 显式测 vision+prefill；结构变化较大 | 官方代码，未运行 |
| Dyna-ViT | 纯视觉分类 | encoder 前按能量/边缘/熵等无参显著性选 patch | 固定 Top-K | 主干不改，无新增参数 | VOC/CIFAR/Tiny-ImageNet | 不看 query/policy；安全小证据可能低显著 | 未运行 |
| QuietPrune | 通用 VLM | 文本→视觉 `[Q-CLS]`；ViT 内早剪和聚合 | 多剪枝率 | 训练轻量 adapter，改变前向输入 | Qwen3-VL/InternVL3，多项 VLM 基准 | 同时省视觉塔和 prefill；安全政策未测 | 无代码入口，未运行 |
| ResponseGuard | 独立多模态 Guard | 单次 pooled 表示直接分类 | 固定全输入 | LoRA+小 head，冻结视觉编码器 | prompt/response harmfulness | 报 67.6 ms；图像组仍弱，骨干非同模型对照 | 官方代码，未运行 |
| SAP | 被保护生成 VLM 的 jailbreak 安全 | 推理期恶意锚点识别、良性 token 恢复和 attention 重分配 | 多剪枝率 | plug-and-play，推理协议变化 | 3 安全+4 utility（仓库说明） | 非独立 Guard 检出；论文正文链接本轮未得 | 官方代码，未运行 |

## 与既有证据的关系

- M3 已联合训练嵌套视觉网格；不能声称首次任意预算训练。
- VisionThink 已用训练决定何时看高清；不能声称首次学习分辨率升级。
- SafeWatch 已是 policy-aware pruning 的直接安全先例。
- VTC-Bench 与 XGuard 已使 resize 成为必须比较的方案。
- Security Pitfalls 已研究压缩状态特有漏洞；“发现剪枝可被攻击”不足以构成新安全论文。

上述复用已登记来源及主文已有来源定位，本轮不将其整体阅读级别自动提升。

## 拟议方法必须增加什么

| 候选增量 | 最近邻已覆盖 | 仍须证明的差异 |
|---|---|---|
| 任务+压缩联合训练 | EPIC/TBD/ViCO | 固定 FPR 下困难政策子群改善，不仅均分恢复 |
| 高清→低清对齐 | ViCO 相邻预算、TBD full→compressed；LOREAL 待读 | 学生证据可见性决定监督与拒绝强一致性，且击败相同训练的 resize |
| 少 token→完整表征恢复或分布覆盖 | SiT/FRD、EM-KD、ETC、OTPrune、RESTORE | ETC 属于任务表征重构，OTPrune 只做二阶分布覆盖；安全证据加权的训练期可恢复性还需证明其预测 harmful flip，不能只报全局 feature MSE |
| 首标签政策关系蒸馏 | TBD margin；Att-CoT；GuardReasoner-VL | 不增加在线推理长度仍改善组合风险，且避免标签/语言捷径 |
| 干预生成训练监督 | Evidence-RL | 干预×压缩的交互收益，而非普通 grounding 后训收益 |
| 可靠蒸馏 | TBD 教师过滤 | 独立检查学生可观察性与 full/pruned 双向纠错 |
| 压缩安全防御 | Security Pitfalls；OOD-VTP | 明确 Guard 威胁模型、固定 FPR、跨攻击/预算泛化，不靠全回退 |
| 浅层安全视觉塔 | EfficientVLM；MuE；METR | 不是普通 early exit；须证明政策条件下的安全充分性、真实截断及 image-only/worst-group 增益 |
| encoder 前/内早剪 | Patch Slimming；Dyna-ViT；QuietPrune | 不是 query adapter 换成 policy；须处理低显著度危险证据和输入×深度交互 |
| 单次 Guard 判定 | ResponseGuard | 同 backbone/数据下拆分视觉前缀、输出形式和训练目标；严格 FPR 而非只报加权 F1 |
| 安全感知剪枝 | SAP；SafeWatch；Security Pitfalls | 独立检测 Guard、漏报威胁与训练泛化；不把生成拒答或 jailbreak ASR 当 recall |

历史方法比较见本页；现行实验基线与协议见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。
