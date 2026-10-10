---
id: c5-per-sample-visual-allocation
type: synthesis
title: "Cx 逐样本视觉预算分配：全局与单局部框的清晰度选择"
tags: [research, visual-token-pruning, multimodal-safety, adaptive-budget, dynamic-inference]
project_id: visual-token-pruning
sources: [paper-liao-2026-resadapt, paper-arxiv-2609-10346, paper-cai-2024-matryoshka-mm, paper-yang-2025-visionthink, webpage-an-2026-adaalloc]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# Cx 逐样本视觉预算分配

## 1. 最新决策与证据

**名称更新：** 自适应预算方法统一称为 Cx；C5 专指原固定 5% 方法。本文的历史设计和对照证据保持原有含义。

**同日方法细化：** 用户进一步提出全局/局部两个重要性指标。当前主候选的 v2 方法定义、双 head 和预算曲线规划见 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|双重要性方法方案]]；该新版不规定数据规模/范围及执行协议，代价仅含 NLL 与标签不一致，每个视图三档。本页配置分类器保留为历史方案和结构对照。

2026-10-10 用户明确：不将 5% 作为核心工作点，先解决逐样本视觉预算划分，暂不考虑 batch 推理。保留文本政策指导、原生图像输入接口和全局＋至多一个局部框；短政策按模板改写，是背景条件。本文取代 [[LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md|此前以 5% 升级门为起点的方案]]作为下一步主设计；旧 5% C5 继续作为实验对照。

推荐顺序：**共享多预算 Guard 支持 → 少量清晰度配置 → 最小充分配置监督的小预算头 → 再做预算与区域联合选择。** 一次预览、一次最终 Guard 是本页推荐的效率设计；用户没有禁止多次 Guard，级联仍可作独立基线。

| 判断 | 依据 | 证据边界 |
|---|---|---|
| 应扩大可选清晰度 | C5 错误分析：全局模糊、错误局部、证据大或狭长 | 场景观察；未证明总预算是唯一瓶颈 |
| NLL router 改动没有明显提升 | [[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md|用户定性报告]] | 没有新指标、缓存或训练曲线，不宣布 router 已最优 |
| 编码前图文 allocator 与 C5 接口相近 | ResAdapt §3.2、Figure 2 | 视频为主；图像迁移存在明显失败 |
| 多预算共享模型可训练 | M3 §3、Tables 1–2 | post-encoder pooling，不直接证明输入降采样同等有效 |
| 预算需要由实际可救回性监督 | VisionThink §3.5；VIP-Router §3 | 迁移到政策 Guard 是本文假设，不是原论文结论 |

本页仅规划，没有执行 GPU 实验或检查 C5 实际代码。已有证据见 [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md|C5 原始分析]]。

## 2. 将总预算和比例改成两个视图的实际 Token 数

动作定义为

$$
a=(K_g,K_l,b),\qquad K_{total}=K_g+K_l.
$$

$K_g$ 是全局图实际视觉 Token 数，$K_l$ 是单局部框的实际 Token 数；$K_l=0$ 表示只看全局，此时不使用 $b$。全局占比 $K_g/K_{total}$ 是选择结果。预算不必围绕固定 5%，比例不必限定 75/25、50/50。

复用原 CNN、政策 Transformer 和 cross-attention，得到全局图文特征 $h_g$ 和区域图文特征 $h_b$。增加配置头，输入共享特征、原图宽高/宽高比、原生参考 Token 数 $N$、候选框几何和候选 $K_g,K_l$。对各候选只运行小 head，最终从原图渲染所选的 global 和 local，再执行一次 Guard。

```text
原图＋完整当前短政策
  → C5 低成本图文预览
  → 单框提议＋预算配置头
  → 选择 (K_global, K_local, box)
  → 原图按合法网格生成全局图＋可选单局部图
  → 共享多预算 Guard → A–J
```

实际网格仍由现有 planner 规划：保持宽高比、满足模型 patch/merge 约束、屏蔽非法动作、合并产生相同输入的配置。Token 总数、像素清晰度、view 数和时延分别记录。改变预算必须改变实际输入图；放大已缩小的模糊图不能补回原图证据。

全局-only 的中/高清配置必须保留：错误局部、较大或狭长目标可能需要整图覆盖。局部 Token 增加只能提高已选框内的细节，不能恢复框外证据。扩大单框尺寸属于后续几何消融，已有建议见 [[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md|单框几何方案]]，仍不需要多框。

## 3. 最直接版本：少量配置＋最小充分配置标签

### 3.1 配置库

第一版建议 4–6 个合法配置：低/中/高全局-only，以及中全局＋低局部、中全局＋中局部或高全局＋低局部。档位从当前图像大小分布和实测静态工作点确定，不宣称最优。

