---
id: visual-token-pruning-training-reading-log
type: synthesis
title: "训练参与的视觉 Token 压缩：检索与证据日志"
tags: [research, visual-token-pruning, knowledge-distillation, multimodal-safety]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-gu-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-chen-2024-llavolta, paper-xing-2024-pyramiddrop, paper-wang-2026-loreal, paper-2026-covipal, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-yu-2023-x-pruner, paper-fan-2026-visual-token-semantics, paper-wang-2026-information-horizon, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap, paper-zong-2022-self-slimmed-vit, paper-feng-2026-em-kd, paper-cho-2026-restore, paper-chen-2026-otprune, paper-burns-2018-women-snowboard, paper-selvaraju-2019-hint, paper-tang-2020-gaic, paper-fu-2024-laps, paper-chen-2025-vltp, paper-guo-2025-crop, paper-anonymous-2026-mvp-token, paper-liu-2026-autoprune-ai4ai, code-autoprune-2026-release, paper-zhang-2025-cdpruner, paper-cao-2023-pumer, code-pumer-2026-audit, code-cdpruner-2026-audit, paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-arxiv-2609-18279, paper-arxiv-2609-13804, paper-arxiv-2609-10346, paper-arxiv-2609-15131, paper-arxiv-2609-13745]
status: active
created: 2026-09-08
updated: 2026-09-24
---

# 检索范围

## 2026-09-22：长政策瓶颈与路线转向

用户报告当前数据中政策 token 通常超过视觉 token 四倍，Dyna-ViT 式 90% pre-ViT 剪枝只得到 1.14× 端到端加速且精度明显下降。Amdahl 反推的有效可移除视觉路径约 13.6%，但原始 profiler 尚未归档，因此仅作为场景约束，不标 reproduced。

定向检索查询包括 `CVPR joint vision language token pruning`、`policy-adaptive image guardrail benchmark`、`same image policy shift guard` 和 `prompt compression gist tokens wall time`。纳入标准是：CVPR 的联合多模态 token 压缩正式先例、运行时政策图像 Guard 数据、同图政策翻转数据，或可复用政策表示压缩；排除只报 token/FLOPs 且无可迁移机制的通用压缩工作。

- MADTP（CVPR 2024）：skimmed/source-checked；同时评测视觉、语言和联合 token 剪枝，证明联合多模态压缩符合 CVPR 范围，也反证“首次联合剪枝”。
- SafeEditBench/SafeGuard-VL（CVPR 2026）：由 skimmed 升级为 deep-read/source-checked；精读 §1–5、表 1–6、图 1–7 和补充政策定义。它把适应性定义为跨自然语言政策泛化并保持通用能力，以有害语义 recaption SFT + policy-aware GRPO 解耦感知和规范判定；缺少 paired flip 指标，正文 128 images 与 62 pairs 的口径待数据发布核对。
- PolicyShiftGuard/PolicyShiftBench（arXiv 2026）：由 skimmed 升级为 deep-read/source-checked；精读 §1–7、表 1–6 和附录 A–G。它把问题收紧为同图 policy flip，以显式属性—可执行规则构造标签、RP-SFT 去模板捷径、BP-Adapt pair margin 优化边界，并用 PSS 要求翻转两侧都正确；长用户自定义政策被作者明确列为未覆盖。
- Gist Tokens（NeurIPS 2023）：skimmed/source-checked；支持政策编译/缓存机制，但其最高 40% FLOPs 降低只对应最高 4.2% wall-time 加速，强化真实计时门槛。

2026-09-22 的综合结论曾写入现已清理的长政策转向评估；保留的论文比较见 [[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md]]。当时活动计划从 pure visual pruning 转为长政策编译、条款检索与 pre-ViT 视觉选择的协同预算；主任务采用 PolicyShiftGuard 式同图翻转定义，视觉剪枝提高精度只保留为需排除校准/类别不平衡解释的次要假设。

## 2026-09-21：研究计划收束为政策条件 ViT 前剪枝

