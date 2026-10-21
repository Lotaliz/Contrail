# 修改记录

本文件按实际发生的 Wiki 内容、结构和流程变化记录，与 Git 状态、暂存或提交无关。日期按新到旧排列。

统一格式：

    - [类型] [范围] 一句话说明结果（可选：详情链接）。

允许的类型：Added、Changed、Fixed、Deprecated、Removed。


## 2026-10-21

- [Changed] [raw, metadata/workflows] 将整个 raw 资料库及来源登记表改为仅本地保存，统一目录级忽略规则并说明新克隆恢复来源表的要求（[[LLM-Wiki/changes/2026-10-21-raw-local-only.md|范围与清单]]）。

## 2026-10-13

- [Removed] [raw, metadata/workflows] 将论文 PDF/HTML 原文改为不发布的本地阅读副本，保留来源和哈希并将原文链接改为官方地址，当前版本及后续提交不再包含原件（详情：[[LLM-Wiki/changes/2026-10-13-untrack-paper-originals.md]]）。

- [Added] [research/visual-token-pruning, raw/sources] 按用户唯一选择完成SheafPrune全文精读，保存并登记完整原件，通俗说明场景、图排序、预算条件与训练部署，核对最优超参数上沿和固定配置消融、区分prefill与完整回答时延，同步比较及阅读导航，校验后晋升候选（[[LLM-Wiki/research/visual-token-pruning/papers/2026-ma-sheafprune.md|SheafPrune精读笔记]]）。

- [Added] [research/visual-token-pruning/watch, raw/sources] 完成2026-10-13失败窗口的四组检索重试，登记10篇新题录，其中4篇直接相关和1篇相邻进入pending、5篇排除仅作查重，保留人工决定并记录1篇既有来源的实际v2版本（[[LLM-Wiki/research/visual-token-pruning/watch/runs/2026-10-13-020129Z-retry1.md|批次日志]]）。

## 2026-10-10

- [Added] [research/visual-token-pruning, experiments, raw/sources] 调研政策条件安全表征指导视觉证据保留，新增 SAHs/SASA/ShiftDC 三篇略读与 Qwen3-VL 接口来源，比较语言拒答、视觉早层与区域贡献并区分其与 Cx 预算的分工，同步项目导航及用户报告的自适应实验运行状态，未新增结果或正式 motivation（[[LLM-Wiki/research/visual-token-pruning/cx-policy-safety-representation-pruning.md|综合]]）。

- [Changed] [metadata/workflows, .agents/skills/paper-ingestion] 固化后续精读先讲场景、问题和概念、使用通俗中文解释方法与结果的原则，并同步三级阅读规范及技能入口，保留技术证据要求，既有论文笔记未改动（[[LLM-Wiki/metadata/workflows/paper-ingestion.md|精读表达原则]]）。

- [Changed] [research/visual-token-pruning, raw/sources] 按用户最新筛选完成第二批七篇 selected 全文精读，新建六篇并升级 SAP 既有笔记，登记完整原件与获取缺口、同步方法比较和阅读入口，并在校验后晋升候选（[[LLM-Wiki/changes/2026-10-10-selected-watch-second-batch-deep-read.md|详情]]）。

- [Changed] [research/visual-token-pruning, experiments] 按用户要求将当前自适应视觉预算方法更名为 Cx，同步主方案文件、方法记录目录、配置及关联链接，保留 C5 历史结果和稳定 ID（[[LLM-Wiki/changes/2026-10-10-cx-method-rename.md|详情]]）。

- [Changed] [research/visual-token-pruning, experiments, raw/sources] 结合用户报告的小图条件将双重要性方案的局部绝对档位示例修正为 0/8/16，补充裁图相对参考网格及框面积的独立作用，并核对登记 Qwen 官方 resize 源码以区分信息分辨率和编码容量，未规定数据使用或执行协议（[[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|方案]]）。

- [Changed] [research/visual-token-pruning, experiments] 按用户要求将双重要性文档收敛为 v2 方法方案，移除数据规模/范围、具体执行步骤、门禁及失败处置，将代价简化为 NLL 与标签不一致、两路预算各三档，补充条件局部收益与局部独立充分性的区别，并同步配置及记录入口（[[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|方案]]）。

- [Added] [research/visual-token-pruning, experiments] 将用户的双重要性预算规划细化为全局升级/条件局部收益曲线，创建可执行算法、默认配置和待执行实验记录，明确共同监督尺度、合法预算映射、辅助中间量、政策控制及解释审计，并同步项目和实验入口（[[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|方案]]）。