例如 $(64,0),(128,0),(256,0),(64,64),(128,64)$ 可以说明动作含义：第三档总预算 256，第四档总预算 128、全局占比 1/2，第五档总预算 192、全局占比 2/3。**这些仅为示意 Token 数，未核验当前处理器是否合法、原图是否足够清晰或档位是否合适。** 实施时以 planner 的实际输出为准，小原图需去重；避免制造只增加补边或插值的预算。

初期冻结旧区域提议，在每个图像—政策对上生成一个部署时也能得到的 $b(I,P)$，给各混合配置使用同一个框。训练预算头所用的 teacher 必须评测这个框；不能用 gold/oracle 框产生标签却在部署换回旧 router 框。先隔离预算变量，避免将预算收益与区域算法变化混在一起。

### 3.2 标签构造与训练

使用同一个冻结、已支持这些配置的 Guard，对训练样本离线评测所有候选。缓存每项实际输入网格、预测 A–J、合法 gold、gold NLL、Unsafe→Safe 和误报状态、实际 Token/时延。政策变化后的 gold 必须同步变化。

定义通过条件的集合 $\mathcal S_i$：候选分类正确；若需要减少偶然正确，可再用预先在内部验证集确定的 gold margin/质量容差检查稳定性。阈值不是线上已知真标签，也不是安全保证。第一版直接选择

$$
a_i^*=\arg\min_{a\in\mathcal S_i} t_i(a),\qquad
\mathcal L_{alloc}=-\log\pi_\phi(a_i^*\mid I_i,P_i).
$$

如果暂时没有可靠逐动作时延表，可先以实际 $K_g+K_l$ 作成本代理；双图开销可能使最小 Token 配置并非最快，因此必须随后核验 batch=1 E2E。性能接近、成本接近的候选可用多个有效标签，损失写为 $-\log\sum_{a\in\mathcal S_i^{near}}\pi_\phi(a\mid I_i,P_i)$，避免惩罚等价选择；$\mathcal S_i^{near}$ 仅包含接近最小充分成本的动作。

若所有配置都错误，保留该样本和失败标记；不要伪造“最大预算一定正确”的升级标签。这类样本仍可用于 Guard 恢复训练、失败分析，或第二版的真实代价监督。预算头主监督可 mask 掉缺少充分配置的项，但最终测试不得过滤这些样本。报告有充分配置的样本覆盖率，防止 oracle 数据筛选造成乐观结论。

这使 router 学习“当前政策需要哪种观察清晰度”，无需先再扩大四项损失或连续 RL。NLL 可以作稳定性辅助，第一版主标签来自分类可解决性与成本，不只来自 NLL 数值大小。少量配置下离线测所有候选更容易，也更直接对应预算动作。

### 3.3 Guard 条件

旧恢复 Guard 主要适配低预算接口，不能预设它已经支持所有新网格。先检查各档合法输入和分类表现；如适配不足，在同一训练集混合预算及单/双 view 做一个共享 Guard 的 CE 恢复，保持政策翻转和标签顺序变化覆盖。

混合预算训练借鉴 M3 的多尺度支持思路，但不宣称随机采样预算等价于 M3 每个样本各尺度损失平均。保证各档得到训练，不让预算头初期偏好决定训练覆盖。共享 Guard 固定后重新生成最终配置标签；每档独立 Guard 仅可用于明确标注的上界，不能混进主自适应结果。

## 4. 下一版：共同尺度的预算与区域联合评分

小配置头可行后，再使候选包含多个单框位置/形状，共享评分器输入 $(h_g,h_b,P,K_g,K_l,b,N,H,W)$，回归同一 Guard 的安全任务代价

$$
\widehat C_{task}(I,P,a),\qquad
a^*=\arg\min_{a\in\mathcal A_{legal}}
\left[\widehat C_{task}(I,P,a)+\lambda_t\widehat t(I,P,a)\right].
$$

这里 $C_{task}$ 延续已有安全代价定义与经验证权重，保存 NLL、错类、漏报和误报分量；权重尚无实际配置，不能补造。所有候选可直接比较绝对代价，无需锚定某个 5% baseline。若继续用收益，必须选共同 reference，不能把每档各自的 Global100 都归零后跨档比较。

VIP-Router 可借鉴共享特征＋候选预算条件＋离线效用监督；其给定外部比例下选剪枝策略的结果并不等于本页 $(K_g,K_l,b)$ 联合选择效果。第一版可以保留原区域头，第二版再共享候选 head，避免一开始展开所有预算×所有框。

