---
id: note-2026-liu-autoprune-ai4ai
type: paper-note
title: "An AI4AI Framework for Visual Token Pruning"
authors: [Zhen Liu, Wenli Huang, Wei Song, Yuhan Liu, Zhiqin Yang, Jingwen Fu]
year: 2026
venue: arXiv
source_id: paper-liu-2026-autoprune-ai4ai
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, vision-language-model, visual-token-pruning, training-free, efficient-inference]
status: active
created: 2026-09-18
updated: 2026-09-18
---

# An AI4AI Framework for Visual Token Pruning

## 书目信息与精读边界

原文：[arXiv 2608.07193v2](https://arxiv.org/abs/2608.07193v2)，2026-08-07 首次提交，2026-09-06 修订；本地原件 [[LLM-Wiki/raw/papers/2608.07193v2.pdf]]，17 页。当前仅核实 arXiv 预印本身份，未确认正式会议录用。论文采用 arXiv perpetual non-exclusive license；作者代码采用 PolyForm Noncommercial 1.0.0，不应误记为 Apache/MIT。

精读范围：正文 Introduction、Related Work、Method、Experiments and Results、Conclusion；图 1–3、算法 1–2、表 1–14、附录 A–C。正文和附录结合官方 HTML 与 PDF 核对；关键表 1–3、6–9 和聚合指标公式核对 PDF 页 5–7、11–12。

实现审查来源：[[LLM-Wiki/raw/sources.yaml|来源登记]]中的 `code-autoprune-2026-release`；[公开仓库](https://github.com/AIM-ResearchLab/AutoPrune)，本轮固定观测版本 `23daf51afab87239d0c36760cd81326675d44b16`。只读检查最终 manifest、anchor/merge YAML、runtime wrapper、评分原子与 typed executor、搜索控制脚本及初始 history；未运行代码、下载数据、调用提案 API 或复现模型。算术复核仅从公开表格重新求和，不能标为 reproduced。

## 结论先行

作者提出 AutoPrune：用 LLM 在人为定义的 TPDSL 操作空间中，离线搜索对已有强剪枝器的小幅残差修正，冻结目标模型，部署时直接执行选定策略。

论文表格支持它在若干已测设置下提高基准聚合分数；不支持“AI 从零发现通用剪枝算法、全面超过人类方法”。默认策略依赖人类提出的 CDPruner；32-token 源设置至少保留其中 30 个，只允许最多两次交换。公开最终策略还包含被删 token 的残差信息回灌。

## 面对什么模型、什么问题

目标是**图像理解与问答的生成式 MLLM**，而非纯 ViT 分类、视觉生成、文本-only LLM 或安全 Guard。三个目标主干：LLaVA-1.5-7B（576 个原视觉 token）、LLaVA-NeXT-7B（2,880 个）、Qwen2.5-VL-7B（主表完整设置 1,296 个）。后两者用于跨主干迁移。另一个独立角色是离线算法提案 LLM：主实验 Qwen-Plus，鲁棒性检查另用 Qwen-Max 和 DeepSeek-V4-Flash；不要把设计者与被剪模型混淆。

其问题包含两层：长视觉前缀增加 LLM 的推理计算与 KV 成本；手工评分、配额、选择和重组规则难以随模型、任务和预算持续调优。论文希望把后者自动化，而不是学习主干参数或做硬件神经架构搜索。

预算 $K$ 由外部给定，最终严格输出 $K$ 个视觉 token。自动化的是策略设计，不是每张图自动决定保留数量、自动选择剪枝层或训练一个在线决策 LLM。

## 方法设计

### 1. TPDSL 把搜索限制在可执行的残差策略内

搜索状态为 $\mathcal S_\alpha=(\pi_P,\alpha)$，其中 $\pi_P$ 是已有基准策略，$\alpha=(B,S,C,R)$：

- $B$：预算与预算依赖参数实例化。
- $S$：token 质量评分、相似度核、分数融合。
- $C$：候选池、基准选中项保护、交换配额、多样性约束。
- $R$：顺序恢复、特征重组及可选被删内容聚合。

131 个 instantiated atoms 分成九组，分别为 token 来源/基准 6、预算 10、评分 10、核 2、融合 3、候选池 6、选择约束 9、重组/处理 81、执行检查 4（附录 A，表 8）。其中许多是参数化变体，不等于 131 种独立新算法。DPP/conditional-diversity 结构继承已有多样性选择知识。

Materialize 将结构状态绑定到具体运行算子；SafetyCheck 检查精确预算、索引有效/不重复、数值、shape 与确定性，非法策略排除或回退到基准。这里的 safety 是工程执行合法性，不是内容安全/低漏报保证。

### 2. 离线 proposal–validation–evaluation 闭环

主论文设定：只在 LLaVA-1.5-7B、MME、$K_0=32$ 搜索一次；Qwen-Plus 每轮提五个候选，共十轮。各候选编译、检查、运行评测，结构、失败诊断与得分汇入 history；选最高分合法策略。全程冻结目标 MLLM，迁移其他预算/主干时只重新实例化依赖字段，不重新搜索。

因此 training-free 不等于无需评测数据或免费：存在离线 API 提案、50 个候选的模型评测、操作库设计和历史准备成本。部署不再调用提案 LLM（附录 A、算法 2）。

### 3. 选定策略的在线行为

基准 CDPruner 先选 $K$ 个 token。对全部视觉 token 计算相关性、attention-proxy 显著性、空间中心先验、冗余密度、局部对比度，归一化后以加权乘积融合：

$$
g_i=\prod_m(\bar s_i^{(m)})^{w_m}.
$$

再以质量及多样性构造候选，找基准集中低置信度项 $T_D$ 和池中待加入项 $T_A$：

$$
\widetilde T_v=(T_P\setminus T_D)\cup T_A,\quad
|T_D|=|T_A|\le q_e,\quad
|T_P\setminus T_D|\ge r_{min}.
$$

源设置 $q_e=2,r_{min}=30$。最多修改 2/32 的集合成员，不是替换整个人工算法。重组保持最终基数，并可将丢弃信息注入 retained anchors（正文算法 1，附录表 9）。

## 模型的哪里修改：结构、参数、输入要分开

执行路径可概括为：图像 → 完整视觉塔 → projector → **CDPruner + residual selection / feature refinement** → $K$ 个视觉 embedding → 与文本拼接 → 原 LLM。

修改点是**视觉表示通往 LLM 的输入接口**，不是视觉塔内部逐层删 patch、LLM 内部多层删 token、权重剪枝或 LoRA 训练。视觉编码器、projector、LLM 参数保持冻结；模型前向中需接入选择 mask/indices、特征回灌和 compact/reassembly 逻辑。完整视觉塔仍需运行，其成本不能算作已被剪掉。

实现证据：

- 最终 merge YAML 的 `token_source.layer: post_projector`；wrapper 同时设置 anchor policy 和 `EVO_UNIMERGE_ENABLE=1`。
- 最终 anchor YAML 使用 `native_teacher_mask_prior` 获得原生 CDPruner mask；最终 selector 为 `native_reference_residual_exchange_selector`，`replace_quota: 2`、`min_reference_keep: 30`、`sort_selected: true`。
- 最终 merge YAML 含 `nearest_anchor`（cosine）、`anchor_weighted_residual`、`mean_residual`，尺度均为 0.0005，注入 anchors。因此不能说最终输出只是未改动的原 token 子集，更不能把所有增益归因于“两次替换”。尚未隔离 selection-only 与 merge-only 的最终收益。
- typed executor 将 `instruction_guided_visual_relevance` 和 `attention_proxy_saliency` 分派到 `cdpruner_policy/atoms.py`：前者有兼容文本表示时用 cosine，否则回退到视觉通道统计；后者默认混合 0.7 token norm 与 0.3 空间中心先验，不是一次真实 attention map。实际运行是否触发文本回退尚未验证。
- executor 注释要求宿主 `llava_arch.py` 提供 native mask；本轮没有核验完整宿主前向/所有迁移 adapter，不声称指定的 Python 行号或 Qwen 位置编码处理已被复现。

## 实验数据与指标

作者声称 14 个图像多模态 benchmark；列举 VQAv2、GQA、VizWiz、ScienceQA-IMG、TextVQA、POPE、MME、MMBench-EN/CN、MM-Vet、HallBench、ChartQA、AI2D、OCRBench。完整 LLaVA 表展示十项，Qwen 表展示七项；本轮未见 OCRBench 对应结果表，不能把“列入评测列表”解释为已展示 OCR 保真。

基线包括 FastV、PyramidDrop、SparseVLM、PruMerge+、TRIM、VisionZip、DART、DivPrune、CDPruner。作者说明相同 checkpoint、split、prompt、decode 与预算；Qwen 的 CDPruner 为作者自行复现，而非可直接核验的官方适配（§Experimental Protocol、附录 B–C）。

附录式 (25)–(27)：MME 在 LLaVA 除以 20、Qwen 除以 28 后，与其他任务得分求均值作为 Acc；Rel 定义为剪枝 Acc / 完整 Acc。Acc 不是一个单一任务准确率。

### 主结果（作者表格，不是本地复现）

| 模型 / 预算 | CDPruner Acc | AutoPrune Acc | 作者报告 Rel：CD / Auto |
|---|---:|---:|---|
| LLaVA-1.5-7B / 32 | 60.0 | 63.2 | 94.3 / 99.7% |
| LLaVA-NeXT-7B / 160 | 62.8 | 65.2 | 96.0 / 99.9% |
| Qwen2.5-VL-7B / 256 | 61.65 | 66.42 | 82.4 / 88.3% |
| Qwen2.5-VL-7B / 128 | 55.58 | 60.66 | 74.9 / 81.0% |
| Qwen2.5-VL-7B / 64 | 50.80 | 55.53 | 69.1 / 74.7% |
| Qwen2.5-VL-7B / 32 | 47.82 | 50.37 | 65.5 / 68.5% |

表 1（PDF 第 5 页）、表 3（第 6 页）。作者报告其他预算仍胜过 CDPruner：LLaVA 128/64 token 的 Acc 提升 2.3/2.5；NeXT 640/320 提升 1.7/1.9。16-token 跨预算迁移 Acc 61.2、Rel 96.6（附录 C、表 10–12）。

### 效率：大加速属于压缩对完整模型，不是 AutoPrune 对 CDPruner

单 RTX 3090、NeXT-7B、**320 token** 的表 2（PDF 第 5 页）：

| 指标 | 完整模型 | CDPruner | AutoPrune |
|---|---:|---:|---:|
| FLOPs（T） | 41.7 | 4.2 | 4.2 |
| Prefill（作者表头 ms/token） | 815 | 131 | 128 |
| Decode（ms/token） | 43 | 28 | 28 |
| KV cache（MB） | 1440 | 160 | 160 |
| GPU memory（GB） | 17.2 | 13.8 | 13.8 |
| MME | 1511.8 | 1453.0 | 1457.9 |

9.9× FLOPs、6.4× prefill 的参照均是完整模型；对 CDPruner 仅 131→128（约 2.3%）的 prefill 变化，其他效率项相同。**99% 保持率来自 94.4% 剪除的 32/160-token 质量设置，而 6.4×来自 320-token 设置（剪除约 88.9%）**，不能拼成同一运行点。

没有明确请求 batch、输入/输出长度、warmup/repetition、不确定性、selector 分项以及 prefill 是否包含视觉编码/选择器的完整计时边界；表头 ms/token 也应保留为作者标注，不能直接当作 E2E/TTFT。论文对“没有额外成本”的表达强于目前可核证的计时协议。

## 消融与“胜过人类”的证据强度

32 token、MME（表 4–6）：CDPruner 1373.00；Full TPDSL 1413.46；无 reference anchoring 1223.29、无多信号融合 1391.70、无多样性 1400.80。$q_e=0,1,2,4,8,16,32$ 对应 1373.00、1384.95、1413.46、1394.28、1362.48、1326.35、1217.88。放开大量替换反而明显变差，强人工先验的保护是方法成功关键。

提案 LLM 的 MME 为 Qwen-Max 1411.04、Qwen-Plus 1413.46、DeepSeek-V4-Flash 1414.34，最大差 3.30（表 5）。相同名义 10×5 搜索预算下，OpenEvolve 1407.23、EvoPrompting 1409.21、AutoPrune 1413.46（表 13），优势 6.23/4.25，尚不能证明 LLM 搜索普遍优于同空间 random/Bayesian search 或同预算人工调优。

表 14 四个搜索 seed 每次 50 个合法候选，best 都为 1413.46；Mean/Min/Std 是**一轮搜索中的候选分数统计**，不是 benchmark 测量误差或主方法相对基线增益的置信区间。

表 7 对五种基准策略均能改善 MME，但作者明确它们是在统一 CDPruner-compatible interface 下重实现 selection/merge prior，不等于完整原方法 native system。不可据此重排原系统 SOTA；表 7 的策略分数与主表 1 不可混在一个排行榜。

## 关键审查：平均提升从哪里来

以下是按主表原始单项值和附录的 Acc 规则进行的个人算术复核，非额外模型实验。

LLaVA-1.5、32 token：AutoPrune 对 CDPruner 的实际聚合增量约 3.1733，其中 MMBench-EN 59.60→70.55、CN 49.60→65.90，两项贡献 2.725，即约 **85.9%** 的总增量。剔除两项后，其余八项平均增量约 0.5604。POPE 87.90→87.67 有退步。

NeXT、160 token：实际聚合增量约 2.3855，其中 MMBench-EN 64.2→73.3、CN 53.8→67.9 贡献 2.320，即约 **97.3%**。其他八项平均增量仅 0.0819；GQA 60.8→60.7、ScienceQA 67.5→67.4、MM-Vet 36.2→35.3 退步。640 token 的 MM-Vet 更从 41.9→36.1。

这并不证明 MMBench 增益无效，但说明“平均更好”主要由特定任务驱动，不能表述为全部视觉能力保留。32-token LLaVA 的 AutoPrune 相比完整模型仍有 VQAv2 78.50→73.91、TextVQA 58.20→53.28、MM-Vet 31.30→28.00 的损失；“99%”不是逐任务无损。

Qwen 有更明显的文字任务提升：128 token TextVQA 23.24→41.42、ChartQA 32.68→47.72，但 TextVQA 仍远低于完整模型 84.80；MME 1755.08→1743.74 退步。因此这里支持相对基准改善，不支持极限压缩无损。

## 指标定义与实现材料的未决一致性

### Rel 列与附录公式不一致

从原始表 3 重算：完整 Qwen Acc 约 78.0551，256-token CDPruner 61.6505、AutoPrune 66.4208。按式 (27)，Rel 应约 **78.98% / 85.09%**，而作者表格为 **82.4% / 88.3%**。后两者可由“每任务剪枝/完整分数比值的均值”复现，说明表格与文字定义使用不同聚合顺序。

128-token Qwen 按聚合比值为 71.20% / 77.71%，作者表格为 74.9% / 81.0%，也接近逐任务比值均值。LLaVA CDPruner 的 94.3%接近逐任务均值，AutoPrune 的 99.7%则接近聚合比值；至少部分表格存在口径混用。

两种公式不等价，尤其 HallBench 剪枝分数高于完整模型时影响明显。不能把一者默默更正为另一者；保留作者原数并列重算，待作者澄清。这不会自动推翻 Acc 的排序，但影响“性能保持率”和百分点增益的精确解释。

### 公布的 50-candidate 搜索不是空 history 起步

论文算法 2 以空 history 初始化，但公开 `run_autoprune_search_10x5.sh` 默认读取 `openevolve/v18_llm_nas/fresh5_small5_history.md`。该文件记录此前 fresh0/fresh3 与 1411-level 区域，并明确要求聚焦 $q_e=2,r_{min}=30$ 和窄参数邻域，避免 q0/q1 或更大交换。

因此可以确认 release 的 10×5 运行受既有搜索经验初始化；**不能确认“50 个候选就是从零到最终策略的全部设计成本”**，也不能仅凭名义候选数认定与空 history 搜索公平。此前历史总成本、作者参与程度以及所有 baseline 是否得到相同 history 尚未厘清。

另外代码初始 history/最终 YAML meta 的 clean CDPruner perception 为 1382.8248，论文主表/消融基准为 1373.00。以代码值为基准，1413.46 的改善约 30.64，而论文值为 40.46。该差异可能来自评测或实现配置，但缺乏完整日志不能确定原因；不能直接断言作者错误或不当行为。

## 综合判断、项目关系与候选启发

来源结论：AutoPrune 在作者测得的平均分上优于所列代表性免训练方法，并展示跨预算/主干迁移。个人判断：更准确的定位是**人工领域库和强剪枝器上的 LLM-assisted residual optimization**，不是排除人工先验后的“AI 对人类”竞赛。

优势：搜索状态可解释、精确预算与 fallback 易部署；有限交换降低搜索失败；在线无外部 LLM；把 selection、merge、合法性检查分开组织。

边界：只展示图像理解、三个 7B 主干，未验证 Qwen3-VL 的多深度注入、安全 Guard、视频、尾部漏报或对抗背景。MME 同时用于选择与报告，未明确独立 search/held-out split；其他任务的直接迁移是有用证据，但不能替代该切分。没有公平的人工同预算调优或同空间随机/贝叶斯优化，最终策略的选择/回灌归因也未隔离。

对当前安全判别项目的候选启发：可借用“保护强基线 + 少量政策条件证据替换 + 编译检查”的离线策略搜索框架，但优化器应在独立开发集以固定漏报风险下的时延/预算为目标，并在 held-out 政策、类别和攻击上测泛化。SafetyCheck 不构成安全风险保证；需要独立语义安全评估。当前浅层安全充分视觉前缀还要求减少视觉深度，本方法没有搜索或修改视觉塔深度，不能直接替代主方案。

关联：[[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|通用执行位置与净收益概念]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|StackTok：固定规则的相关性—覆盖门控]]；[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|时延与质量口径审计]]；[[LLM-Wiki/research/visual-token-pruning/overview.md|项目主线]]。本轮仅补充论文证据，不创建单篇方法概念、不修改正式 Motivation、研究缺口或实验结果。