- [Changed] [research/visual-token-pruning, metadata/workflows, raw/sources] 完成最近失败窗口重试并新增 5 篇 pending 与 9 篇查重排除题录，精读六篇 selected、保存完整原件并晋升 ingested，同时将每批新增 pending 限为十篇、其余相关记录单列备查（[[LLM-Wiki/changes/2026-10-10-arxiv-watch-cap-retry-selected-read.md|详情]]）。

- [Fixed] [raw/sources] 补齐六篇既有来源对应的十个 HTML/PDF 原件路径、SHA256 和本地许可登记，在同一来源内保留补充格式，修复 wiki-finalize 的原件未登记错误，原始文件保持不变。

- [Changed] [research/visual-token-pruning, raw/sources] 按用户最新决策将 C5 主线更新为不锚定 5% 的逐样本全局/单局部预算分配，补充最小充分配置监督与相关机制比较，新增 ResAdapt/M3/VisionThink 快读及 AdaAlloc 项目页筛查，复用既有来源并修正 VisionThink 许可，同步方案、项目和阅读入口（[[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md|当前方案]]）。

## 2026-10-09

- [Changed] [experiments, research/visual-token-pruning] 记录 NLL 收益 router 的定性负结果，提出复用 C5 的单次执行高清升级门与预算—路线联合评分，明确共同收益基准、多预算 Guard 适配及平均预算/时延约束，并同步项目和实验入口（[[LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md|方案]]）。

## 2026-10-08

- [Added] [experiments, research/visual-token-pruning, raw/sources] 归档并分析 C5 原始报告，给出单局部框下政策配对收益、匹配像素干预和条款级路由建议，补入 GapSight/PF-CBM 快读与来源；结合后续错误分析补充尺度/宽高比单框候选、预算清晰度边界和政策入评分的具体例子，并更新项目和实验入口（[[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md|建议]]）。

- [Fixed] [experiments, research/visual-token-pruning] 根据用户补充明确 C5 Guard 恢复训练已包含政策翻转且使用 CE，将收益/政策差分目标限定为 router 监督，并说明相对 Global100 的代价平移不改变 teacher 排序及直接奖励 Guard 相对收益的退化风险。

- [Changed] [experiments, research/visual-token-pruning] 记录 C5 router 的四项实际目标，补充统一完整路线收益、纯回归和回归＋联合 KL 的替换方案，明确层次 KL 合并的等价条件、收益零点、风险权重与选路 regret 门禁。

- [Fixed] [research/visual-token-pruning] 明确条款 MLP 的训练标签应来自合法单条款变更的路线收益差与匹配像素干预，区分条件边际效应和不可唯一识别的绝对贡献；补充单样本 teacher 代价/NLL 的收益定义、任务与时延收益分离、缺失配对 mask、可选 grounding 先验及非可加边界。

- [Fixed] [research/visual-token-pruning/watch] 补回被旧版覆盖的候选索引条目，并以当前索引为准保留用户筛选决定。
- [Added] [research/visual-token-pruning/watch, raw/sources] 重试完成原十天窗口的四组 arXiv 检索，新增 23 篇相关或相邻候选与 16 篇查重排除题录，复用 65 个既有候选及 SAP 来源，并保留原限流失败日志与人工决定。

## 2026-10-03

- [Added] [research/visual-token-pruning/watch, raw/sources] Collected the complete rolling ten-day arXiv window, screened 93 new title/abstract records (21 direct, 26 adjacent, 46 out-of-scope), retained user decisions, and recorded query coverage and deduplication in the batch log.
- [Fixed] [research/visual-token-pruning/watch, metadata/workflows/arxiv-watch] 将本批 93 条候选及排除理由改为中文，并明确后续索引理由的中文书写与写入前检查要求。
- [Changed] [research/visual-token-pruning/watch, raw/sources] 按用户筛选边界将 5 篇以在线策略自蒸馏为主的论文移至仅查重排除表，并在后续标题摘要筛查中排除同类论文，同时保留已选择的精读候选。

## 2026-09-25

- [Added] [research/visual-token-pruning/watch, raw/sources] 完成 2026-09-25 的 10 天 arXiv 检索，登记 4 篇直接相关、1 篇相邻及 10 篇去重排除论文，复用 26 个既有候选并保留人工决定。
- [Added] [research/visual-token-pruning/papers, raw/papers] 精读用户新选定的 Riemannian Metrics、CoRePrune 与 STD，保存三份 arXiv v1 原件并更新来源、阅读日志和候选状态。

## 2026-09-24