根据用户的新研究边界，本项目删除旧的“安全充分视觉前缀”总方案和“浅层联合早退出”评估，当前主线改为 `(image, policy)` 场景下、首个 ViT block 前的政策条件 patch 选择。既有论文笔记、专题综述、实验记录和负结果保留为证据。当时的新计划已清理；现行计划见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|短政策视觉剪枝计划]]。本日志下方旧条目按当时研究状态保留，不代表当前方案。

## 2026-09-20：近期追踪选定论文精读

用户将近期候选中的 G2TM、StepPrune、VIP-Router、AdaVSkip 与 VLM 图表读数因果定位标记为 selected。本轮沿用既有 source_id，下载并登记五份 arXiv v1 原件与 SHA256，全部升级为 deep-read / source-checked；候选状态改为 ingested。未运行代码、模型或实验，所有数字均为作者报告。

- [[LLM-Wiki/research/visual-token-pruning/papers/2026-bercy-g2tm.md|G2TM]]：第 1/2 个 ViT block 内做相邻图连通分量合并；跨 decoder 的合并统计稳定，但阈值对预训练配方和数据集敏感，轻量模型会出现 GFLOPs 降而吞吐降。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-stepprune.md|StepPrune]]：完整视觉塔后以历史条件 pointer 和 STOP 生成样本级保留集；短前缀 selector 开销可抵消收益，过早 STOP 会丢失局部证据。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md|VIP-Router]]：在多种现有剪枝器与 Full 间按样本路由；主证据限于 full 正确、下采样错误的 VTC-Bench Group A，跨 backbone 需重新训练。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-sun-adavskip.md|AdaVSkip]]：按层、按 attention/MLP 决定所有视觉 token 是否参与计算，属于纵向跳过而非 token 删除；可与水平压缩组合，但 profiling 和计时协议仍有缺口。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-niu-chart-reading.md|图表读数因果定位]]：变化柱顶以更少 token 恢复更多答案偏好，legend/series 状态比柱高和轴尺度更早失去局部可恢复性；只在成功的合成竖柱图上成立。

对项目的直接影响是补齐五类比较轴：浅层合并、动态子集、策略选择、纵向计算路径、证据可观察性。它们作为基线和反证进入研究地图；安全充分性、unsafe 漏报和真实服务加速仍需本地实验，本轮不修改正式 motivation 或主方案。

## 2026-09-18：SafeAtlas-VL 训练数据与联合判别必要性定向核验

用户询问 SafeAtlus-VL，官方资源名称核为 SafeAtlas-VL / arXiv2608.29098。检索官方 arXiv 原文、HF 数据卡和作者 GitHub README，按 DOI/标题/ID 去重无既有条目；paper-ingestion 定向 skimmed / source-checked，PDF 技能视觉核查图 1/3/4 和附录表 A12–A14。原件 web PDF 请求失败、沙箱下载网络受限后，获准下载官方 v1 PDF；保存45页原件与SHA256，不改写原件。HTML与PDF关键数字一致。

保存 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-safeatlas-vl.md|论文定向核验]] 与 [[LLM-Wiki/research/visual-token-pruning/safeatlas-vl-public-release.md|公开数据卡说明]]。区别论文完整150万训练实例与当前公开100万标注；core-only请求/回复文本教师标签可区分端点为构造规则推导，不是单模态实验数字。检查完整原文实验/消融未见同集缺模态结果；HF记录gated，未访问或统计，未运行模型。官方README外部结果与v1部分数字不同，本轮不合并排名。新来源登记三条；不晋升正式动机或创建实验结果。

## 2026-09-18：浅层图文联合判别、单侧早退出与困难分支剪枝

本轮问题来自用户的新设想：在 ViT 早层或之前进行图文联合计算，已识别有害时结束整个 Guard 判别，未确定时选择 token 继续执行。先按图文内容/对话风险判别评估，具体政策、输入/输出位置、风险类别与部署流量仍待用户细化；“降低平均实验”暂按降低平均时延理解。检索截至 2026-09-18，覆盖公开代表性先例与会议定位，不是穷尽性最新综述，不运行新实验。