## 2026-09-18：CDPruner 原文及投稿质量复核

### 基线地位与 Qwen 保真度

[[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]] 已核实发表于 NeurIPS 2025 Main Conference；其条件 DPP 同时奖励指令相关性和视觉集合多样性，详见该笔记。AutoPrune 的主路径可准确定位为其上的 LLM-assisted residual policy search，不只是超参数数值搜索，但也不是从零创造选择器。框架可以接其他基准策略；表 7 只是统一接口内重实现，仍不可据此宣称普遍重排原生系统。

新的协议/实现疑问：CDPruner 官方会议稿表 4 的 Qwen2.5-VL-7B / 128-token TextVQA 为 **77.8**、ChartQA **59.2**、AI2D **74.0**；本文表 3 的自行复现 CDPruner 为 **23.24 / 32.68 / 66.26**。两篇的对应完整模型分数均为 84.8 / 86.1 / 80.4。即使本文 AutoPrune 在其管线提高到 41.42 / 47.72 / 66.68，也不能在没有统一协议与原生 adapter 对照下认定超越原论文结果。该差异不证明实现错误或研究不当，但应优先要求澄清图像处理、split/prompt、位置编码、评分表示及 adapter。

### 只读视觉版面检查：观察，不是录用证据

通过 PDF 技能将 17 页原件渲染为临时 PNG，人工视觉抽查第 1、3、5、7、10、11、12、14、17 页；没有编辑、覆盖或重新导出来源 PDF。

