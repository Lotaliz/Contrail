---
id: 20260908-bidirectional-token-intervention
type: experiment
title: "多模态安全判别的双向视觉 Token 因果干预审计"
tags: [experiment, visual-token-pruning, vision-language-model, multimodal-safety, safety-evaluation, representation-probing]
status: draft
created: 2026-09-08
updated: 2026-09-08
---

# 多模态安全判别的双向视觉 Token 因果干预审计

## 目的与假设

### 研究问题

在已有 1,000 样本 XGuard 实验中，视觉 Token 压缩既会把完整模型的正确预测变成错误（`C→W`），也会把完整模型的错误预测变成正确（`W→C`）。后者多见于内容较简单的样本，候选解释是完整模型受到无关细节干扰，剪枝形成了证据净化；但硬删除 Token 同时改变内容、注意力归一化、位置和序列形状，因此不能仅由输出翻转或 attention heatmap 得出该结论。

本实验不以刷新平均 accuracy 为目的，而是回答：

1. `W→C` 中有多少是真正的干扰证据删除，而不是位置/归一化副作用或随机边界抖动？
2. `C→W` 是否主要来自实体/OCR 丢失、空间关系断裂，还是政策绑定与生成状态退化？
3. 两类翻转能否由一组带符号、带结构角色的 Token 因果量解释？
4. 若机制成立，应该研发新的 selector、merge/reweight 机制，还是只做低成本回退？

### 预注册假设

- **H1：干扰删除。** `W→C` 样本包含对错误类别有稳定正贡献的背景、共现捷径或竞争证据；删除对应图像区域和删除 Token 都会提升 gold policy margin，重新插回该组会使预测回退。
- **H2：证据拓扑。** `C→W` 比 `W→C` 更依赖小目标、OCR、多实体关系或分散证据；被删组对 gold policy margin 有正贡献，回插少量 evidence/relation groups 可以恢复。
- **H3：计算重标定。** 一部分翻转只在序列被物理压缩时出现，等价的像素级语义删除不能复现，说明主因是 attention denominator、position ID 或残差混合改变。
- **H4：边界抖动。** 低 margin 样本的所谓纠错对 prompt 同义改写、轻微几何变换和随机同预算 mask 不稳定，不应当作证据净化。
- **H5：政策绑定断裂。** 某些 `C→W` 样本在剪枝后仍可由中间表示解码实体/OCR，但 policy class probe 和 verdict margin 在后层分叉；这类样本属于 perception-preserved policy-binding failure。
- **H6：标签中介合理化。** 在 `label→rationale` 协议中，换用反事实标签会显著重写政策理由，甚至污染视觉事实，而固定标签后的 full/pruned 差异更小；因此自然语言归因主要是 decision-conditioned justification，而非首标签的生成原因。

H1—H6 是待验证假设，不是当前实验结论。

## 数据与版本

### 固定数据

- 使用 [[LLM-Wiki/experiments/20260907-xguard-token-pruning-analysis/README.md|2026-09-07 XGuard 实验]]的同一 1,000 样本 manifest、标签映射、输入图像、用户文本、系统政策、prompt 模板和 Qwen3-VL-2B-Instruct checkpoint。
- 完整模型 L28 的已复核 accuracy 为 `0.616`，因此 full-correct 与 full-wrong 基数分别约为 616 与 384；正式运行前从逐样本记录重新计算，不从汇总数字反推样本集合。
- 原始输出保持不可变。本实验的 masks、人工标注、干预输出和中间激活写入本实验目录的新文件。

### 四个结果队列

对每个 `方法 × 预算 × 样本`，用相同 gold label 定义：

| 队列 | 完整模型 | 剪枝模型 | 解释角色 |
|---|---|---|---|
| `C→C` | 正确 | 正确 | 稳定对照 |
| `C→W` | 正确 | 错误 | 压缩致错 |
| `W→C` | 错误 | 正确 | 压缩纠错 |
| `W→W` | 错误 | 错误 | 固有困难对照 |