检索站点：arXiv、CVF、ACL Anthology、Google Research、Apple ML Research、USENIX 和 IEEE S&P 官方站点。实际查询包括 `vision language safety guard early exit token pruning`、`text guided early vision token pruning vision encoder`、`SafeRoute adaptive routing safety guard early exit`、`early exit multimodal guard vision language safety classifier`、`You Need Multiple Exiting`、`SingGuard dynamic guardrail reasoning`、`Conformal Risk Control` 与三个会议 CFP。

纳入标准：能减少视觉编码计算的早剪/截层、动态 Guard 判别、图文组合安全与边界误拒证据，以及官方 venue 范围。排除：仅凭摘要中的 efficient/safe 名称判定相关、机器人动作安全与本任务无关的工作、聚合页或跨论文不统一的速度排名。CVF 新请求出现 Internal Error 时复用已有 QuietPrune 精读和本地原件；一个 ACL 路径返回无关写作论文，未用作 SafeRoute 证据，改用已核对的 arXiv 原文。

### 先登记 discovered 候选，再核验与综合

| 候选 | 发现后的处理 / 阅读层级 | 是否作为本轮依据 |
|---|---|---|
| QuietPrune、Dyna-ViT、METR、SafeRoute、SAP | 复用既有来源与笔记；QuietPrune/SafeRoute 为既有 deep-read，其余保留原层级 | 最近邻与迁移边界；不声明新复现 |
| MuE / You Need Multiple Exiting | discovered → skimmed；核验 arXiv v2 §3 与 §4 效率表，Google Research 确认 CVPR 2023 | 图文编码器/decoder 多出口已有先例 |
| VLSU | discovered → skimmed；核验 arXiv v2 §2–5、Limitations 与官方项目摘要 | 跨模态组合及上下文误拒压力测试依据 |
| SingGuard | discovered → skimmed；核验 arXiv v1 §2.6、§3–4、§7 | Guard 动态早退出直接反证，区分 decoder 退出与视觉塔早退出 |
| Conformal Risk Control | discovered；只作为后续理论阅读候选，未核完整证明 | 不作本方案保证已成立的证据 |
| CVPR 2026、OSDI 2026、IEEE S&P 2027 CFP | 核验官方范围；前三者分别作为已公开定位文本使用，不预测未来规则 | 会议适配解释；分数为主观判断 |

综合判断当时单独保存为“浅层联合计算与早退出评估”；该旧评估已于 2026-09-21 删除，其历史结论由本日志保留。该分支不属于现行的 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|短政策视觉剪枝计划]]。

## 2026-09-18：PuMer / CDPruner 双篇精读与关联成本比较

用户指定两篇精读；新增 [[LLM-Wiki/research/visual-token-pruning/papers/2023-cao-pumer.md|PuMer 笔记]]，将 [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]] 从先前 skimmed 升为 deep-read，两者 verification 均 source-checked。复用既有 ACL 14 页/NeurIPS 31 页原件，不重复下载；核对正文、方法算法、主结果、消融、技术附录与限制，并渲染关键方法/效率页只读视觉检查。没有模型实验或 reproduced 声明。

官方代码有限只读审查：PuMer revision `8a00d85314175a4635d074fb003ae39da171ddc7`，CDPruner revision `9541616c40fcd5625de1cdb8ea6c33c129eb7864`；新增 `code-pumer-2026-audit`、`code-cdpruner-2026-audit`。GitHub API 限流后使用官方 HTML/raw fallback，未调用 Git。确认 PuMer 无独立 learned scorer、复用 attention/key、同模态二分匹配，但仍微调并蒸馏；CDPruner 加载 CLIP 文本塔、双 stream 编码、构建核并做增量选择，论文 Qwen 路径只需 input embedding 均值。

[[LLM-Wiki/research/visual-token-pruning/pumer-cdpruner-text-conditioning-cost.md|定向比较]] 区分额外评分/匹配成本、PuMer 最优 batch throughput 与 CDPruner 短回答 prefill/decode、训练适应与纯选择。保留 CDPruner 当前负 cosine 与原文正 relevance 的静态实现差异及未明确的全流程计时边界，不静默修复、不否定未复现的表格。Guard 启发标为候选，未修改正式动机、主方案或旧实验。