- [Changed] [research/visual-token-pruning/watch] 精读索引中选定的 SLICEChat、ME-VLM、VPRune、CounterCredit 与 QCPruner，保存五份当前版本原件并升级来源；排除表删除 `pending` 决策列，out-of-scope 条目改为仅查重记录（详情：[[LLM-Wiki/changes/2026-09-24-selected-watch-deep-read-and-exclusion-policy.md]]）。

- [Removed] [raw/papers, research/visual-token-pruning] 清理未精读论文副本与过时方案，保留精读原件和最新短政策研究计划，并同步来源路径与链接（详情：[[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md]]）。

## 2026-09-23

- [Changed] [research/visual-token-pruning] 将当前课题切换为模板短政策条件下的文本政策指导视觉 Token 剪枝，整理 v1–v3 数据构造、短政策证据边界和首轮同场景 baseline 协议，并将联合压缩方案标为历史路线（[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|新版方案]]）。

## 2026-09-22

- [Changed] [research/visual-token-pruning] 将路线二定稿为视觉—政策文本相互指导的联合压缩，核对 PolicyShiftGuard-3B/7B、SafeGuard-VL-RL 及两套公开数据的可用性与许可，并以“零新增人工标注、零全量 Guard 重训、允许 selector/LoRA 适配”替代不可证的零训练前提（[[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md|历史方案清理记录]]）。
- [Changed] [research/visual-token-pruning] 深读 SafeGuard-VL 与 PolicyShiftGuard，区分跨政策泛化和同图政策翻转两种任务定义，比较语义 SFT+RLVR 与属性规则+边界配对训练，并将 PSS、双重反事实和长政策未覆盖边界回填路线二计划（[[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|比较]]）。
- [Changed] [research/visual-token-pruning, research/safety-classifier-compression] 根据长政策 token 主导与 pure-visual 90% 剪枝仅 1.14× 的用户报告约束，将路线二转为政策编译/条款检索与 pre-ViT 视觉选择协同预算；补入 MADTP、SafeGuard-VL、PolicyShiftGuard 和 Gist Tokens 证据，并保留精度提升为待反证次要假设（详情：[[LLM-Wiki/changes/2026-09-22-long-policy-bottleneck-pivot.md]]）。
- [Added] [research/visual-token-pruning/watch] 完成滚动 10 天 arXiv 收集，60 条命中合并为 39 个唯一 ID，登记 6 篇直接相关、6 篇相邻与 12 篇排除题录，复用 15 个既有来源并保留人工决定，记录完整 API 分页与筛查边界（详情：[[LLM-Wiki/changes/2026-09-22-arxiv-watch.md]]）。

## 2026-09-21

- [Changed] [research/multimodal-safety-guard, research/multimodal-compositional-safety, research/visual-token-pruning] 将研究重组为两条独立投稿路线：专业 Guard 的图文组合式规避与兼容防御，以及 `(image, policy)` 的 ViT 前视觉 Token 剪枝；补充可行性、方法、实验、会议写作、阶段门和停止条件（详情：[[LLM-Wiki/changes/2026-09-21-multimodal-guard-two-track-plan.md]]）。
- [Removed] [research/multimodal-compositional-safety, research/visual-token-pruning] 删除三个旧方案/评估文档并重定向跨库链接；保留论文笔记、原始来源、阅读日志、专题综述、实验记录和负结果。

## 2026-09-20

- [Added] [research/multimodal-compositional-safety] 从安全四大当前 CFP 与既有多模态 Guard 近邻评估快速图文 Token 联合判别器，结论为问题必要性和研究基础充分，但需以可利用的组合式逃逸、明确威胁模型、风险校准防御及端到端系统证据建立安全顶会创新；该旧评估于 2026-09-21 并入 [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|当前路线一计划]]。

- [Added] [research/visual-token-pruning] 精读近期追踪中选定的 G2TM、StepPrune、VIP-Router、AdaVSkip 与图表读数因果定位，保存五份原件及哈希，更新来源、候选状态、项目入口与阅读日志，并记录方法边界及未复现实验（详情：[[LLM-Wiki/changes/2026-09-20-selected-watch-deep-read.md]]）。

- [Added] [research/multimodal-compositional-safety] 调研安全图像与安全文本组合后的内容风险，登记 SIUO、MSTS、MSSBench、Hateful Memes 及攻防近邻来源，比较任务模型对齐失效、自动判别漏检和 strict 定向 Guard 防御，并给出三标签反事实评测与研究缺口（[[LLM-Wiki/research/multimodal-compositional-safety/overview.md|综述]]）。

## 2026-09-18

