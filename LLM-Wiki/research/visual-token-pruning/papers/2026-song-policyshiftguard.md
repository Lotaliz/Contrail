---
id: note-2026-song-policyshiftguard
type: paper-note
title: "PolicyShiftGuard: Benchmarking and Improving Policy-Adaptive Image Guardrails"
authors: [Mingyang Song, Luxin Xu, Haoyu Sun, Minzhou Pan, Yu Cheng, Bo Li]
year: 2026
venue: arXiv
source_id: paper-song-2026-policyshiftguard
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, safety-guardrail, multimodal-safety, safety-evaluation, vision-language-model]
status: active
created: 2026-09-22
updated: 2026-10-20
---

# PolicyShiftGuard：同图政策翻转与边界配对训练

来源：[arXiv 原文](https://arxiv.org/html/2607.05910)与[官方项目页](https://policyshiftguard.github.io/)。精读正文 §1–7、表 1–6、图 1–5，以及附录 A–G 中政策目录、PSS、实现和质量审计；另核对官方 GitHub、Hugging Face 模型卡、文件列表和数据卡，未下载权重/数据或本地复现。

2026-10-20补核保存44页arXiv v1 PDF原件，SHA256为`e549f6e8a03c8643e2ff8085cd872606360473371f54bb2e8439bdd38d5a4065`，只读渲染第4页图2并核对§3和表6；原件登记在既有来源，不另建重复论文。HTML正文抽取未包含的图中文字需以PDF视觉检查补充。

## 更严格的问题定义

论文将 policy-adaptive image guardrail 定义为：给定同一视觉证据，模型必须依据当前运行时 policy bundle 改变 pass/block 判定，而不是把“危险”视为图像固有属性。

设图像在类别 $c$ 上的原子属性为 $A_c(x)$，类别政策为规则 $f_{c,p}$，则类别决策为：

$$
z_{c,p}(x)=f_{c,p}(A_c(x)).
$$

运行时 bundle 为每个类别选择一条政策；图像只要违反任意激活政策即 block：

$$
y(x,\mathcal{B})=\mathbf{1}\{\exists c:f_{c,p_c}(A_c(x))=1\}.
$$

这把任务分成“图像里有什么”和“当前规则如何处置”两层，并允许固定图像、只改变政策得到严格反事实。

## PolicyShiftBench 如何构造

七个风险类别覆盖裸露/性内容，暴力/仇恨/恐怖主义/自残，受管制物品，IP/品牌，文化宗教敏感，隐私/PII，以及图中文字安全。图1的五类宏观场景是主流社交、儿童/家庭保护、宽松法律底线、商业品牌安全和专门用途；医疗教育、新闻、游戏及地区文化是具体情境。类别与场景的有效交叉形成 28 个评测政策变体，不是七乘五的全部组合。

数据构造不是直接让模型标 safe/unsafe，而是：

1. 为每类定义可观察的原子属性，包括触发条件和医疗、艺术、新闻等豁免；
2. 三个多模态标注器分别输出属性，字段级多数投票；
3. 对投票属性执行显式政策规则，确定类别标签与最终 OR 标签；
4. 优先采样同图、同类别、换政策后标签翻转的实例，同时保留始终安全/危险锚点。

最终评测集 2,000 个实例、265 张图、28 个政策，平均每图 7.55 个政策条件 prompt；262/265 张图同时存在 pass 和 block 标签。Adaptive split 使用训练见过的政策家族，Shift split 使用 12 个 held-out 政策定义。训练语料 9,816 条、2,945 张训练图，包括 3,000 条 RP-SFT、3,000 条 reasoning 诊断数据和 3,816 条 BP-Adapt 边界对。

质量控制中，475,569 个字段决策有 97.5% 三标注器一致；论文另报 Adaptive/Shift 的盲人类准确率 88%/90% 和两个 split 95% qualified rate。高模型一致率不等于人工真值；其内部人审和可执行规则提高了可审计性，但属性遗漏仍会系统性传入所有标签。附录G将盲做题与看gold的质量审查分开，不应称为外部独立审计。

### 2026-10-20 补核：论文是否交代了数据构建

**回答：交代了属性、政策、标签与边界样本的生成逻辑，但不能称为完整披露了原始图像采集与标注运行环境。** 本轮重新核对 arXiv v1 正文§2.1–2.3、附录B/C/D/G/J，以及官方公开 `dataset_stats_sanitized.json` 和 `PolicyShiftBench_croissant.json`；未下载Parquet图像、运行构建器或复现实验。

具体来源定位：

- §2.2与附录B.1说明属性标注→投票→规则执行→七类政策组合→边界采样；附录C列出每类属性定义、政策文本与可执行布尔规则，不只是模糊描述“按不同政策重新标注”。
- 附录D给出属性JSON标注与最终审核prompt骨架；属性标注器判断的是可见事实，不直接给每个政策组合的safe/unsafe真值。未形成多数决的字段标unknown，执行规则时按False处理；表10中当前汇总没有遗留unknown。这一默认值本身并不构成安全保守保证。
- 每个输入bundle为七类各选一条政策，任意一类触发即block。因此，要让目标类的政策改变导致最终标签干净翻转，其他类别必须均放行；这是OR逻辑带来的必要条件，不能只按某一个物体的类别标签生成最终标签。公开统计对clean boundary group进一步明确：block侧仅目标类违规，pass侧无违规类。
- 数据集优先保留同图、同目标类、只换政策就翻转的实例。表7的两个评测split各1000条，全部是policy-discriminative，且各500 block/500 pass；“始终安全/始终危险锚点”在RP-SFT构成中各500条，不能误写为最终2000评测条目中也混入了这些训练锚点。
- Adaptive为130图/16政策，Shift为152图/12留出政策，合计唯一图265张；两评测轨道共享17张图，训练与评测图像不重叠。不能把两个评测轨道说成完全图像不相交。262/265图有两种标签，平均7.55条政策条件prompt/图。

**按真实规则设计的说明例（不是已核验的实际样本）**：一张普通海报只出现网址，不含仇恨、辱骂、诈骗或其他触发项，其他六类政策也均放行。附录C.8的Basic Safety允许普通URL，因此pass；Anti-Spam政策将URL作为阻断条件，因此同图block。此处不需要编辑图片，变化的是审核规则。可见物体/文字是属性，违规与否是政策作用后的结果。

**质量与披露边界**：

1. 8,973张图、475,569字段是上游投票元数据的规模，不是最终评测规模。97.5%指三模型字段一致率，不是整图标签人工准确率。附录G的95% qualified rate来自内部标签合理性审查；88%/90%另指不看gold的人类做题准确率，不能混用，也不能称作外部独立审计。
2. **图2补正**：PDF第4页图2左侧的Image collection明确写有`Web / partner datasets / curated sources`，即网络、合作方数据集和人工整理来源。因此应说“披露了来源大类，但未明确具体网站/数据集清单与各来源数量”，不能说“完全没有交代来源”。在所查正文、附录与Croissant字段中仍未找到三个属性标注器的具体模型、版本与采样设置；图中模型标志也不足以确定运行型号。Croissant的`rai:dataCollection`仍泛称image corpus and policy catalog，`rai:machineAnnotationTools`泛称multiple multimodal model annotators。不能自行补成来源于UnsafeBench，也不能把评测所用的闭源模型当作属性标注器。
3. `rai:hasSyntheticData=true`不能直接解释为“图片全部由生成模型合成”；发布包也含程序构造的政策条件prompt、标签与推理目标，需要图像级来源记录才能判断原始图片的合成比例。
4. [官方数据卡](https://huggingface.co/datasets/PolicyShiftBench/PolicyShiftBench)公开了评测/训练文件、规则目录和manifest，可以使用已发布benchmark；但这不等于能从相同原图来源、相同教师运行设置完整重建。GitHub内容API本次限流，未完成全部curation目录审计，不声称仓库任何位置都不存在补充信息。

对当前项目，最可借鉴的是“独立标视觉事实，再执行明确政策并生成同图翻转对”。属性错误会传播到多个政策标签，三模型一致也不能消除相关错误；后续若扩充数据，需要保留原始图源、属性不确定性和独立人审，而不是直接把教师投票视为人工真值。本轮不更改正式方案或现有训练数据。

## 训练方法

### Stage 1：Randomized Policy SFT

每个样本输入图像和七类政策 bundle，输出短结构化结果 `false` 或 `true | category`。训练随机打乱政策顺序、表面标识和类别槽位，并同步转换目标类别 ID，迫使模型读政策语义而非记忆固定位置。

RP-SFT 提高输出接口可靠性并减少模板捷径，但作者消融显示随机化本身不保证 held-out policy sensitivity；7B 的 Shift PSS 甚至比普通 SFT 低 9.7 点。

### Stage 2：Boundary-Pair Policy Adaptation

核心训练单元固定同一图像和视觉证据，只切换目标类别政策：

$$
q^+=(x,\mathcal{B}^+)\rightarrow\texttt{true}\mid c,
\qquad
q^-=(x,\mathcal{B}^-)\rightarrow\texttt{false}.
$$

总损失由 answer CE、标签分离、类别稳定项和 pair margin 构成。关键 pair loss 强制 blocking policy 的 unsafe score 高于 permitting policy：

$$
\mathcal{L}_{pair}=max\left(0,m-[s_\theta(\texttt{true}\mid q^+)-s_\theta(\texttt{true}\mid q^-)]\right).
$$

因此它不是“再加一些政策数据”，而是直接优化同图政策边界。表 6 中移除 pair loss 后，3B/7B Avg. F1 分别下降 10.6/17.7 点，支持配对结构而非数据量本身是主要因素。

### 2026-10-20 补答：主要技术贡献与创新层级

**个人判断**：算法侧最值得强调的是BP-Adapt的同图政策边界配对目标；论文整体还包括可执行规则基准与PSS。不能把它概括为“只用SFT训练一个更小的审核器”，也不能把常见hinge/margin形式本身说成新发明。

1. **任务和数据层**：将固定图像标签改为图像与运行时政策bundle的关系；视觉属性和政策逻辑分离，使同图翻转的标签可追溯到规则变化，另设留出政策评测。这是组合式任务/基准贡献，并非声称此前没有政策条件Guard。
2. **第一阶段**：RP-SFT随机化政策顺序、表面标识与类别槽位，并同步变换输出类别ID，减少固定位置捷径。它仍是next-token CE微调；表4显示7B域外Shift PSS反降9.7点，不能把随机化本身说成已解决政策泛化。
3. **第二阶段**：普通CE独立要求每条样本的答案正确；BP-Adapt额外将同图同类别的block/pass两侧联合约束，要求前者的unsafe分数比后者至少高margin。label与category项分别约束二元决策和违规类别。仅有分数差并不保证两侧都正确，所以仍需单样本监督。
4. **指标层**：PSS仅在同图同类别的翻转对两侧均正确时计分，并按组宏平均，检测“认得风险物体但不随政策改变”的失败。配对数据、训练目标和指标针对同一失效模式，构成该工作的主要闭环。

表6的7B控制中，移除pair loss为Avg.F1 59.2/Shift PSS45.2，完整方案为76.9/70.4，支持当前训练设置下配对目标有效；不能由单项消融证明任何成对学习都全新，或排除其他充分优化SFT方案。主模型基于Qwen2.5-VL-3B/7B微调，没有新的视觉主干或token剪枝结构；主训练不以PPO/GRPO为核心，think/RL是诊断对照，目录或旧split名`rl`不代表最终BP-Adapt算法是强化学习。

部署侧的短结构化输出是实用设计，时延改进包含生成长度变化，不等于视觉推理计算已被剪枝。当前最直接的迁移启发是保留政策翻转对及both-correct评测，并用full/压缩模型比较边界保持；不能直接将BP-Adapt替代视觉区域选择或证明长政策压缩有效。本轮未改变正式方法计划。

## 评测指标：Policy Shift Score

PSS 先按 `(same image, same target category)` 分组，只保留 gold label 不同的政策对。一对样本只有 pass 侧和 block 侧都预测正确才计分，最后在组间宏平均。这比单样本 accuracy/F1 更严格：一个始终拦截危险图像的模型可以有可观 F1，却无法获得 policy flip 得分。

该指标仍只测二元翻转，不包含 fixed-FPR 校准、违规严重度、政策冲突优先级或压缩后条款遗漏；当前课题需要在 PSS 外增加这些指标。

## 主要证据

- PolicyShiftGuard-7B：作者报告 Adaptive F1/PSS 86.8/73.8，Shift F1/PSS 67.0/70.4，平均 F1/PSS 76.9/72.1。
- SafeGuard-VL-RL-7B：平均 F1 51.0，但 PSS 4.0；GuardReasoner-VL-3B 平均 F1 59.2，PSS 3.2。该差距证明普通风险识别不等于政策敏感。
- 跨 benchmark：PolicyShiftGuard-7B 在 UnSafeBench、SafeEditBench、Adaptive、Shift 的 F1 分别为 64.1、61.7、86.8、67.0。
- concise no-think 训练在 3B/7B 两阶段均优于 reasoning 版本；输出通常不超过五个 token，作者报告同 7B 基座时延从 273.3 ms 降至 163.9 ms。计时改善混合了训练和输出长度变化，不能归因为 token pruning。

以上均为作者报告，未本地复现。

## 局限与证据边界

作者明确限制为静态图像、显式英文政策和结构化 moderation policy style；不覆盖视频、多轮、网页、跨语言、法律文档式或长用户自定义政策。政策目录虽含 held-out split，仍来自同一属性/规则 schema 和有限 28 个变体。

属性—规则分离使标签可审计，也可能产生 closed-world 偏差：模型只需覆盖预定义属性和政策模板；现实中未建模的属性、模糊规则和跨条款冲突不在任务内。多数属性由 VLM 投票获得，可能有相关错误。PSS 不评估概率校准或部署安全代价。

## 公开模型、代码和数据

官方公开了四个直接可加载的检查点：最终 [PolicyShiftGuard-3B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-3B) 与 [PolicyShiftGuard-7B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-7B)，以及各自的 RP-SFT 中间检查点。3B 名称对应 Qwen2.5-VL-3B-Instruct 基座，但 Hugging Face 对完整多模态模型计为约 4B 参数，BF16 仓库约 7.53 GB；7B 版本计为约 8B。对当前压缩课题，3B 最适合作为首个开发基座，7B 更适合作为 teacher/尺度验证。

[PolicyShiftBench 公共包](https://huggingface.co/datasets/PolicyShiftGuard/PolicyShiftBench)包含 RP-SFT、reasoning SFT、BP-Adapt boundary pairs、Adaptive/Shift 评测、boundary group 元数据、可执行政策规则和政策释义，足以避免重新采集或人工标注主数据。许可标签为 `other`，数据卡限制为非商业研究、评审和复现，使用及再发布前必须遵循 `LICENSE` 与 `TERMS.md`。

[官方代码](https://github.com/ssmisya/PolicyShiftGuard)公开了评测、生成式 SFT、冻结 VLM 分类器基线、RL 数据准备/reward、数据整理和验证工具，复现指南直接示范 Qwen2.5-VL-3B。方法监督在概念上可迁移到其他能接收图像与政策并输出结构化 verdict 的 VLM，但官方结果和训练路径没有证明跨架构零修改复用；更换架构至少需要适配 processor、视觉 token 接口、prompt/parser 并重新微调。

## 对当前课题的启发

这篇更适合作为主任务定义：压缩 Guard 必须保持同图 policy flip，而不仅是平均 F1。其可执行条款和属性 schema 可作为 policy compiler 的教师信号；BP-Adapt 可直接改造成“full policy vs compressed policy”边界保持损失。但论文明确不覆盖长用户政策，因此不能用其结果证明长政策压缩已经解决。

关联：[[LLM-Wiki/research/visual-token-pruning/papers/2026-piao-safeguard-vl.md|SafeGuard-VL]]；[[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|两篇比较]]；[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]。