## 2026-09-18：CDPruner 方法与 AutoPrune 投稿证据复核

用户追问强人工基线及投稿潜力；新增 [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner 定向阅读笔记]]，登记 `paper-zhang-2025-cdpruner` 并保存 31 页 NeurIPS 2025 官方定稿与哈希。核对摘要、引言、总览图、§3 方法、主要实验表和结论；未全读附录或审查原生代码，登记 skimmed / source-checked，不冒充完整复现。

确认条件 DPP 目标联合指令相关性和集合多样性；AutoPrune 主路径在其上搜索有限交换和重组。对照发现 Qwen / 128-token 的原文 TextVQA、ChartQA、AI2D 与 AutoPrune 自行复现基线差异明显，保持协议/adapter 待核边界，不作跨论文直接排名。另将 AutoPrune 17 页原件渲染后抽查九页，补记附录未解析引用及标题一致性问题；投稿潜力写为主观、有条件判断，与正式发表身份分开。没有运行模型或改变正式动机。

## 2026-09-18：AutoPrune / AI4AI 精读与实现审查

用户指定 [[LLM-Wiki/research/visual-token-pruning/papers/2026-liu-autoprune-ai4ai.md|An AI4AI Framework for Visual Token Pruning]]，新增来源 `paper-liu-2026-autoprune-ai4ai` 与 `code-autoprune-2026-release`。原文 v2 为 deep-read / source-checked；核对正文、附录 A–C、表 1–14，并保存 17 页原件与 SHA256。公开代码固定观测 revision 为 `23daf51afab87239d0c36760cd81326675d44b16`，只读审查 final anchor/merge 配置、评分/执行路径和搜索 history；未运行实验。

确认方法为冻结 MLLM 上、完整视觉塔/projector 后的离线策略搜索与在线有限交换/回灌，非 ViT 内部剪枝或模型权重训练。表格算术复核发现平均增益主要由 MMBench 驱动，Rel 列与附录聚合公式不一致；公开 10×5 控制器加载此前搜索历史，代码 clean baseline 与论文不同。保留这些未决项，不将平均优胜写成全面超越人工方法，不更新正式动机或已有实验。

## 2026-09-16：StackTok 精读晋升

用户指定 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|StackTok]]（`paper-arxiv-2609-16841`），沿用近期候选的来源 ID，升级为 deep-read / source-checked。核对 arXiv v1 官方 HTML 正文、主表 1–3、附录 A 理论和附录 B 表 A1–A5，下载并登记 11 页原件及 SHA256；未复现代码或模型。

证据边界：给定固定预算下的相关性—覆盖门控不是自动预算预测或逐前缀硬覆盖保证；选择位于完整视觉塔/projector 后。论文提供压缩质量与消融，但未报告实测端到端加速；Qwen Avg† 排除 OCRBench 和 ScienceQA，极低预算的 OCR 明显退化。本轮仅补充论文证据和候选启发，不修改正式动机、主方案或已有实验。

例行近期检索单独记录在 [[LLM-Wiki/research/visual-token-pruning/watch/overview.md|arXiv 近期论文追踪]]：轻量候选先人工选择，再精读入库。本页继续记录专题调研与阅读证据，不复制每批候选。

检索日与截止日：2026-09-16。以 arXiv 原文、CVF、NeurIPS、OpenReview、ACL、AAAI、ECVA 和作者项目页为证据；搜索引擎中的聚合页只用于发现，再回到原文。覆盖 2022—2026，重点补充训练、蒸馏、跨分辨率一致性、压缩安全、token merging 及自回归 VLM 剪枝的实测时延—性能边界。不以检索未命中证明研究不存在。

纳入：改变训练目标或训练输入预算、具有直接新颖性冲突、研究压缩导致的语义/安全失败，或提供强比较基线的工作。排除：纯权重压缩、无视觉任务的上下文压缩、纯生成加速、单纯 serving 优化；保留必要相邻工作作为反证。代码未运行，论文数字不视为本地测量。

## 检索批次与 discovered 候选（先登记，后核验）