- [Added] [research/visual-token-pruning] 核验 SafeAtlas-VL 完整训练集安全样本及公开 1M 版本边界，保存原始论文与定向笔记，区分配对相关性和联合判别必要性并推导 core-only 请求/回复的文本教师捷径，标明缺模态消融与原始记录统计尚未完成（[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-safeatlas-vl.md|核验]]）。

- [Added] [research/visual-token-pruning] 评估浅层图文联合判别、unsafe 单侧早退出和不确定分支剪枝，补入 MuE/VLSU/SingGuard 定向来源及会议范围，记录流量比例、全链错误预算、残余分布和真实时延的验证门槛与主观会议适配；该旧分支评估于 2026-09-21 删除，历史记录保留于 reading-log。

- [Changed] [research/visual-token-pruning] 新增 PuMer 精读并将 CDPruner 升级为精读，复用原件并只读审查两者固定代码版本，比较图文 attention 复用与额外 embedding/DPP 的成本和训练/选择性能机制，记录吞吐计时边界及公开相关性符号不一致（[[LLM-Wiki/research/visual-token-pruning/pumer-cdpruner-text-conditioning-cost.md|比较]]）。

- [Changed] [research/visual-token-pruning] 定向核对并收录 NeurIPS 2025 CDPruner 条件 DPP 方法及原始结果，补充 AutoPrune 的 Qwen 基线保真度、只读版面检查与有条件投稿潜力判断，区分公开来源事实和主观评审意见（[[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-liu-autoprune-ai4ai.md|AutoPrune]]）。

- [Added] [research/visual-token-pruning] 精读 AI4AI/AutoPrune v2 并只读审查固定版本最终策略与搜索实现，保存原件，核对模型角色、post-projector 有限交换/回灌和人工基线优势，记录聚合口径、已有搜索历史及计时边界的未决项（[[LLM-Wiki/research/visual-token-pruning/papers/2026-liu-autoprune-ai4ai.md|笔记]]）。

- [Added] [research/visual-token-pruning/watch] 执行滚动 10 天定时收集，API HTTP 406 后网页回退新增 G2TM 直接相关候选与 5 篇排除题录、合并 4 篇已知命中并保留人工决定，记录 partial 覆盖与补查范围（详情：[[LLM-Wiki/changes/2026-09-18-arxiv-watch.md]]）。

## 2026-09-17

- [Fixed] [research/visual-token-pruning] 审计既有时延基线的生成任务、硬件、请求 batch 与计时边界，修正 ZipVL 可变最大 batch、V2Drop 的 LLM-only 与全模型/全数据集区别及 PACE/EvoPrune 的 TTFT 边界，并补齐定向来源笔记（详情：[[LLM-Wiki/changes/2026-09-17-vlm-latency-protocol-audit.md]]）。

## 2026-09-16

- [Changed] [research/visual-token-pruning] 严格筛选生成式 MLLM 在 ViT 出口之前的 token 减少，补入 FlowCut/METEOR/FiCoCo-V 与四项合并先例的分级证据，修正 VScan 的输出端位置和 EvoPrune 的合并机制，并记录联合收益归因边界（详情：[[LLM-Wiki/changes/2026-09-16-generative-intra-vit-pruning.md]]）。

- [Changed] [research/visual-token-pruning] 将用户指定的 StackTok 从近期发现候选升级为精读，保存原文与哈希，核对参考门控、共享 crop 预算和主表/附录消融，明确无实测加速与 OCR 退化边界，并同步来源和候选索引（[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|笔记]]）。

- [Added] [research/visual-token-pruning/watch] 完成首次近 10 天 arXiv 轻量收集，将 49 条命中合并为 32 篇并登记候选与来源（直接相关 10、相邻 7、待核验 1、排除 14），保留 pending 供人工选择（详情：[[LLM-Wiki/changes/2026-09-16-arxiv-watch-first-run.md]]）。

- [Added] [research/visual-token-pruning/watch] 建立滚动 10 天 arXiv 发现索引、检索日志、人工筛选到精读晋升的流程与仓库 skill，提供每周两次的维护建议，尚未运行检索或启用调度（详情：[[LLM-Wiki/changes/2026-09-16-arxiv-watch-design.md]]）。
- [Added] [research/visual-token-pruning] 汇总多模态自回归 VLM 视觉 Token 剪枝的统一复现与论文自报时延—性能基线，区分 encoder、prefill、TTFT、decode 与端到端口径，并精读 UniPruneBench 作为跨方法校准依据。

## 2026-09-15