数量比必须与条件率分开报告。定义：

$$
\mathrm{BFR}=P(\text{pruned correct}\mid\text{full wrong})=\frac{N_{W\to C}}{N_{W\to C}+N_{W\to W}},
$$

$$
\mathrm{HFR}=P(\text{pruned wrong}\mid\text{full correct})=\frac{N_{C\to W}}{N_{C\to W}+N_{C\to C}}.
$$

若仅知道 $N_{C\to W}:N_{W\to C}=2.5:1$，在 616/384 的基数下，`HFR/BFR` 约为 $2.5\times384/616=1.56$，不是 2.5。正式报告同时给出 raw counts、BFR、HFR 和净 accuracy 改变量。

### 主分析集与人工审计集

1. 主分析使用所有 1,000 样本，不丢弃不支持的风险类别，但按类别 support 标注置信区间。
2. 人工审计集纳入全部 `W→C`；从 `C→W`、`C→C`、`W→W` 各匹配同等数量，若资源允许使用 2:1 对照。
3. 匹配变量至少包含 gold 类别、图像视觉 Token 数、原图尺寸、OCR 有无、目标相对面积、实体数、full-model gold margin 和用户文本长度。
4. 若 `W→C` 少于 50 条，全部人工标注；若多于 100 条，按风险类别和 margin 分层抽取 100 条，并保留全量自动干预。

### 人工标注字段

两名标注者独立标注，分歧仲裁：

- 风险证据实体、属性、动作、OCR span 及其图像区域；
- 构成政策类别所需的实体—关系—上下文边；
- 可能诱导错误类别的 distractor region；
- 视觉复杂度、目标面积、遮挡、位置、背景拥挤度；
- 判断属于感知、关系、政策映射、输出格式或不可判定中的哪一类。

对 distractor 的标注仅作为候选，不当作因果真值；因果角色必须由干预验证。

## 环境与配置

### 固定模型配置

- 模型：与 2026-09-07 实验完全相同的 Qwen3-VL-2B-Instruct checkpoint；记录 revision/hash。
- 推理：主结果使用确定性 decode、固定 label space、固定最大输出长度和固定 chat template。
- 主剪枝层：L28，不在本实验混入 R15 Ghosted 或结构剪枝。
- 主预算：保留率/剪枝率的定义沿用原实验；选择中等预算 p50 作为机制主分析，高压预算 p75 作为 stress test。
- 方法：FastV 与 DivPrune 使用相同目标 Token 数；Resize、random、uniform-grid 作为机制与简单基线。
- 计时不是本实验首要终点，但仍记录 preprocess、vision、selector、compact、prefill、verdict 和 rationale，防止机制方案脱离部署约束。

### 稳定性配置

- canonical prompt 为主结果；另用两条语义等价、label 顺序不变的 prompt 改写。
- 对图像做不改变标签的轻微平移、2%—4% crop/resize 和轻度 JPEG 变化；所有区域 mask 使用归一化坐标同步变换。
- 对确定性路径重复 3 次检查 kernel 非确定性；若输出完全一致，后续不再把重复运行当作独立样本。

## 方法

### 1. 第一阶段：复核双向翻转与稳定性

对 FastV/DivPrune 的 p50 与 p75 建立逐样本四队列，并计算：

- BFR、HFR、净 accuracy、macro/worst-policy recall 变化；
- 两方法和两预算间 `W→C`/`C→W` 的 Jaccard overlap；
- prompt/图像轻微变换后的 flip retention；
- full 与 pruned 的 gold margin、预测 entropy 与校准误差。

把纠错定义为“稳定纠错”前，至少要求 canonical 纠错在 2/3 prompt 改写和 2/3 轻微图像变换中保持；阈值同时做敏感性分析，不把这一经验阈值包装为普适标准。