- 正文为专业双栏论文风格，标题、公式、流程图和主要表格总体清楚；抽查页未见明显裁切、重叠。模板外观不能用于确认投稿 venue 或录用。
- 第 5 页主表及图 3 较密；第 12 页附录表 9 字号较小，可提高可读性。第 17 页右栏和中部留白较多，是次要浮动体/空间利用问题，不是研究质量否定证据。
- 第 10 页补充材料标题为 `Towards LLM-Driven Autodesign of Visual Token Pruning Algorithms`，与正文标题不同；该页 `Atom Composition and Runtime Semantics` 段落存在字面未解析引用 `(Liu et al. 2026b; ?)`。这是明确的定稿一致性/引用问题，应修复。不能因此推断审稿结果或作者动机。

### 个人评审判断：潜力和当前证据分开

选题有顶会潜力：在强剪枝先验上做可解释、受约束且可部署的自动策略搜索，具有跨预算/主干迁移和不在线调用 LLM 的实用价值。131 原子、多个基线与消融表明其工作量不应被简化为仅写 prompt。

但本轮对当前版本不作高置信度录用预测。主要障碍是**自动化相对同预算传统搜索的增量贡献与实验证据一致性**，不是排版。应补充：同空间、相同 history 和评测预算的 random/Bayesian search 与人工调优；完整搜索日志与总成本；独立 search/held-out 切分；原生 CDPruner adapter 的公平复现；统一 Rel 公式与表格；最终 selection-only/merge-only 归因；重复、selector-inclusive 时延与逐任务/迁移退化分析。上述需要作者解释或新实验，本轮未解决。