- [Added] [research/ai-system-security-landscape] 结合 USENIX Security、NIST AI 100-2、OWASP GenAI Top 10 与 MITRE ATLAS，建立安全属性 × AI 生命周期二维分类并梳理 2025—2026 热门系统安全问题。
- [Added] [research/model-compression-privacy] 精读 USENIX Security 2026 CompLeak，并以 2025—2026 安全顶会十篇代表工作定位 MIA 主流程度与攻击/防御前沿，区分单模型、多版本差分、现实威胁模型及生成式大模型外推边界。

## 2026-09-14

- [Changed] [research/visual-token-pruning] 将 QuietPrune 升级为精读，补齐逆 projector adapter、`[Q-CLS]` 评分、三阶段半结构化剪枝、被删 token 聚合、自蒸馏、主要实验与安全迁移边界。
- [Added] [research/safety-classifier-compression] 按选择位置、attention 校正、相关性—覆盖和动态证据预算梳理生成式 MLLM 的文本指导视觉 Token 剪枝，并形成面向 Qwen3-VL 安全 Guard 的组合方案与基线。
- [Fixed] [research/safety-classifier-compression] 将视觉—文本 Token 压缩范围收缩到 Qwen3-VL/LLaVA 式 decoder-only 生成 Guard，补入 AIM、AsymVLM、Hi-Lo Prune 与长上下文文本剪枝证据，并把 PuMer、SmartTrim、CrossGET 降级为非同构机制来源。
- [Changed] [research/safety-classifier-compression] 区分文本指导的纯视觉剪枝与视觉—文本 Token 共同压缩，补入 PuMer、SmartTrim、CrossGET、SafePTR 与 TrimTokenator 的机制和反证，并将安全判别缺口收束为固定漏报风险下的样本级分模态联合预算。
- [Changed] [research/visual-token-pruning] 精读 Equalizer 的反事实区域约束，梳理 HINT、GAIC、LAPS、VLTP、CROP、MVP-Token 与 SafeWatch 的后续谱系，并将安全剪枝方案收束为政策条件证据组覆盖、必要性干预和无关背景不变性。
- [Added] [experiments/20260914-dual-evidence-token-compression] 将完整视觉前缀、双头证据选择、context residual merge、类别边界监督、原生视觉尾部 LoRA 适配及位置与物理 compact 约束整合为可证伪实验设计。
- [Added] [research/visual-token-pruning] 梳理视觉 Token 合并的池化、匹配、语义凝聚、信息回灌、学习式和 VLM 条件合并路线，并按可比实验区分免训练吞吐、分类精度与重训练上界。

## 2026-09-10

- [Added] [research/visual-token-pruning] 综合视觉编码器前与浅层内部 token 剪枝先例，并将解释证据区分为空间相关性、表示可解码性、输出因果效应和充分集稳定性，形成面向多模态安全判别的可证伪设计建议。

## 2026-09-09

- [Changed] [metadata, skills, research/visual-token-pruning] 将 ETC 与 OTPrune 的公式改为 Markdown 预览支持的 `$...$` 和 `$$...$$`，并把数学定界符规范写入维护约定、研究技能及 Wiki 校验器。
- [Changed] [research/visual-token-pruning] 将 ETC 与 OTPrune 升级为精读，区分训练期任务表征重构与无恢复的 OT 子集覆盖，补全执行路径、实验边界及面向早层安全充分性蒸馏的迁移判断。
- [Changed] [concepts/technology] 补充标准 ViT 从 RGB patch 到 `[B,N,D]` token 序列的张量变换、颜色通道投影与编码器输入口径，并澄清固定序列长度下的逐层计算、并行注意力、真实 token 剪枝位置及已有早剪先例。
- [Changed] [research/visual-token-pruning] 补检少量视觉 token 与完整表征的恢复和对齐方法，新增 SiT/FRD、EM-KD、RESTORE、OTPrune 四条来源及论文笔记，并将候选空白收束为安全证据加权的训练期线性可恢复性。

## 2026-09-08

- [Changed] [research/visual-token-pruning] 对缩短视觉塔、前置剪枝和压缩样本再训练做直接排重，将方法收束为政策因果安全充分视觉前缀、最坏压缩格训练与压缩翻转回放，并新增 8 条来源及论文笔记（[[LLM-Wiki/changes/2026-09-08-safety-sufficient-vision-prefix.md|详情]]）。

- [Changed] [research/visual-token-pruning] 将主线更新为同结构的任务与压缩联合训练，补充 EPIC、TBD、ViCO 等 14 条来源及 12 篇分级笔记，重写背景、候选空白和动机并加入可见性约束训练对照（[[LLM-Wiki/changes/2026-09-08-training-aware-visual-safety-pruning.md|详情]]）。