| 批次 | 实际查询关键词 | 初步候选与处理 |
|---|---|---|
| Q1 | visual token pruning training aware fine tuning low high resolution distillation 2026; visual token compression training safety guard pruning 2026 | ViCO、VisCo、ETC、TBD；待原文阅读 |
| Q2 | site.arxiv.org visual token compression training 2026 distillation; ViCO; PyramidDrop; LLaVolta | InternVL3.5、PyramidDrop、LLaVolta；区分训练加速和推理压缩 |
| Q3 | Token-Budget Distillation; visual token pruning-aware training; visual token safety compression training distillation | TBD、Fast-Slow、CoViPAL、ET-Prune；待核对结构与任务 |
| Q4 | visual Progressive Consistency Distillation; Security Pitfalls Token Compression; Visual Token Compression Enhances Robustness; high low-resolution distillation VLM token | ICD、Security Pitfalls、Robustness、LOREAL、RADIOv2.5；待区分 Guard 检测与被保护模型拒答 |
| Q6 | early vision encoder layer reduction distillation VLM; pre-encoder token pruning; query-guided early pruning; efficient multimodal guard frozen vision encoder | EfficientVLM、Patch Slimming、METR、FastVLM、Dyna-ViT、QuietPrune、ResponseGuard；用于三项策略排重 |
| Q7 | token-pruning-induced vulnerabilities safety-aware pruning; compression-aware safety training guard | SAP 及相邻压缩攻击；区分生成模型 jailbreak/拒答与独立 Guard 漏报 |
| Q8 | visual token pruning feature reconstruction/distillation; unbalanced vision-token alignment; distribution/attention alignment; least-squares recovery | SiT/FRD、EM-KD、ETC、OTPrune、RESTORE；用于“少 token→完整表征恢复”排重 |
| Q9 | early-layer vision token pruning; shallow feature token importance; explainable ViT pruning; causal token information | 复核 Patch Slimming、METR、Dyna-ViT、QuietPrune；补入 X-Pruner、EmbedLens 与 Information Horizon，区分热图、probe 与因果删除解释 |
| Q10 | token merging ViT classification throughput accuracy; ToMe PiToMe DTEM TPS ToFu DiffRate; VLM visual token merging | 复核 ToMe、STViT、DiffRate，补入 TPS、ToFu、PiToMe、DTEM、PruMerge、Libra-Merging 与 AdaptMerge；只在同主干同硬件表内判断速度—精度优劣 |
| Q11 | Women also Snowboard forced attention region; right for the right reasons token pruning; region supervised visual token pruning; rationale mask token pruning | 精读 Equalizer；沿 HINT/GAIC 区分证据依赖监督与 attention 对齐；补入 LAPS、VLTP、CROP、MVP-Token，并与既有 SafeWatch/QuietPrune 对照 |
| Q12 | autoregressive VLM visual token pruning latency TTFT end-to-end 2025 2026; UniPruneBench; SIEVE; PACE; VScan; SparseVILA; ZipVL; VFlowOpt; HAWK; V2Drop; EvoPrune | 以统一复现和原论文实测为两条证据线，区分 encoder、prefill、TTFT、decode 与 total runtime；综合见 [[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]] |
| Q13 | visual encoder early token pruning generative MLLM; METEOR; FiCoCo-V; iLLaVA; MustDrop; AdaptMerge; EvoPrune; FlowCut; QuietPrune; VScan; DeSAP; Skip-Vision | 2026-09-16 严格核验 ViT 出口之前真实减少序列且评测自回归文本生成；FlowCut、METEOR、QuietPrune 是剪枝核心，FiCoCo-V 混合；其余四项核心为合并；VScan 使用输出层特征，不按 intra-ViT 归类；综合见 [[LLM-Wiki/research/visual-token-pruning/early-encoder-pruning-and-interpretability.md]] |
| Q14 | 2026-09-17：既有时延基线的 batch size / GPU / TTFT / total / generation latency 定向回查；SparseVILA fixed decode length；ZipVL maximum batch；V2Drop Table 5 | 核对 UniPruneBench v2、VisionZip 本地 CVPR 原件、SparseVILA ICCV 效率片段及后续 arXiv v1、其余原文效率段落；新增 10 篇定向 skimmed 来源笔记，修正可变最大 batch、LLM-only 与 TTFT 的 E2E 误读；未运行代码，未以未报告设置证明不支持 batch；审计回填既有 SOTA 页 |