主观审稿倾向：若关键疑问未澄清，核心创新可能被视为强人工方法上的受限 AutoML，证据不足以支持宽泛“AI 优于人类”主张；若公平搜索对照、迁移机制及复现材料补强，则可形成有竞争力的自动化算法设计论文。不能仅靠目前版面判断 NeurIPS/ICLR/ICML/CVPR 或顶刊的接受概率；正式发表状态仍仅核实为 arXiv。

## 证据定位与待验证

- 模型角色、问题、TPDSL、离线搜索：Introduction、Method、图 2、式 (1)–(12)，PDF 第 1–3 页。
- 交换、配额与重组：Method、算法 1、式 (13)–(20)，第 3–4 页；附录表 9，第 12 页。
- 基准与主结果、时延、Qwen：表 1–3，第 5–6 页。
- 组件、提案者、交换配额、统一接口策略：表 4–7，第 6–7 页。
- 原子库、编译及检查：附录 A、表 8、算法 2，第 10–12 页。
- 指标：附录 B、式 (25)–(27)，第 12 页；迁移、搜索基线、多 seed：附录 C、表 10–14。
- 代码精确定位：固定 revision 下的 `FINAL_POLICY_MANIFEST.md`、两个 final YAML、`openevolve/run_autoprune_policy.sh`、`cdpruner_policy/{executor,atoms}.py`、`yaml_policy/v9_pipeline/executor.py`、`run_autoprune_search_10x5.sh`、初始 history。
- TODO：Rel 口径、代码/论文 baseline 差异、history 完整成本与公平性、MME held-out split、最终 residual merge 的独立归因、宿主 hook/迁移 adapter、selector-inclusive E2E 计时、OCRBench 未展示结果、安全迁移。未在本轮解决。