- [Changed] [research/ai-safety-systems-security-venues] 将 HMGUARD 从泛读升级为精读，补全 harmful meme 任务场景、HMCOT 方法、主结果与消融，并登记原始 PDF 及指标一致性、复现和部署证据边界。
- [Changed] [research/visual-token-pruning, experiments/20260908-bidirectional-token-intervention] 将 label-first 归因界定为可能受首标签中介的事后合理化，登记 Unfaithful CoT、label—rationale association 与 RORA，并加入标签前缀反事实、span 级标签支配指数和低成本 evidence-first/延迟承诺实验。
- [Added] [experiments/20260908-bidirectional-token-intervention] 将视觉 Token 剪枝的纠错/致错双向翻转预注册为因果干预审计，区分语义干扰删除、证据/关系损失、attention/position 重标定与随机边界抖动，并登记 DART、CrisPrune、EmbedLens、Information Horizon、VASparse 和 VisPruner 来源。
- [Changed] [research/visual-token-pruning] 调研视觉 Token 剪枝中的复杂推理退化、视觉遗忘与安全政策推理，登记 DSTP、TVC、Look and Think、VFlowOpt、Policy-Guided Safety Tuning 和 GuardReasoner-VL，并将候选缺口明确为 label-first Guard 中“感知保留但政策绑定失败”的诊断与推理保持压缩。

## 2026-09-07

- [Added] [experiments/20260907-xguard-token-pruning-analysis] 归档 XGuard 41 类安全分类、归因生成、Ghosted Layers、FastV、DivPrune 与降分辨率实验原始记录并完成派生复核，将研究优先级收束为逐样本 harmful-flip 审计、平衡长尾确认和 resolution-first 证据恢复。

## 2026-09-04

- [Changed] [research/visual-token-pruning] 将本会话的 Token 剪枝研究整理为单一方案文档，删除目录内其余专题与论文笔记，并重定向相关索引和跨项目链接（[[LLM-Wiki/changes/2026-09-04-consolidate-visual-token-pruning-research.md|详情]]）。
- [Added] [research/visual-token-pruning] 调研可解释性与 Token 剪枝交叉，登记 X-Pruner、FRESH、ERASER、TokenTM、GAP、SemVID、IF-Prune、FPVG 与解释指标反证，并将候选主线收束为带 provenance 的多模态安全证据瓶颈、非对称证据契约和不确定性回退。
- [Added] [research/visual-token-pruning] 评估离线 profile、fixed-shape token reducer 与 profile-aware batch serving 三层贡献的已有工作、实现风险和投稿路径，登记 E-AdaPrune、OccamToken、Conformal LLM Routing、PLA-Serve、HELIOS，并将主线收束为 risk-calibrated execution contract。
- [Added] [research/visual-token-pruning] 调研离线激活/梯度校准的 Token 选择与融合，登记 Prune and Merge、DiffPrune，区分固定结构、离线预算与训练式在线 selector，并将安全 profile 细化为固定执行骨架、动态内容寻址、空间覆盖/关系槽及归因恢复的候选路线。
- [Changed] [research/visual-token-pruning] 核验低分辨率安全关键样本的研究必要性，补充分辨率反事实漏报定义、现有工作覆盖边界与压缩状态攻击威胁，并登记《Less Is More—Until It Breaks》预印本。

## 2026-09-03

- [Added] [research/visual-token-pruning] 调研输入图像下采样、动态分辨率、低清先行/高清回退与均匀空间池化，登记 VTC-Bench、VisionThink、Qwen2-VL、M3、DeCo 原始论文，形成多模态安全判别的分辨率优先方案、失败边界和实验矩阵。

## 2026-09-02

- [Added] [research/visual-token-pruning] 核对 FastV、SparseVLM 与 DivPrune 的选择器、attention-kernel 和物理压缩开销，形成端到端时延成本模型、复现 profiler 清单及短标签安全 Guard 的低开销混合剪枝建议。
- [Added] [research/visual-token-pruning] 精读 CVPR 2026 MetaCompress，登记原始论文并梳理学习式压缩矩阵、attention 启发式反证、训练目标、实验边界及其与安全语义剪枝的区别。

## 2026-08-31

- [Changed] [concepts/methods] 将 DeepStack 从仅描述多尺度高分辨率 token 的定义扩展为跨层视觉信息注入家族，并基于 Qwen3-VL 技术报告与公开实现补充多深度 ViT 特征侧路、消融证据及空间 × 深度联合剪枝启发。