### 2. 第二阶段：同一 Mask 的因果干预矩阵

对原方法得到的保留集 $K$ 和删除集 $D$，执行以下条件。所有可比条件保持相同 prompt、decode 和输出评测。

| ID | 条件 | 主要隔离因素 |
|---|---|---|
| `F` | 完整图像、完整 Token | 基线 |
| `P-hard` | 原方法物理删除 $D$ | 已观察翻转 |
| `P-pos` | 仅保留 $K$，但保存原始 position IDs | 物理压缩与重编号差异 |
| `P-null` | 保持原序列长度和位置，将 $D$ 替换为层均值/零向量两种 neutral control | 内容删除但不改变 shape |
| `I-drop` | 在像素空间灰化、模糊、inpaint $D$ 对应区域，重新走完整视觉塔 | 语义内容删除；三种遮挡避免单一 artifact |
| `D-only` | 仅显示 $D$ 对应区域，其余区域遮挡，仍走完整 Token | 删除集自身的类别证据 |
| `R-random` | 随机删除相同数量 Token，重复 20 masks | 偶然翻转与预算效应 |
| `R-grid` | 均匀网格保留相同数量 Token | 空间覆盖基线 |
| `R-swap` | 使用匹配样本的 mask，按归一化坐标映射 | selector—内容对齐 |
| `M-residual` | 保留 $K$ 并把 $D$ 合并为 1/4/8 个带 provenance 的 residual tokens | 原始细节竞争与摘要信息差异 |

`P-null` 不被假定为完美的“无信息”输入；零向量与层均值可能成为新的 out-of-distribution token，因此两者均做，并以 `I-drop`、`P-pos` 和随机对照交叉验证。

### 3. 第三阶段：分组回插与最小因果集合

不做昂贵且非加性的全量单 Token leave-one-out。先把视觉 Token 聚成有语义与空间连续性的 groups：

1. 人工/检测器对象框；
2. OCR 行与单词框；
3. 2×2 或 3×3 相邻 patch block；
4. policy evidence 的关系两端及其空间桥；
5. 其余区域用 superpixel/embedding cluster 补齐。

对 `W→C` 从 `P-hard` 开始逐组回插 $D$，寻找使正确预测重新变错的最小集合 $D^{-}$；对 `C→W` 逐组回插，寻找恢复正确预测的最小集合 $D^{+}$。组 $g$ 的 gold margin 因果效应定义为：

$$
\Delta_g=m_{\mathrm{gold}}(K\cup g)-m_{\mathrm{gold}}(K),
$$

其中 $m_{\mathrm{gold}}$ 为 gold 类别相对当前最强竞争类别的序列 log-prob margin。$Delta_g>0$ 表示该组支持 gold，$Delta_g<0$ 表示其在当前上下文中抑制 gold；不把该分数外推为输入无关的固定 Token 属性。

为处理组间交互，在最有代表性的 30—50 个样本上对前 6 个候选 groups 计算二阶交互：

$$
I(g_i,g_j)=\Delta_{g_i\cup g_j}-\Delta_{g_i}-\Delta_{g_j}.
$$

高正交互用于识别 relation bridge，高负交互用于识别相互竞争或重复证据。

### 4. 第四阶段：跨层表征与决策断点

attention 只作描述，不单独支撑因果结论。记录每层以下信号：

- gold/competitor policy logit lens margin；
- verdict 前最后一个文本 Token、policy Token 和保留视觉 Token 的 residual states；
- 对人工证据区、distractor 区和背景区的 attention mass 与 entropy；
- `gradient × activation` 对 verdict margin 的局部敏感度；
- full/pruned 在相同原始位置 Token 上的 representation similarity。

训练冻结模型上的轻量 linear probes，训练/验证按样本划分，不让同图增强泄漏：

- perception probe：实体、属性、OCR 是否存在；
- relation probe：关键实体—动作/位置关系是否成立；
- policy probe：风险类别及 unsafe margin。