候选尚不构成 motivation；后续阅读结果、唯一来源 ID、版本和排除原因在本页更新。当前项目主文为 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|短政策视觉剪枝计划]]。

## 阅读结果与版本边界

| 方法 | source_id / 笔记 | 本轮层级 | 处理 |
|---|---|---|---|
| epic | [[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-epic.md]]；`paper-wen-2025-epic` | deep-read / source-checked | 2510.00515v1；会议身份另核对 NeurIPS 2025 官方页 |
| tbd | [[LLM-Wiki/research/visual-token-pruning/papers/2026-guo-token-budget-distillation.md]]；`paper-guo-2026-token-budget-distillation` | deep-read / source-checked | 2608.28138v1，2026-08-28；会议标注来自稿件，未独立确认 proceedings |
| vico | [[LLM-Wiki/research/visual-token-pruning/papers/2025-wang-internvl35-vico.md]]；`paper-wang-2025-internvl35` | skimmed / source-checked | 2508.18265v2；仅聚焦 ViR/ViCO，authors 登记第一作者，完整名单见原文 |
| etc | [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-etc.md]]；`paper-gao-2026-etc` | deep-read / source-checked | 2606.00543v2；§1–5、附录 A.1–A.2、图表与执行路径 |
| dualspeed | [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-dualspeed.md]]；`paper-zhang-2026-dualspeed` | skimmed / source-checked | 2602.03815v1 |
| ood | [[LLM-Wiki/research/visual-token-pruning/papers/2026-gu-ood-vtp.md]]；`paper-gu-2026-ood-vtp` | skimmed / source-checked | 2607.22716v1；稿件会议 DOI 为占位符，不据此确认录用 |
| etprune | [[LLM-Wiki/research/visual-token-pruning/papers/2026-ding-et-prune.md]]；`paper-ding-2026-et-prune` | skimmed / source-checked | 2608.01979v1 |
| visco | [[LLM-Wiki/research/visual-token-pruning/papers/2026-zheng-visco.md]]；`paper-zheng-2026-visco` | skimmed / source-checked | 2607.12756v1 |
| evidencerl | [[LLM-Wiki/research/visual-token-pruning/papers/2026-huang-evidence-rl.md]]；`paper-huang-2026-evidence-rl` | skimmed / source-checked | 2608.08021v1 |
| attcot | [[LLM-Wiki/research/visual-token-pruning/papers/2026-sinha-att-cot.md]]；`paper-sinha-2026-att-cot` | skimmed / source-checked | 2606.01558v1 |
| llavolta | [[LLM-Wiki/research/visual-token-pruning/papers/2024-chen-llavolta.md]]；`paper-chen-2024-llavolta` | discovered / unverified | 2406.20092v2；本轮仅题录/摘要与作者项目页 |
| pyramiddrop | [[LLM-Wiki/research/visual-token-pruning/papers/2024-xing-pyramiddrop.md]]；`paper-xing-2024-pyramiddrop` | discovered / unverified | 2410.17247v2；本轮只核题录/摘要 |
| efficientvlm | [[LLM-Wiki/research/visual-token-pruning/papers/2022-wang-efficientvlm.md]]；`paper-wang-2022-efficientvlm` | skimmed / source-checked | 2210.07795v1；蒸馏后缩短视觉/文本/融合层 |
| patch-slimming | [[LLM-Wiki/research/visual-token-pruning/papers/2022-tang-patch-slimming.md]]；`paper-tang-2022-patch-slimming` | skimmed / source-checked | 2106.02852；final→early patch 选择先例 |
| metr | [[LLM-Wiki/research/visual-token-pruning/papers/2024-liu-metr.md]]；`paper-liu-2024-metr` | skimmed / source-checked | ICLR 2024 官方页/PDF；多出口 early pressure+自蒸馏 |
| fastvlm | [[LLM-Wiki/research/visual-token-pruning/papers/2025-vasu-fastvlm.md]]；`paper-vasu-2025-fastvlm` | skimmed / source-checked | CVPR 2025；新混合视觉编码器，显式测 vision+prefill |
| dyna-vit | [[LLM-Wiki/research/visual-token-pruning/papers/2026-rubab-dyna-vit.md]]；`paper-rubab-2026-dyna-vit` | skimmed / source-checked | CVPR 2026 Findings；无参 pre-encoder saliency |
| quietprune | [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md]]；`paper-gao-2026-quietprune` | deep-read / source-checked | CVPR 2026；§1–6、Figures 2–7、Equations 1–16、Tables 1–2；query adapter 引导 ViT 内早剪 |
| responseguard | [[LLM-Wiki/research/visual-token-pruning/papers/2026-na-responseguard.md]]；`paper-na-2026-responseguard` | deep-read / source-checked | 2607.21401v1；§1–6、主表、视觉差距与校准 |
| sap | [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md]]；`paper-wang-2026-sap` | skimmed / source-checked | 官方作者仓库；正文链接本轮未得，会议状态仅按仓库登记 |
| sit-frd | [[LLM-Wiki/research/visual-token-pruning/papers/2022-zong-self-slimmed-vit.md]]；`paper-zong-2022-self-slimmed-vit` | skimmed / source-checked | ECCV 2022；RTSM 训练期稠密恢复+逐 block MSE |
| em-kd | [[LLM-Wiki/research/visual-token-pruning/papers/2026-feng-em-kd.md]]；`paper-feng-2026-em-kd` | skimmed / source-checked | AAAI 2026；Hungarian matching+视觉语义/图文 affinity 蒸馏 |
| restore | [[LLM-Wiki/research/visual-token-pruning/papers/2026-cho-restore.md]]；`paper-cho-2026-restore` | skimmed / source-checked | ICML 2026；位置与注意力失真校准、anchor merging |
| otprune | [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-otprune.md]]；`paper-chen-2026-otprune` | deep-read / source-checked | arXiv 2602.20205v3；§1–6 与附录；原文标注 CVPR 2026 |
| equalizer | [[LLM-Wiki/research/visual-token-pruning/papers/2018-burns-women-also-snowboard.md]]；`paper-burns-2018-women-snowboard` | deep-read / source-checked | arXiv 1803.09797v4；§1–4、公式 (1)–(6)、Tables 1–3 与附录；核实为反事实遮挡输出约束而非训练 attention-map 对齐 |
| HINT / GAIC | `paper-selvaraju-2019-hint`；`paper-tang-2020-gaic` | skimmed / source-checked | 官方 CVF 页与 arXiv 摘要/方法概览；属于 grounding/attention 监督后续，不执行 token pruning |
| LAPS / VLTP / CROP | `paper-fu-2024-laps`；`paper-chen-2025-vltp`；`paper-guo-2025-crop` | skimmed / source-checked | 语言监督 patch slimming、任务条件逐 token scorer、query-region 引导剪枝三条直接路线；任务均非安全判别 |
| MVP-Token | `paper-anonymous-2026-mvp-token` | discovered / unverified | 匿名 ACL 稿件部分可读；以 grounding+segmentation patch mask 参与多视角 pruner 监督，发表状态与完整结果待核 |