- [Added] [concepts/methods] 精读 NeurIPS 2024 DeepStack 并凝练视觉 Token 深度注入概念，明确固定 LLM 上下文、跨层有效 token、真实视觉编码成本及其与剪枝的边界。
- [Changed] [research/visual-token-pruning] 精读 TRIPS、PuMer、FastV、SparseVLM、VisionZip、DivPrune 与 SafeWatch，补齐问题场景、方法流程、实验条件、证据边界及多模态安全判别建议。
- [Added] [research/safety-classifier-compression] 精读 Ghosted Layers，登记 arXiv v2 原件并梳理无约束边界激活对齐、闭式求解、质量—效率证据、数学表述边界与安全 Guard 复用假设。
- [Added] [research/safety-classifier-compression] 调研 MHA 与 MLP 的任务作用、细粒度冗余和整块剪枝敏感性，形成多模态安全 Guard 的联合预算建议。
- [Fixed] [wiki] 将残留的 LaTeX `\[...\]` 与 `\(...\)` 公式统一改为 Markdown 阅读器支持的 `$$...$$` 与 `$...$` 语法，并完成全库扫描。

## 2026-08-28

- [Added] [research/safety-classifier-compression] 精读 Numerical Pruning，梳理 Newton 连续 mask、全局 attention-head/MLP-channel 结构选择、闭式权重补偿、实验依据与数学实现边界。
- [Changed] [research/visual-token-pruning] 核验自适应模型规模的子网抽取、权重驻留、模块加载和条件执行语义，并明确其在多模态安全 Guard 中的适用边界（[[LLM-Wiki/changes/2026-08-28-verify-adaptive-model-size-execution.md|详情]]）。

## 2026-08-27

- [Added] [research/safety-classifier-compression] 调研 BlockPruner 替代重要性指标，形成多模态安全任务的前向代理、Taylor/Fisher 与迭代真实消融三级剪枝方案（[[LLM-Wiki/changes/2026-08-27-survey-task-aligned-pruning-importance.md|详情]]）。
- [Added] [research/variable-length-llm-serving] 调研变长自回归请求的连续组批、Paged KV、chunked prefill、流水线均衡与 prefill/decode 解耦，结论为常规难题已较好解决但严格 SLO 和复杂集群下仍非彻底消失。
- [Changed] [research/visual-token-pruning] 深读 Sarathi-Serve、NanoFlow 与 Prism，补全请求组批、设备内异构资源重叠和跨模型显存弹性三层问题场景、系统创新、实验目的及证据边界。

## 2026-08-26

- [Changed] [research/visual-token-pruning] 补充 OSDI/SOSP/NSDI 动态网络与推理 serving 调研，将多模态 Guard 课题重构为风险/SLO 约束下的 Token—主干二维弹性执行、批处理与回退系统（[[LLM-Wiki/changes/2026-08-26-osdi-dual-adaptive-guard-serving.md|详情]]）。
- [Fixed] [experiments/20260825-safety-*] 修复 Llama Guard 1B/8B chat template 与判定位置实现错误，重跑三个预注册 safety-classifier-compression 实验并更新实验 README 与项目 overview：decoder S1-adapted 由 0.5000 修正为 0.9000，T8 由 0.5095 修正为 0.8141，encoder M1 由 0.7226 修正为 0.7997；三实验时延目标均达标，质量目标仍未达成（详见各实验 README）。
- [Added] [experiments/20260826-safety-pruning-finetuned] 完成 LoRA 微调后 Qwen2.5-VL-3B 安全判别在 60%–90% 视觉 token 剪枝下的性能扫描（9 条件 × 300 样本）：微调对 unsafe recall 无提升（C0=0.660），全剪枝范围最大降幅 < 3 pp，结论为检出率由模型固有能力决定而非 token 数量。
- [Added] [raw/sources] 登记 BeaverTails 数据集（dataset-ji-2023-beavertails），作为实验 20260826 LoRA 微调来源。
- [Changed] [metadata/tags] 修复 7 个 frontmatter 分隔符错误，为 56 篇论文补充受控技术标签并重构分类标签索引（[[LLM-Wiki/changes/2026-08-26-normalize-technical-tags.md|详情]]）。

## 2026-08-25