若 perception probe 保持而 relation/policy probe 在后层显著下降，支持 H5。进一步进行 activation patching：

1. 将 full 路径中 verdict 前文本状态逐层移植到 pruned 路径；
2. 对仍保留且位置可对齐的 evidence Token 移植 full hidden states；
3. 用随机层、随机 Token 和同范数噪声做负对照。

记录最早能恢复 gold margin 的层。patching 可能破坏计算一致性，因此只把跨多个相邻层、超过负对照且能复现实验的效果解释为候选中介机制。

### 5. 第五阶段：标签中介与事后合理化审计

当前协议满足：

$$
P(y,r\mid x,z)=P(y\mid x,z)P(r\mid x,z,y),
$$

因此后续 rationale $r$ 不能直接用来证明它导致了先前标签 $y$。对 `C→W`、`W→C` 和匹配的 `C→C` 子集，交叉干预视觉条件与标签前缀：

| 因子 | 水平 |
|---|---|
| 视觉状态 $z$ | full、原剪枝、像素空间删除、blank/irrelevant-image 负对照 |
| 强制标签 $y$ | gold、full prediction、pruned prediction、语义邻近错误类别 |
| 输出协议 | label-first、evidence-first、短 policy-reasoning-first、双通道 extractor→classifier |

同一条件下用固定结构生成：`视觉事实 → 实体关系 → 政策条款映射 → 结论理由`。若 gold/full/pruned labels 重合，只保留唯一条件；错误类别从同一政策上位组或模型第二高概率类别选择，避免用明显荒谬的标签夸大效应。

分别评价：

1. **perception span：** 实体、属性、OCR、数量及区域 grounding；
2. **relation span：** 实体—动作—对象—上下文关系；
3. **policy span：** 视觉关系到政策类别的映射；
4. **template span：** 与证据无关的通用解释语言。

将类别名、标签符号和政策标题从 rationale 中遮蔽后，再计算事实正确性、政策支持度和 rationale informativeness，避免显式 label leakage 让评价器轻易还原标签。整体自然语言流畅度不作为 faithfulness 主指标。

对每个 span $s$ 定义标签干预与视觉干预造成的分布/评分距离：

$$
D_y^{(s)}=D\big(R_s(z,y_{\mathrm{gold}}),R_s(z,y_{\mathrm{cf}})\big),
$$

$$
D_z^{(s)}=D\big(R_s(z_{\mathrm{full}},y),R_s(z_{\mathrm{pruned}},y)\big),
$$

并报告标签支配指数：

$$
\mathrm{LDI}_s=\frac{D_y^{(s)}}{D_y^{(s)}+D_z^{(s)}+\epsilon}.
$$

$D$ 优先使用 teacher-forced token-distribution 的对称 KL、人工事实/政策 rubric 变化和 embedding distance 三种实现做一致性检查，不以单个文本相似度指标定论。

解释模式的判定：

- perception span 基本随图像变化、policy span 主要随标签变化：**视觉事实保持但标签驱动政策合理化**；
- 换标签同时改写实体/OCR：**标签反馈污染感知报告**；
- 固定标签后 full/pruned 仍显著改变 relation/policy span：**压缩具有独立内容效应**；
- blank image 下仍生成具体视觉事实：**语言先验或模板幻觉**；
- 强制 gold label 后文本恢复但 verdict 前 probe 仍错误：**生成级联被修复，不代表决策机制恢复**。

### 6. 第六阶段：输出顺序与低成本延迟承诺

在同一 Token 集和相同 decode 预算下比较：

1. `label-first`：当前基线；
2. `evidence-first→label`：先输出结构化实体/OCR/关系；
3. `8/16/32-token policy scratchpad→label`：只增加很短的政策绑定步骤；
4. `evidence extractor→独立 classifier`：分类器只能读取抽取证据，作为 faithful-by-construction 上界；
5. `label-first→independent verifier`：保持低 time-to-verdict，但对低 margin/高风险样本复核。