第一次训练参与调研登记 14 条来源：原表 12 条及下列 2 条待核候选；新增 12 篇笔记（现为 3 deep-read、7 skimmed、2 discovered）。针对用户三项策略的二次排重再登记 8 条来源并新增 8 篇笔记（1 deep-read、7 skimmed）。表征恢复补检新增 4 条来源与 4 篇笔记（现为 1 deep-read、3 skimmed）。累计登记 26 条来源、24 篇笔记（5 deep-read、17 skimmed、2 discovered）；来源原件未下载，仅登记稳定 URL；未改动已存 PDF、原始实验和旧笔记。

- LOREAL：`paper-wang-2026-loreal`；[CVF PDF](https://openaccess.thecvf.com/content/CVPR2026/papers/Wang_LOREAL_Mitigating_Low-Resolution_Challenges_in_Vision-Language_Models_with_Attribute-driven_Prompt_CVPR_2026_paper.pdf) 搜索可见，但直接 PDF/HTML 访问失败；discovered，作者字段待核，不用于正式动机。它是 G1 新颖性结论的重要未决项。
- CoViPAL：`paper-2026-covipal`；[OpenReview 稿件](https://openreview.net/pdf?id=RqY4w2gxW9) 仅搜索片段；discovered，题录/状态待核，不用于正式动机。
- Q5 补检：`visual token training September 2026`、`visual token safety distillation guard`、`visual token counterfactual training`，发现并回读 Evidence-RL 与 Att-CoT；LOREAL 另用题名查询。
- Q6/Q7 补检表明三项单点均有直接最近邻：EfficientVLM/METR 对应浅层任务蒸馏，Dyna-ViT/QuietPrune 对应前置或 ViT 内早剪，EPIC/TBD 对应剪枝状态再训练；SAP 进一步排除“首次安全感知 token pruning”。Q8 表明稠密特征恢复、不等长匹配、任务统计量、分布保持与注意力校准均有先例；未检索到直接以闭式最小二乘恢复安全证据子空间的工作，但此结论仅是有限检索结果。
- Q12 表明没有跨模型、预算和硬件的单一 SOTA。UniPruneBench 在 A100-40GB 上给出最可信的同条件基线；SIEVE、PACE、VScan 等论文自报点展示更高加速，但必须按 total、TTFT、prefill 和 decode 分别解释，不能用 FLOPs 或 prefill 加速替代端到端收益。
- Q13 复用 QuietPrune 深读，新增 7 篇 skimmed 笔记与 5 条唯一来源：FlowCut 核 arXiv v3 §2–4、附录 A.4–A.5 及 NeurIPS proceedings；METEOR 核 v1 §3.2/4.1/主表及 ICCV 正式题录；FiCoCo 核 v3 方法、§7 实现与 AAAI 正式题录；iLLaVA 核 v2 §3.2/4 及 ICLR proceedings；MustDrop 核 v1 §3.3/4；AdaptMerge 核 ACL PDF §3.2.1/4；EvoPrune 核 v1 Algorithm 1/§3–4。无模型/代码复现，新增来源只登记原文 URL，未复制 PDF。DeSAP 虽称 encoder-side，但方法依赖最后层 attention，未确认其压缩发生在最后 block 完成之前，不纳入严格表；Skip-Vision 的摘要不足以证明 intra-ViT drop，也不纳入。此批是定向搜索，不能证明不存在更早先例。
- 其他发现但未入核心比较：LRCP/EvoCut/SPARE（选择规则）、LiteFrame（换视觉编码器）、RADIOv2.5（视觉基础模型蒸馏）、长视频 selection/reinvestment。只作为后续检索线索，不据此概括具体论文方法或推出研究空白。

## 既有证据复用

Security Pitfalls 复查原文 §3–5 的压缩专属攻击与任务范围；VTC-Bench 核对 ACL 页面并沿用库内 PDF/主文分析；M3/VisionThink 复用既有来源。未整体提升这些论文的阅读深度，也未新建重复来源。SafeWatch、GuardReasoner-VL、DART 等使用已有 Wiki 笔记与主文。

XGuard 2026-09-07 的探索结果与 2026-08-26 text-only 微调负结果均保留。双向因果审计是计划而非已得到结果。

## 覆盖不足与证据门槛

本轮针对性搜索覆盖公开可访问材料，不等于 2026-09-08 前全部工作；无检索命中不能证明不存在。近期 arXiv 的会议页眉可能含占位元数据，TBD/OOD-VTP 不仅凭页眉宣布正式录用。EPIC 的 NeurIPS 2025 身份已核对[官方页](https://papers.nips.cc/paper_files/paper/2025/hash/6518f9339196e172fa0ceef48a85543a-Abstract-Conference.html)。

强新颖性排重仍需 LOREAL、CoViPAL 原文及更广泛低分辨率/选择性预测研究。本轮不声称复现实验或发现确定空白；候选差异均附反证和停止条件。正式动机引用事实已映射到来源/实验，方法效果均为 hypothesis。