连续的全局/局部分辨率输出是后续选项：预测两路尺度和 local 开关，借鉴 ResAdapt 的图文 allocator。合法网格量化和 resize 不能直接用分类 CE 对预算动作反传；需离线监督、可验证的松弛或 bandit/RL。离散配置已经能自适应，不必先为连续形式增加 RL 训练成本。

## 5. 相关机制及采用次序

| 机制与来源 | 与 Cx 的契合 | 采用边界 |
|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-liao-resadapt.md|ResAdapt]]：低成本图文特征→编码前分辨率 | 原生接口、一次最终主干调用，结构最接近 | 主要为视频；仅借 allocator 思路，第一版不照搬 CAPO/时间正则 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md|VIP-Router]]：离线候选效用→小路由器 | 复用现有图文交互和评分头 | 不是自主总预算模块；需要目标 Guard 的未过滤数据 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2024-cai-m3.md|M3]]：共享多尺度模型与最小正确尺度 oracle | 说明共享多预算适配及标签构造的方向 | 论文没有实现可部署的最小预算预测器；完整视觉编码开销仍在 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-yang-visionthink.md|VisionThink]]：低清先答，必要时再看高清 | 逐样本自适应，容易做升级基线 | 可多次 Guard；OCR 类任务可能更慢，不能当成一次调用 |
| [[LLM-Wiki/research/visual-token-pruning/adaalloc-project-screening.md|AdaAlloc 项目页]]：全局/局部固定预算分配 | 覆盖与细节取舍相近 | 仅项目页筛查；视频、多段证据、固定总预算，不作安全图像性能证据 |

最易实现的独立基线是“低清全局 Guard → 置信度/类别 margin 门 → 更高清全局 Guard”。它不要求先训练新预算头；但缺失证据时模型可能自信地判 Safe，因此门需要用真实高低档救回样本校准，不能把预测熵直接当困难度。计算两次调用的总时延，必要时明确重新执行还是复用缓存。该基线和一次预览 allocator 分开报告。

## 6. 逐样本实验协议

暂不引入 batch 拼接、跨请求预算调度或平均 5% 硬约束。仍需定义可选最大网格/单请求上限及质量—成本取舍；完全不计成本的选择不一定产生压缩收益。batch=1 是本阶段计时设置。

| 阶段 | 变量 | 保持条件与成功依据 |
|---|---|---|
| A | 少量全局和单框清晰度配置 | 同一 Guard、同一单框提议；确认确有互补的正确样本和有用静态工作点 |
| B | 必要的共享多预算 Guard 恢复 | 同数据/政策、各档覆盖；更新后重建 teacher |
| C | 最小充分配置 CE 预算头 | 初期冻结区域头；与每个固定配置、随机配置及 oracle 比较 |
| D | 配置与单框联合代价评分 | 只在 C 有实际价值后扩展；比较收益是否来自新框/更宽预算 |
| E | 连续 allocator 或级联 | 仅解决离散档位/预览可观测性的具体剩余问题 |

训练/内部验证/dev/test 按基础图像隔离，避免同图政策变体泄漏。dev 调质量容差、成本偏好与上限，test 不调阈值。计时含 preview、政策编码、head、渲染、所有 Guard 调用及 Python 开销。保存实际 Token 与 E2E 均值/P50/P95，同时报告 macro、Unsafe recall、benign FPR、政策配对两侧均正确率及类别/政策最差组。

逐样本问题也需要汇总效率来证明效果：报告预算分布和同平均实际 Token/同平均 E2E 的静态对照，不代表本阶段需要实现 batch 或跨样本硬预算分配。若自适应只提高平均计算而质量与相同成本静态配置接近，则尚未证实分配价值。

诊断两种后续方向：oracle 配置有效而学到的预算头接近随机，检查 128×128 预览可观测性，必要时单独试更清晰预览并计入新增成本；所有配置包括高清全局都无明显救回，转回区域覆盖、Guard 能力或标签问题。预算变大不自动解决错误选框。

## 7. 可解释性与贡献边界

第一版解释输出为“当前政策下所选全局/局部清晰度及其训练时充分性标签”，不是条款级因果归因。第二版可显示预算增量的预测安全代价下降、单框位置和实际成本，并用合法同图政策翻转检验这些量是否随政策改变。相同预算也可能是合理政策响应，不强迫每次翻转都换预算。

核心候选问题是：政策是否帮助识别何处、需要多清晰的视觉证据，并在同成本下减少压缩诱发漏报。动态分辨率、图文 allocator、多预算训练和 global/local 分配已有先例，不能直接声称这些形式首次提出。投稿贡献和安全非劣均待实验证据，不因加入预算头自动成立。

关联：[[LLM-Wiki/research/visual-token-pruning/overview.md]]；[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/reading-log.md]]。