分别记录首标签 accuracy、unsafe recall、macro/worst-policy recall、翻转矩阵、time-to-verdict 和完整 rationale 时延。若 8—32 个前置 Token 即能恢复多数 perception-preserved `C→W`，问题更接近过早承诺，而不是视觉信息不可恢复；若只有双通道 evidence bottleneck 有效，则后续应改变模型协议，而不是继续优化 post-hoc rationale；若所有顺序均不能恢复，则返回 Token 内容和关系保存问题。

## 原始结果

尚未执行。不得把 2026-09-07 汇总表中的探索性观察复制为本实验结果。

运行后至少保存：

```text
20260908-bidirectional-token-intervention/
├─ README.md
├─ data/
│  ├─ cohort-manifest.jsonl
│  ├─ human-evidence-annotations.jsonl
│  └─ intervention-manifest.jsonl
├─ outputs/
│  ├─ predictions/
│  ├─ masks/
│  ├─ activations/
│  ├─ probes/
│  └─ figures/
└─ scripts/
```

每条输出需保存 `sample_id`、model revision、method、budget、mask hash、position-ID 处理、干预类型、prompt variant、image transform、gold/pred label、各类 log-prob、verdict latency 和错误状态。

## 指标与分析

### 主要终点

1. BFR 与 HFR，按方法、预算和政策类别报告 95% bootstrap CI；
2. 稳定 `W→C` 中被判为 semantic distractor removal 的比例；
3. 稳定 `C→W` 中由 evidence/relationship reinsertion 恢复的比例；
4. 各干预相对 `R-random` 的 gold margin 因果选择性；
5. perception、relation、policy probes 的首次显著分叉层。
6. perception/relation/policy spans 的标签支配指数，以及反事实标签造成的事实幻觉率。

### 次要终点

- minimal sufficient token/group count；
- minimal harmful distractor count；
- mask stability、空间 evidence coverage 与 relation-edge coverage；
- explanation span NLL 与 factual evidence precision/recall；
- `M-residual` 能否保留 `W→C` 的纠错同时减少 `C→W`；
- selector/intervention 的端到端时延，仅用于判断后续算法可部署性。

### 统计方法

- full 与 pruned 的 paired label 变化使用 McNemar 检验；
- margin 和 causal effect 使用按风险类别分层的 paired bootstrap；
- 多组/多层检验用 Benjamini—Hochberg 控制 FDR；
- 以 mixed-effects logistic regression 分析 flip，固定效应包括目标面积、OCR、实体数、full margin、方法和预算，风险类别与样本作为随机效应；
- 报告效应量和区间，不只报告显著性；稀有类别不作无支撑的机制外推。

### 机制判定规则

| 观察 | 主要判定 | 后续方向 |
|---|---|---|
| `P-hard` 与 `I-drop` 均稳定纠错，回插 $D^{-}$ 使结果变错，且超过随机对照 | 语义 distractor removal | 学习带符号的 policy-conditioned distractor selector |
| 只有 `P-hard`/特定 position 处理纠错 | attention/position/shape 重标定 | 研究位置保持、attention rescaling 或规则 merge，不训练语义 selector |
| 随机同预算也经常纠错，且变换后不稳定 | 低 margin 边界抖动 | 做校准/ensemble/fallback，不把纠错包装为解释性贡献 |
| `C→W` 经 $D^{+}$ 回插恢复，证据/关系覆盖显著下降 | 正证据或关系桥被删 | evidence + relation slots 与 residual merge |
| 实体 probe 稳定，policy probe/decision state 后层分叉 | 政策绑定断裂 | policy-conditioned decision-state preservation |
| `M-residual` 同时保留纠错并修复致错 | 原始细节竞争而非信息总量不足 | 剪枝—融合联合方法优先于纯 Top-K |
| perception 随图像、policy rationale 随强制标签变化 | 标签先行的事后合理化 | 将现有归因降格为 justification；研究 evidence-first 或独立 verifier |
| 8—32 个前置 evidence/relation Token 显著修复 pruned verdict | 低成本延迟承诺有效 | 优先研究 compressed-vision deliberation，而非更复杂 selector |