- [Changed] [research/safety-classifier-compression] 以安全顶会审稿视角重构 Guard 轻量化动机，新增计算不对称、自适应攻击与多模态证据完整性的研究缺口和投稿定位。
- [Changed] [research/ai-safety-systems-security-venues] 精读 Sentinel 与 VLM Unsafe Concepts，补全创新、研究场景、方法、证据定位、局限及标签，并登记原始论文 PDF。
- [Added] [research/ai-safety-systems-security-venues] 完成 2023—2026 安全四大顶会中内容安全、对齐、检测与系统治理工作的保守调研，纳入20篇核心论文并明确排除攻击方法（[[LLM-Wiki/changes/2026-08-25-survey-ai-safety-systems-security-venues.md|详情]]）。
- [Changed] [research/ai-safety-systems-security-venues] 重新泛读核对14篇现有论文，并将英文阅读记录统一改写为中文结构化笔记（[[LLM-Wiki/changes/2026-08-25-survey-ai-safety-systems-security-venues.md|详情]]）。

- [Changed] [experiments/20260825-vispco-qwen25vl-small] 修复 v1 hook 实现（KV-cache 绕过问题），改用 scoring pass + embedding 归零，重跑 Phase 1 v2（20 样本，B0 macro=0.817 vs B1=0.350，剪枝实际生效）与 Phase 2 v2（275 样本，六条件），H1 不满足（V2 相对 B1 仅 +0.73 pp），TextVQA 50% 预算下几乎归零；完整记录 v1/v2 运行、实现限制与序列压缩后续路径。
- [Added] [experiments/20260825-vispco-qwen25vl-small] 执行 VisPCO Qwen2.5-VL-3B 小规模配置优化测试（Phase 0–2 v1），记录环境冻结（模型 SHA、GPU、依赖版本）、负向运行（HF generate KV-cache 导致所有条件输出完全相同）并记录修复路径。
- [Added] [research/safety-classifier-compression] 调研 On-policy 蒸馏并凝练为概念实体，补充安全 Guard 的适用边界、方法路线、候选缺口与假设（[[LLM-Wiki/changes/2026-08-25-survey-on-policy-distillation.md|详情]]）。
- [Changed] [research/visual-token-pruning] 精读 VisPCO 的 Qwen2.5-VL 实验与官方实现，并新增不含代码的小规模预注册实验方案（[[LLM-Wiki/changes/2026-08-25-deep-read-vispco-qwen-experiment.md|详情]]）。
- [Changed] [wiki] 将品牌视觉与 Wiki 内容结构分离，在仓库根目录建立主 README 与响应式 HTML 封面，并移除 LLM-Wiki 内部 README。

## 2026-08-24

- [Added] [research/safety-classifier-compression] 深读 SafeWatch 并建立可生成归因的多模态自回归 Guard Token 剪枝证据、边界与实验路线（[[LLM-Wiki/changes/2026-08-24-safewatch-attribution-guard-token-pruning.md|详情]]）。

- [Added] [research/visual-token-pruning] 扩展图文多模态分类与生成 Token 剪枝调研，登记八篇正式论文并建立挑战、路线、反证与研究缺口（[[LLM-Wiki/changes/2026-08-24-survey-multimodal-token-pruning.md|详情]]）。

- [Added] [research/safety-classifier-compression] 完成近三年安全判别及相邻文本/多模态分类的剪枝与蒸馏进展调研（[[LLM-Wiki/changes/2026-08-24-survey-safety-classifier-compression.md|详情]]）。
- [Added] [research/visual-token-pruning] 精读 STViT 并建立涵盖 ViT 结构、任务、训练推理与 patch token 的视觉 Token 剪枝基础概念。
- [Changed] [metadata/changelog] 统一为按日期、类型与范围记录的 CHANGELOG，并移除所有 Git 状态依赖（[[LLM-Wiki/changes/2026-08-24-unify-changelog-style.md|详情]]）。
- [Added] [research/visual-token-pruning] 完成 2023–2026 视觉模型 Token 剪枝顶会进展调研（[[LLM-Wiki/changes/2026-08-24-survey-visual-token-pruning.md|详情]]）。
- [Added] [automation] 添加标准研究工作流、五个仓库技能、三级论文阅读、Wiki 校验器与 Codex Stop Hook（[[LLM-Wiki/changes/2026-08-24-standardize-research-workflows.md|详情]]）。
- [Changed] [research] 建立 research 项目分区并清理 concepts 种子概念（[[LLM-Wiki/changes/2026-08-24-add-research-layout.md|详情]]）。
- [Fixed] [index] 修复 entities 索引中 WikiLink 竖线破坏 Markdown 表格列的问题。
- [Added] [wiki] 初始化 LLM Wiki 的原始资料、概念、实验、索引、模板和维护结构（[[LLM-Wiki/changes/2026-08-24-initialize-wiki.md|详情]]）。