## 结论

尚未执行。预注册后的首个论文级结论必须在以下三者中择一，而不能事后混合：

1. **证据净化成立：** 剪枝的本质是删除对错误政策有稳定因果贡献的 distractors；
2. **计算重标定为主：** 翻转主要由位置、归一化或残差流改变；
3. **表面纠错：** 纠错不稳定且随机控制可复现，不构成新算法依据。

## 异常、限制与后续工作

- 完整模型的预测不是事实真值，`W→C` 只表示相对人工 gold 的纠错；必须复核标签和多标签兼容性。
- hard deletion、null embedding 和像素遮挡均有各自的分布外效应，任何单一干预都不能独立证明因果。
- 单 Token 效应具有强交互，优先解释语义/空间 groups，不把逐 Token heatmap 当作忠实 rationale。
- 1,000 样本和长尾类别不足以声明普适机制；应在第二个安全数据集和至少一个更大 VLM 上做外部验证。
- 若稳定 semantic `W→C` 数量不足，停止“去干扰剪枝”方法线；优先做 harmful-flip 预测与回退。
- 若机制得到支持，下一阶段方法将 Token 分为 `policy evidence`、`relation bridge`、`distractor`、`redundant`，离线用本实验干预生成监督，在线输出固定 shape 的动态 indices；系统 serving 仍作为后续验证，不与机制首篇论文同时扩张。

## 关联实体与来源

- [[LLM-Wiki/research/visual-token-pruning/multimodal-safety-token-pruning-research-plan.md|多模态安全判别 Token 剪枝研究方案]]
- [[LLM-Wiki/experiments/20260907-xguard-token-pruning-analysis/README.md|XGuard Token 剪枝实验复核]]
- [DART / duplication-aware reduction](https://aclanthology.org/2025.emnlp-main.505/)
- [CrisPrune](https://aclanthology.org/2026.findings-acl.663/)
- [What Do Visual Tokens Really Encode?](https://openaccess.thecvf.com/content/CVPR2026/html/Fan_What_Do_Visual_Tokens_Really_Encode_Uncovering_Sparsity_and_Redundancy_CVPR_2026_paper.html)
- [When Token Pruning is Worse than Random](https://openaccess.thecvf.com/content/CVPR2026/html/Wang_When_Token_Pruning_is_Worse_than_Random_Understanding_Visual_Token_CVPR_2026_paper.html)
- [VASparse](https://openaccess.thecvf.com/content/CVPR2025/html/Zhuang_VASparse_Towards_Efficient_Visual_Hallucination_Mitigation_via_Visual-Aware_Token_Sparsification_CVPR_2025_paper.html)
- [VisPruner](https://openaccess.thecvf.com/content/ICCV2025/papers/Zhang_Beyond_Text-Visual_Attention_Exploiting_Visual_Cues_for_Effective_Token_Pruning_ICCV_2025_paper.pdf)
- [FRESH](https://aclanthology.org/2020.acl-main.409/)
- [ERASER](https://aclanthology.org/2020.acl-main.408/)
- [Goodhart's Law Applies to NLP's Explanation Benchmarks](https://aclanthology.org/2024.findings-eacl.88/)
- [Language Models Don't Always Say What They Think](https://proceedings.neurips.cc/paper_files/paper/2023/hash/ed3fea9033a80fea1376299fa7863f4a-Abstract.html)
- [Measuring Association Between Labels and Free-Text Rationales](https://aclanthology.org/2021.emnlp-main.804/)
- [RORA](https://aclanthology.org/2024.acl-long.60/)
