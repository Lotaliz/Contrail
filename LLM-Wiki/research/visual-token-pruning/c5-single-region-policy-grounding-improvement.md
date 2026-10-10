---
id: c5-single-region-policy-grounding-improvement
type: synthesis
title: "C5 后续方案：单局部框下的条款级证据路由与反事实验证"
tags: [research, visual-token-pruning, multimodal-safety, adaptive-routing, visual-evidence]
project_id: visual-token-pruning
sources: [paper-chen-2025-safewatch, paper-gao-2026-quietprune, paper-arxiv-2609-10346, paper-arxiv-2609-22910, paper-huang-2026-evidence-rl, paper-guo-2025-crop, paper-song-2026-policyshiftguard, paper-zhu-2026-gapsight, paper-ramachandram-2026-pf-cbm]
status: active
created: 2026-10-08
updated: 2026-10-10
---

# C5 后续方案

## 1. 建议与边界

**2026-10-10 当前主设计：** 不锚定 5%，先做逐样本的全局/单局部框实际 Token 配置选择，见 [[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md|逐样本分配方案]]。下述 5% 和二选一预算门是历史实验条件及 pilot；本页的几何、政策监督和证据解释设计仍可用于新动作空间。

**2026-10-09 后续观察与优先级：** 用户报告 NLL 路线收益 router 几乎不选 50/50、指标与原方法接近，尚缺具体数值及配对输出。下一步优先验证自适应总预算的高清救回空间；最小方案是当前 5% 路线与 20% 全局的单次执行升级门，详见 [[LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md|自适应总预算方案]]与 [[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md|本次观察]]。本页保留固定预算下的损失、条款干预与单框几何设计，不把新观察写成 router 已无改善空间。

以 C5 的 **全局＋至多一个局部框、5% 逐样本预算及恢复 Guard**为基础，原 33 路线保留为对照。用户后续指出 C5 错/B0 对的样本中有全局模糊、选错局部及大尺度/狭长证据无法被 1/16 网格覆盖的情况；因此先检查并补充单框几何，再改同图异策的收益监督、匹配布局的像素监督与显式条款级评分。全局保留门和预览分辨率作为独立变量。全部新增设计为研究假设，不预设有效。

用户明确不继续多框路线。此次不增加框数、在线 Guard 调用或自动生成长理由。短政策模板继续作为背景条件。当前 C5 已经是输入分辨率/视图预算路由系统，包含 Guard 恢复训练；论文应把它准确描述为政策条件的视觉预算分配，不把系统全部收益归为原 ViT 内部 Token 选择。

原始结果、数据、训练和环境边界见 [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md|C5 实验分析]]；所有内部链接均指向本 Wiki 已有或本次实际创建的文件。报告中列出的仓库外实现与输出不作为已检查证据。

## 2. 当前结果允许作出的判断

| 观察 | 能支持什么 | 还缺什么 |
|---|---|---|
| C5 对配对 Global100-cap 宏召回 +5.69 pp，Unsafe recall +2.03 pp | 单框动态细节分配在低预算下有用 | 逐图救回/新增错误、政策组效果和统计区间 |
| C5 对 V5 宏召回 +1.67 pp，Unsafe recall +1.47 pp | 文本分支值得继续研究 | 固定同一 Guard 的匹配训练消融；当前差值不能独立证明政策语义作用 |
| 相同 C5 路线，恢复 Guard 比原 B0 宏召回高 14.91 pp | 输入适配是系统的重要组成 | router、Guard 和渲染各自贡献的受控分解 |
| C5 比 B0 宏召回低 15.90 pp、Unsafe recall 低 12.58 pp | 极低预算仍有质量困难 | 不能主张基本保持完整视觉的安全质量 |
| 同图禁/允两种政策选择同一路线而最终 verdict 正确翻转 | Guard 使用了政策；同一视觉事实可能服务两种判定 | 不足以判定 router 是否使用政策 |

报告还显示 C5 的 NLL 略高于配对全局路线；不宜仅通过进一步拟合平均 NLL 衡量改进。需要固定 FPR 的 Unsafe recall、PER/配对两侧均正确率、类别宏召回与路线 regret。

宏召回改进也可能主要来自 Unsafe 类之间的细分类，而不是 Safe/Unsafe 边界；必须分别统计这两种救回。汇总表不能判断哪一项占主导。已公开 test 实例说明局部证据与上下文的矛盾，后续调参使用 train 内部独立划分和 dev，避免逐条拟合这些 test 图。

## 3. 论文机制依据与最近邻

| 机制 | 相关工作 | 对 C5 的建议与限制 |
|---|---|---|
| 每条政策关联视觉证据 | SafeWatch PAP | 可拆条款评分；仅做 policy cross-attention 已有直接先例 |
| 文本指导早期视觉选择 | QuietPrune、CROP | 文本相关或区域可视化本身不足以支撑解释性新意 |
| 按真实效果训练路由 | VIP-Router、GapSight | 用收益/regret 而非仅 best-route 分类；全局＋单框＋收益 teacher 已有近邻 |
| 区分分支价值与像素价值 | CounterCredit | 匹配布局替换局部像素，检查 route 收益是否依赖选中内容；只迁移离线监督，不必用 GRPO |
| 训练期证据干预 | Evidence-RL | 干预可在训练期提供约束，不增加在线审核次数；其普通推理效果不等于 Guard 安全效果 |
| 命名概念实际进入决策 | PF-CBM | 让条款中间量实际参与 route score，且检查语义错配/捷径；不照搬前景/部位空间先验 |
| 同图政策边界学习 | PolicyShiftGuard | 学同图异策的判定或效用变化，不能强迫所有禁/允翻转都换框 |

上述为有限定向检索与 Wiki 复用；不是全部相关工作的穷尽综述。GapSight/PF-CBM 仅快读，未确认正式会议录用或复现。Wiki 的 CounterCredit/VIP-Router 等使用已核对笔记，未在 C5 上执行迁移。

## 4. 第一项优化：在 router 中学习政策改变的路线收益

### 4.0 先区分 Guard 恢复训练和 router 训练

用户已确认当前 C5 的 **Guard 恢复训练包含全部政策翻转样本，损失只有分类 CE**。因此不把“再加入翻转样本”作为新的改进；本节建议作用于 router 的选路监督，不是把收益裸加到 Guard 的 CE 上。

| 阶段 | 训练对象 | 目标 |
|---|---|---|
| 已完成的恢复训练 | Guard 参数 $\theta$ | 根据当前低预算视图和政策预测 gold，当前为 CE |
| 路线 teacher 生成 | 冻结恢复 Guard | 计算各政策、候选路线的任务代价与相对收益；不反传 |
| 建议的收益/政策差分训练 | router 参数 $\phi$ | 预测路线价值与政策变更效应，梯度仅流入 router |

Guard 中普通 CE 已通过每条政策对应的 gold 提供政策变化监督；同图配对损失增加的是组内关系约束，不是新的图像或翻转标签。对 Guard 是否另加政策边界 margin，需要看其在可见证据下的 PER/双侧正确率，作为独立消融，不与 router 损失混用。

### 4.0a 收益的数值定义：单样本代价减少量

本方案的收益是**单张图像、给定政策、给定候选路线**下的可计算标量，原始 logits 和多样本 accuracy 都不是默认定义。它由冻结 Guard 输出、该政策的已确认 gold 和预先固定的代价函数计算，再相对一个 reference 做差。

对当前 C5，首轮统一 router 损失应沿用已有 teacher 代价，不悄然换成只看正确率的新目标。报告列出的安全任务代价可用以下形式说明：

$$
C_{task}(I,P,a)=w_n\ell_{NLL}(I,P,a)
+w_e\mathbf 1[\widehat y_a\ne y_P]
+w_{fn}\mathbf 1[y_P\ne A,\widehat y_a=A]
+w_{fp}\mathbf 1[y_P=A,\widehat y_a\ne A].
$$

这里错类项与 FN/FP 项可能叠加；是否这样叠加及实际权重以原 teacher 实现为准，上式不是本次核实过的代码。报告说明 FN 权重最高，但没有列出具体系数。令固定归一化时间为 $\widetilde t_a$，则

$$
C_{route}=C_{task}+w_t\widetilde t_a,\qquad
G_{route}=C_{route}(a_0)-C_{route}(a),\qquad a_0=\mathrm{Global100}.
$$

这是选路主头的默认收益：正值表示相对同预算全局路线降低了综合 teacher 代价，负值表示更差；它的单位由代价定义决定，不是 accuracy 的百分点。纯安全任务收益另记为

$$
G_{task}=C_{task}(a_0)-C_{task}(a),\qquad
G_{route}=G_{task}-w_t(\widetilde t_a-\widetilde t_{a_0}).
$$

框内像素和条款解释使用 $C_{task}/G_{task}$，避免把运行更快算成视觉证据更有用；两种量明确命名并分别保存。若同图政策配对的时间增量固定，它在收益差分中抵消；否则先从主头净收益中分离时间项再比较条款效应。本页一般选路公式里的 $C/G$ 默认为原 teacher 的综合 $C_{route}/G_{route}$，证据干预章节显式使用任务量。

若仅用分类字符 NLL 的教学版本，设正确类别概率为 $p_\theta(y_P\mid I,P,a)$，则

$$
\ell_{NLL}(a)=-\log p_\theta(y_P\mid I,P,a),\qquad
G_{NLL}(a)=\log\frac{p_\theta(y_P\mid I,P,a)}{p_\theta(y_P\mid I,P,a_0)}.
$$

比如 gold 概率从 0.20 升至 0.60，$G_{NLL}=\log3\approx1.10$ nats；这是教学数值，不是 C5 结果。需要固定全词表/A–J 条件归一化口径、teacher forcing 位置，以及是否包含 EOS/按 Token 平均；本次没有代码证据确认原 gold NLL 的细节，不悄然重定义缓存值。

raw gold logit 可随所有 logits 的共同平移改变而概率不变，不能直接当收益；正确选项 margin 可作为独立代理但不能与 NLL 混用。单样本 0/1 正确性可以定义另一种成本，但较稀疏；数据集 accuracy/macro recall 是最终评测，不直接提供每个候选动作的稠密收益标签。条款效应 $D$ 和像素作用 $E/J$ 是同一任务代价在不同条件下的差分，不是额外未知物理量。

### 4.1 以配对形式使用现有数据

在 **router 训练的 batch 中**把同一基础图像的 default、flip_target、flip_irrelevant、synonym_target 分组采样，沿用已经确认的标签和冻结 Guard 结果。每行独立监督仍保留，但加入组内差分监督，检验是否减少“这类图片一般选某框”的捷径。只使用实际存在且语义已验证的变体，不为了损失函数未经核验地新造 gold。

先固定 C5 的恢复 Guard，核实 33 路线 teacher 是否来自这个精确 checkpoint、提示与渲染；若来自恢复前 B0，则需在 pilot 上重建目标，因为输入适配已显著改变路线结果。本文无法由汇总报告确认 teacher 与最终 Guard 是否完全一致。

令 $C(I,P,a)$ 是原 C5 teacher 的综合路线代价，包含 gold NLL、已冻结的漏报/误报/错类权重与原定义的时间成本；$a_0$ 为同预算 Global100。以相对全局的收益监督一层标量 gain head：

$$
G(I,P,a)=C(I,P,a_0)-C(I,P,a).
$$

如果原目标包含时延，先把安全任务部分与时延拆开保存，推理评分再明确加入成本；避免用“收益”同时指像素证据与设备速度。对同图政策 $P,P'$，加入

$$
L_{pair}=\operatorname{Huber}\left([\widehat G(I,P,a)-\widehat G(I,P',a)]-[G(I,P,a)-G(I,P',a)]\right).
$$

从候选中抽取高 regret、Global100、少量随机路线用于差分，控制训练成本。Soft distribution 与排序损失可以保留；新增 gain head 提供同尺度、可核验的量。若只保存 route logits，不能把未经校准的两组 logits 差当作真实效用差。具体可增加

$$
L_{gain}=\operatorname{Huber}(\widehat G_\phi,\operatorname{sg}[G]),\qquad
L_{router}=L_{existing}+\lambda_gL_{gain}+\lambda_pL_{pair}.
$$

$\operatorname{sg}$ 表示目标 stop-gradient；teacher 代价/收益不更新 Guard。数值权重在内部验证选择，收益回归和差分分别消融，尚无证据保证组合一定改善 C5。

### 4.1a 相对收益不是新的排序信息

对固定图像与政策，$C(a_0)$ 对全部路线相同，因此

$$
\arg\max_a G(a)=\arg\min_a C(a),\qquad
\operatorname{softmax}_a(G(a)/T)=\operatorname{softmax}_a(-C(a)/T).
$$

仅把原 teacher cost 改写为相对 Global100 的 gain，不改变硬排序、同条件 pairwise route margin 或 softmax 软分布。其用途是给出零收益基准、可核验的增益大小和局部净收益门控；这些是建模/校准用途，不能被当作已有 loss 的新信息来源。真正新增的监督形式是 gain 回归、同图跨政策差分或匹配像素 probe。若现有 router 已准确预测绝对成本/政策差分，新增项也可能冗余，应做消融。

若不增加 gain head，可以对冻结 teacher 的收益优化 $-\sum_a\pi_\phi(a\mid I,P)G(a)$，梯度通过 router 的概率 $\pi_\phi$；这相当于期望代价目标，不是将与参数无关的单个收益常数加进 loss。其与原 teacher 目标的重叠、概率集中和效果均需单独验证，第一轮不同时改变全部目标。

### 4.1b 为什么不直接奖励 Guard 超过 Global100

仅以 NLL 为代价，设可训练 Guard 的局部/全局 loss 分别为 $L_\theta^a,L_\theta^0$。若直接最小化 $L_\theta^a-\lambda(L_\theta^0-L_\theta^a)$，则

$$
L=(1+\lambda)L_\theta^a-\lambda L_\theta^0.
$$

这个目标含有提高全局 loss 的激励，可能通过让 Global100 变差扩大“相对收益”；若全局项 stop-gradient，在单路线、固定权重的这个 NLL 例子中只相当于重加权局部 CE。它不能替代正确的路由学习目标。Guard 自身需要改进政策响应时，可以借鉴 [[LLM-Wiki/research/visual-token-pruning/papers/2026-song-policyshiftguard.md|PolicyShiftGuard]] 的同图政策 margin；这与路线收益回归是两个对象，且不能迫使证据已丢失的输入产生高置信判定。

### 4.2 什么应变，什么应不变

同义改写与条款块换序在语义不变时约束路线收益分布一致；政策块换序须维护完整条款和例外，不能任意重排内部词语。目标条款放行时，学习真实收益变化，不要求选另一框。无关条款放行只有在确认为该图及候选视图无关时才加不变性；否则使用实测差分，避免过强约束。

A–J 是输出编码，条款/风险身份使用规范 O1–O9，不能让命名字母成为视觉 grounding 的语义。若扩展标签顺序扰动，必须同步标签图例和 gold 映射；当前 C5 报告没有证明该扰动已完成。

### 4.3 一个能隔离 router 的政策干预

对同一图像，保持最终 Guard 的真实政策 $P$ 不变，仅给 router 输入同义政策、目标条款反转、其他样本政策或无政策。渲染各自选中的路线，再由同一 Guard 读取真实 $P$。记录最终质量、实际代价和 oracle regret。这样能区分政策对路线的影响与 Guard 对政策的影响；与整体删除政策的实验含义不同。

定义路线 regret 为 $C(I,P,\widehat a)-\min_{a\in\mathcal A} C(I,P,a)$。近似并列路线应有零/低 regret，不能只统计 route ID 一致率。Oracle 使用 gold 仅作离线不可达上界；未知的 test oracle 不得用于在线选路或调参。

### 4.4 用统一路线收益替换现有前三项 router 损失

用户补充现有 router 有四项：预算/profile 的软标签 KL、区域软标签 KL、路线得分排序损失、标签反转惩罚。以下保留第四项的原定义，不把它自动等同本方案新增的跨政策差分损失；具体代码未检查。

**可以统一监督对象与输出，也可以试验只用收益回归替代前三项，但不能宣称替换前后数学等价。** 预算/profile 与区域共同定义完整动作 $a$，例如 Global100、75/25＋框 5、50/50＋框 12。让 router 对全部有效动作预测同一尺度的相对收益，部署直接对完整动作取最大值，不先以 profile 概率总量选 profile 再在其中选框。

可以保留当前 CNN 与文本 encoder，并将已有输出组合或改为完整路线评分 $s_\phi(I,P,a)$。用

$$
\widehat G_\phi(a)=s_\phi(a)-s_\phi(a_0)
$$

显式锚定 $\widehat G(a_0)=0$；也可以直接固定 Global100 的输出为零，预测其他路线的 gain。收益是有符号实数，不用 sigmoid 或每 profile 独立 softmax。Alias/无效路线按原规则去重、屏蔽，所有输出必须在同一可比较尺度上。

Teacher 沿用原风险代价：gold NLL、分类错误、Unsafe→Safe、Safe→Unsafe 等已冻结权重；不能为简化而只保留 NLL。如果原排序目标包含真实时延成本，应统一放入总 $C$，或先学安全 gain 再减同尺度的额外时延，二者不能重复扣除。第四项若已惩罚相同漏报事件，核对其与 $C$ 的重叠和有效权重；第一轮不同时取消安全约束。

纯回归版本是

$$
L_{reg}=\frac1{|\mathcal A|}\sum_{a\in\mathcal A}\operatorname{Huber}(\widehat G(a),\operatorname{sg}[G(a)]),\qquad
L_A=L_{reg}+\lambda_fL_{flip}.
$$

在容量和可观测信息允许、拟合充分的理想情形，收益预测同时确定比例、区域和排序；有限容量下 Huber 的平均误差并不保证最优路线正确，尤其大量差路线可能主导拟合、少量高收益路线被排错。VIP-Router 使用效用 Huber 回归提供先例，但未验证其能替代 C5 当前三项损失，见 [[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md]]。

建议的稳妥简化版本，以同一收益生成联合路线 teacher 与 router 概率：

$$
q(a)=\frac{\exp(G(a)/T)}{\sum_{b\in\mathcal A}\exp(G(b)/T)},\qquad
\pi_\phi(a)=\frac{\exp(\widehat G(a)/T)}{\sum_{b\in\mathcal A}\exp(\widehat G(b)/T)},
$$

$$
L_B=L_{reg}+\lambda_j\mathrm{KL}(q\Vert\pi_\phi)+\lambda_fL_{flip}.
$$

这里一个联合路线 KL 替代独立预算 KL、区域 KL 和单独排序 loss；gain 回归负责可校验的数值，joint KL 负责整体路线分布。它们共享 teacher 收益，不再给各头生成独立标签。纯 joint KL＋第四项也是可执行的单监督版本，理想极小值且 Global100 零点固定时可确定相对分数；实际训练中尾部路线收益校准弱，不能仅凭 KL 值小就主张收益准确。若需要固定 profile 先验以避免候选数量改变局部总概率质量，teacher 与 student 使用同一明确先验；不要暗中改变比较协议。

若现有两个 KL 的标签已经由同一 joint teacher 边缘化、条件化得到，且区域 KL 按 teacher profile 概率加权，则按 KL 链式法则

$$
\mathrm{KL}(q(p,r)\Vert\pi(p,r))
=\mathrm{KL}(q(p)\Vert\pi(p))
+\sum_p q(p)\mathrm{KL}(q(r\mid p)\Vert\pi(r\mid p)).
$$

Global100 的条件区域为单一空区域。只有在目标、mask、权重、条件分布一致时，该合并才与前两项等价；现有实现是否满足尚未检查。单独排序项的去除仍是优化变化，不属于这个等价式。

首轮固定 Guard、候选库、teacher、数据、训练预算和安全代价，比较现有四项、$L_A$、$L_B$。以实际选路 regret、Unsafe→Safe、macro recall、PER、Global100/各 profile 使用率和 E2E 选择，不能根据回归 loss 最低选模型。可用训练集固定尺度归一化；按路线独立归一化时必须复原到原尺度再选路，跨政策差分也在同尺度计算。接着才对胜出版本加入跨政策 gain-delta，避免同时替换全部目标与增加额外监督。

## 5. 第二项优化：验证局部像素的实际作用

借鉴 CounterCredit 的两种比较，区别“把预算分给局部是否值得”与“选中的局部像素是否有帮助”。这两项并不等价。

取局部路线 $a=(\rho,r)$，固定同一恢复 Guard、真实政策、global 渲染分辨率、local Token 数、视图顺序、尺寸、letterbox 和位置接口。构造真实 crop、同尺寸匹配无关 crop、局部 blur/中和的对照。无关 crop 只能是候选对照，随机 patch 未必无关，需多个对照和抽检。

本节明确使用 $U=-C_{task}$ 为安全任务效用，$U_{real}$ 是真实局部路线，$U_{null}$ 是相同布局只替换 local 内容的路线。此处的 $G$ 为 $G_{task}$，不含时间收益。定义

$$
E(I,P,a)=U_{real}-\mathbb E[U_{null}],\qquad
G(I,P,a)=U_{real}-U_{Global100}.
$$

两个比较的全局输入不同之处必须说明：计算 $E$ 时 global 完全不变，用于隔离 local 内容；计算 $G$ 时 Global100 使用全部 $K_{eff}$，用于反映真实预算取舍。不能通过直接少一个视图或减少 Token 来假装纯像素干预。

| 实测 | 解释 | 优化方向 |
|---|---|---|
| $G>0,E>0$ | 局部路线带来净收益且依赖其像素 | 可靠的局部正监督候选 |
| $G>0,E\le0$ | 收益可能来自布局/其他改变或对照噪声 | 降低作为空间证据解释的置信，不直接定性为虚假 |
| $G\le0,E>0$ | 像素有用但全局预算损失抵消 | 提高 Global/75% 全局保留，或保留全局路线 |
| $G\le0,E\le0$ | 当前局部路径不值得执行 | Global100 正监督候选 |

先在 train 内 pilot 对 C5 选中路线、teacher 高收益路线及一个随机对照加 probe，不对全部 33 路线穷举多个 null。训练 router 预测 $\widehat G,\widehat E$，用实测目标监督；在原风险代价上加入对“无证据收益的局部路线”的软惩罚，或以经过验证集校准的双门选择局部。硬要求两者为正可能过度保守，需与连续惩罚比较，不能预设最优。

在线仍只评分后执行一条 Guard 路线，null probe 仅用于离线训练与机制评测。解释可以报告“预计净收益、预计像素贡献、对应条款、所选区域与 profile”，不额外生成长理由。预测证据价值必须经离线校准，不能写成每次在线决策已得到因果认证。

## 6. 第三项优化：条款级评分实际进入选择图

### 6.1 最小结构改动

从已有模板构造条款单元 $(c,text_c,status_c,exception_c)$。在仅 9 类允许/禁止切换的子集可用 O1–O9；若模板包含更细禁止项、允许项或例外，就按实际字段保留，不能用 9 个开关替代全部语义。当前报告未附模板，字段可行性待检查。

复用字节 encoder，对完整条款分别编码或在整段序列按条款边界池化，加可验证的 allow/block 状态表示。保留条款内部位置和句义；条款 ID 使用规范语义身份。不同条款不能被长文本中的偶然先后次序定义。

复用 16 个 CNN 区域特征，构造条款 query 对区域的 cross-attention，显式输出 $M_{c,r}$ 及每条款对 Global100、75/25、50/50 的收益/语境风险预测。基础消融先使用原 33 动作；扩展单框几何后用共享候选评分头，最终仍只有至多一个局部框。若用多头 attention，应明确如何得到单个可审计评分，而非任意挑好看的头。

条款贡献要真正进入 route score。例如使用受监督的有符号条款贡献加全局语境项，生成各动作 gain。例外或条款交互需有独立可检查的项；这是候选可解释评分结构，不保证复杂政策的真实效用可加性分解。若保留 unrestricted residual 绕过条款，必须报告其贡献；若它占主要评分，就不能声称条款中间量完整解释了路由。

同一图像的视觉事实估计在允许/禁止变化前后应稳定，当前违规判断和检查优先级再受政策状态影响。视觉事实头可以读取“发生何种事件”的语义查询，但不能把“被允许”作为视觉事实不存在的训练标签。允许某类时仍可能需要看见它来确认例外或排除其他违规，不做“一允许就丢弃”硬门。

### 6.2 监督和解释的界限

现有图像类别标签最多提供粗类别弱监督，不能直接铺到所有区域作为 pixel gold；Safe 也不代表每个风险视觉事实都不存在。以路线干预产生的条款相关效用监督为主，辅以少量 train 内区域—条款审核或仅训练期 grounding teacher；定位与“该 crop 对 Guard 有效”必须分别验证。

CNN 区域特征的感受野可能跨区，attention map 不等同于原像素依赖。需要原像素替换、条款状态修改、命名中间量修改三类干预。强迫热图稀疏或 foreground-only 容易丢掉行为上下文与允许例外，不作为默认损失。

PF-CBM 的迁移价值是中间量实际参与评分和防止命名头语义错配，不能保证本设计是完整概念瓶颈。此处只解释 router 的预算分配；最终 Guard 的 A–J 判定仍需单独做证据使用验证，不能由路由解释自动推导 verdict 理由。

### 6.3 政策文本如何进入路线评分：一个具体设计

以下是**拟议结构与教学例子**，不是当前 C5 的实际实现、实验样本或观测分数。设图像左边有两人持械冲突，右边有狭长仇恨标语。政策 $P_1$ 禁止暴力、允许仇恨表达，$P_2$ 允许暴力、禁止仇恨表达；示例只解释不同规则下的预算分配，不假设当前单标签数据包含此多风险场景。

每条政策先按模板获得语义正文、允许/禁止状态及例外。用原字节 Transformer 编码语义正文 $e_c\in\mathbb R^{128}$，用一个 embedding 表编码状态 $s_c$。若正文中仍含否定、条件或例外，完整保留其语义；只有已知模板字段才做确定性拆分，不用关键词删除改造任意政策。

图像 CNN 给出区域特征 $h_r$ 和全局特征 $g$。条款语义与区域可先形成匹配矩阵 $M_{c,r}$，用于检查“暴力条款匹配冲突处、仇恨条款匹配标语处”。独立 sigmoid/无证据槽可避免即使无相关物体也必须把 attention 分给一个区域；匹配信号本身不宣称概率已校准。

对候选路线 $a=(b,\rho)$，在 CNN 特征图上用池化或 ROIAlign 获得 $v_a$；加入框位置、大小、宽高比 $\gamma_a$ 与实际全局/局部 Token 数 $k_a$。直接复用缩略图特征，不逐候选裁图或运行 Guard。共享小 MLP 预测每条款对这条路线的贡献：

$$
u_{c,a}=\mathrm{MLP}_{gain}([e_c;s_c;v_a;(W_e e_c)\odot v_a;g;\gamma_a;k_a]).
$$

这里 $\odot$ 使文本与视觉逐维交互，维度先投影到一致。匹配矩阵可以帮助池化/辅助监督，但最低可执行版本只需上述联合输入，不必先实现复杂 attention。$u_{c,a}$ 表示该条款下相对 Global100 的路线贡献，不是“图片里是否有暴力”的概率。

以受监督的 context head 预测全局损失 $H_a$，最终候选评分示意为

$$
S(a)=\sum_c u_{c,a}-H_a-\lambda\Delta t_a,\qquad S(a_0)=0.
$$

$\Delta t_a$ 是相对 Global100 的预计额外成本。同图禁/允变化保留图像 $v_a,g$ 与几何 $\gamma_a,k_a$，改变相应条款状态/语义，直接通过 $u_{c,a}$ 改变 $S$。这个分解不预设各条款真实风险严格可加，先在独立条款切换的模板子集验证；复杂交互需显式增加并单独审计。$H_a$ 与 $u$ 不能在同一总收益里重复扣除损失。

举例忽略成本项，假设网络预测如下**演示数值**：

| 政策 | 候选单框 | 暴力条款贡献 | 仇恨条款贡献 | 全局损伤 | 总分 |
|---|---|---:|---:|---:|---:|
| $P_1$ | 左侧冲突框 | 0.50 | 0.02 | 0.10 | 0.42 |
| $P_1$ | 右侧标语框 | 0.03 | 0.02 | 0.08 | −0.03 |
| $P_2$ | 左侧冲突框 | 0.02 | 0.03 | 0.10 | −0.05 |
| $P_2$ | 右侧标语框 | 0.02 | 0.55 | 0.08 | 0.49 |

因此 $P_1$ 选冲突框，$P_2$ 选标语框。允许项贡献没有被强制清零，因为仍可能需要确认视觉事实或例外。如果相关框导致 $H_a$ 过高，总分也可能小于零而选 Global100；“匹配某条款”不足以强迫局部裁剪。

### 6.4 这些条款贡献怎样训练

teacher 在同一 Guard 上给出总体收益 $G$，可以直接监督总路线分数。只改变条款 $c$ 的配对能够提供该条款的条件边际效应；这并不能直接标注每条款的绝对贡献。只有额外假定评分可加、其他条款项与 context 项保持不变时，才可把总体差分交给单个 $u_{c,a}$；这些是假设，不能由给 MLP 命名自动成立。用同义改写、单条款变更及匹配像素干预检查语义与 grounding。

只给总体 $G$ 无法唯一识别每条款的绝对贡献，配对差分也主要识别变更效应；上述表格不能从已有 gold 直接分解得到。若要把 $u$ 解释为定量的绝对条款收益，需要额外条款干预、无证据基准、匹配全局降采样对照及可核实语义监督。第一轮可以先训练联合 gain head，只主张可追溯的政策变更效应，再逐步验证更强分解。视觉事实头必须独立检查，不能由 route utility 代替。

### 6.5 推荐的条款级训练标签：条件边际效应

**MLP 没有天然的条款/区域收益先验。** 当前 C5 的路线总 teacher、A–J gold 和模板信息不能唯一生成 §6.3 表格里的绝对条款分数。该例子的两种政策同时改变暴力和仇恨两项，只能演示选路，不能用于识别某一条款的训练标签。应把第一阶段可解释目标明确为“固定其他政策时，切换条款 $c$ 对路线净收益的影响”。

令 $P^{c,+}$ 与 $P^{c,-}$ 是只改变条款 $c$ 的禁止/允许状态的两个合法政策，其他条款/例外保持一致。允许/禁止只是该模板下的控制，不能通过字符串删除否定来构造任意政策。图像、候选框、profile、实际 Token 数、Guard checkpoint、提示和渲染固定，gold 则按每个政策已确认的标签计算。本节明确以 §4.0a 的 $C_{task}$ 生成条款任务效应，下式简写的 $C/G$ 均不含时间成本：

$$
G^{c,s}_a=C(I,P^{c,s},a_0)-C(I,P^{c,s},a),\qquad s\in\{+,-\},
$$

$$
D_{c,a}(I,P_{-c})=G^{c,+}_a-G^{c,-}_a.
$$

$D_{c,a}$ 是**相对同预算全局路线的条款变更效应**，不是图片固有的风险强度、物体出现概率或条款的唯一绝对贡献。它可以为负或零；其他条款、Guard 饱和/错误、证据冗余和 gold 变化都会影响结果。不能仅凭 $D=0$ 判断该框没有该类视觉事实。

例如以下为**教学代价，非实验数字**，除暴力允许/禁止外其余政策相同：

| 暴力条款状态 | Global100 代价 | 候选冲突框路线代价 | 路线收益 |
|---|---:|---:|---:|
| 禁止 | 1.20 | 0.40 | 0.80 |
| 允许 | 0.20 | 0.15 | 0.05 |

该框对应暴力条款的变更效应为 $0.80-0.05=0.75$。四种组合来自冻结 Guard 评测，可从完整 teacher 缓存复用，无需把某个 A–J 标签强行变成框内 gold。其他候选框用相同程序得到不同效应。

MLP 训练输入建议为 $(e_c,v_a,g,\gamma_a,k_a,z_{-c})$：条款及其例外语义、从预览提取的候选框特征、全局图像特征、框几何、实际 Token 数和其他政策的表示。因为效应是在某个其他政策背景下定义的，不能默认只用 $(e_c,v_a)$ 就能预测所有 bundle 下相同数值。禁止/允许对本身是该差分定义的两端；若输入任意当前状态，需明确输出相对哪一端。

对具有合法单条款配对且路线有效的项目设 mask $m_{c,a}=1$，训练

$$
L_{clause}=\frac{\sum_{c,a}m_{c,a}\,\operatorname{Huber}(\widehat D_{c,a},\operatorname{sg}[D_{c,a}])}{\max(1,\sum_{c,a}m_{c,a})}.
$$

没有配对或 gold 无法可靠确定的条款不填零标签；保留未监督状态。对已有 default/flip_target/flip_irrelevant 先核对其他条款语义是否一致、gold 是否有效；synonym_target 可用作语义不变控制，不把它当作允许/禁止边界对。不能用最终 test 生成训练标签。

### 6.6 更强的空间证据监督：政策 × 局部像素

仅有 $D$ 仍可能反映 Guard 的文本捷径或路线结构效应，不能证明效应来自框内内容。固定同一政策、global 图像、local Token/尺寸/视图顺序，比较真实局部与多个匹配替换/blur 对照，定义

$$
E^{c,s}_a=U(I,P^{c,s},a_{real})-\mathbb E_jU(I,P^{c,s},a_{null,j}),\qquad U=-C_{task},
$$

$$
J_{c,a}=E^{c,+}_a-E^{c,-}_a.
$$

$E$ 衡量该政策下的局部像素作用；$J$ 衡量这种像素作用随条款状态的变化。真实与 null 的 global/profile/实际 Token 必须相同；用 Global100 代替 null 会再次混入全局预算改变。沿用多个合法替换类型，随机 patch 未必真正无关，不能把一次差分称为人类因果真值。

在上表中再假设禁止/允许下的 null 路线代价分别为 1.00/0.18，则 $E^{c,+}=1.00-0.40=0.60$，$E^{c,-}=0.18-0.15=0.03$，$J=0.57$。仍为教学数值。可以单独训练像素作用预测头，但不要把 $D$ 和 $J$ 的总和直接当新总 gain，二者有重叠。

这一构造是对 [[LLM-Wiki/research/visual-token-pruning/papers/2026-peng-countercredit.md|CounterCredit]]/[[LLM-Wiki/research/visual-token-pruning/papers/2026-huang-evidence-rl.md|Evidence-RL]] 离线干预思想的场景迁移，尚未在 C5 验证。首轮只对训练样本的 teacher 优选/当前 router 选中与少量随机路线补 null，不对全部条款、路线、替换方式穷举。在线保持一个实际局部框和一次 Guard 执行。

### 6.7 先验与监督来源及最小结构

| 信息 | 获取方式 | 可训练/约束的内容 | 不能直接代表什么 |
|---|---|---|---|
| 条款身份、禁止/允许、例外 | 已有模板和规范类目 | 政策语义绑定、合法单条款变更 | 区域视觉存在性或收益 |
| 路线及政策变更效果 | 冻结恢复 Guard 的 teacher、合法 gold | $G$ 与 $D$ 数值监督 | 人类标注的绝对条款因果贡献 |
| 框内像素作用 | 匹配替换/blur 干预 | $E/J$ 的模型证据使用监督 | 无条件安全保证 |
| 条款—区域匹配先验 | 原图审核的小样本框、已有定位器/OCR 或视觉语义 teacher | grounding 辅助目标/预训练 | 对本 Guard 的实际净收益 |

匹配先验是可选项。它可能帮助识别“人/工具/文字在哪”，却不能替代主体—动作—上下文关系，也不把 Safe 当作所有视觉风险事实不存在。所有自动定位/OCR 标注只在训练期使用并标为弱标签；若推理使用额外 encoder，则另计部署成本。现有 128×128 预览已丢失的证据不能通过监督变成可观测内容。

当前更稳妥的第一版是 **共享图文主干＋总路线收益主头＋条款差分辅助头**：主头按 §4.4 学 $G$ 并选路，辅助头按本节学 $D$，可增加与主头在两政策下的预测 gain 差的一致性检查。它解释的是政策变更响应，并通过共享主干提供监督；不把辅助预测自动当作实际总评分的完整分解。

若要求条款项直接相加构成总分，应额外规定合法参考政策、基准路线收益与交互项。固定顺序逐条变更可以定义顺序依赖的增量；平均多种顺序是另一种交互分配方案，离线成本更高。当前只有有限单条款配对，不能默认 $\sum_cD_{c,a}=G_a$，也不把这些边际效应当作 Shapley 值。首轮不做全政策组合 teacher。

## 7. 补充：单框几何与全局清晰度

### 7.1 先区分选错与候选框无法覆盖

用户后续的定性观察提示至少三类失败：现有候选中有可用路线但 router 没选中；原 1/16 单格都不够完整而新单框能覆盖；在严格 5% 下扩框后仍无法达到必要的清晰度。尚无各类数量或新增 oracle，不能宣称某一类是已确定主因。

在 train/internal-val 固定恢复 Guard，比较原 33 路线 oracle 与扩展单框 oracle，分别记录救回、新增错误、政策组和代价。若原路线已有正确答案，优先优化评分；若只有新几何能救回，就补候选表示；若都失败，再检查预算/渲染/Guard。原 33 路线全部失败不能直接归因于 5% 或 Guard，因为固定框几何本身尚未排除。

### 7.2 最小单框库：先加大小和形状，再考虑连续微调

第一轮可沿原 4×4 网格，保留 16 个 1×1 单格，再加入 12 个 1×2 横框、12 个 2×1 竖框、9 个 2×2 大框，共 **49 个单框**。两个原 profile 加 Global100 最多为 **99 条逻辑路线**，合法预算下的 alias/无效路线仍剔除。每条路线都只渲染一个 local crop；候选评分复用同一缩略图特征。对跨度更长的证据，再有针对性加 1×3/3×1 等单框，初期不做全部连续坐标搜索。

该库解决部分跨格和尺度问题，仍不能保证覆盖任意证据：原图宽高比影响实际框形状，边界目标可需要重叠中心或有限坐标残差。可在后续为已选 anchor 加有界中心/宽高残差；最终仍输出一个矩形。GapSight 的候选先验、有限残差和语境扩框是近邻，见 [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhu-gapsight.md]]；单框几何变化本身不作为原创政策机制。

新增 teacher 的理想动作数约为旧库三倍，实际成本依合法路线去重及真实 profiling 确定，不能把轻量在线评分等同离线 teacher 免费。若恢复 Guard 对新增尺度不适配，先记录固定 Guard 的几何诊断，再进行共同适配与新 teacher 生成；不能把不同 Guard 的收益混成几何贡献。

### 7.3 扩框不自动恢复清晰度

面积为原图 $a_b$ 的 crop 分到 $K_l$ 个 Token，其近似相对 B0 采样密度为 $K_l/(a_bN)$；这是忽略 letterbox、网格取整及动态分辨率的面积近似，不是实测质量定律。名义 5% 的 75/25 下，1/16 框约为原图 B0 的 20% 密度，1/4 大框约为 5%。因此大框覆盖更多上下文，但相同局部预算下放大优势下降。

应联合评分 **位置、面积/宽高比、全局/局部实际 Token 数和预计收益**。狭长证据优先匹配狭长框以减少无关面积；视图的合法网格尽量匹配其内容宽高比，记录 letterbox 内容占比，避免补边消耗仅有的视觉预算。128×128 router 预览与最终 Guard 的低清 global 是两个不同问题，增加前者不能直接恢复后者像素。

如果需要的大范围视觉关系在 5% 下始终不清晰，就用 Global100/profile 选择尽量减少损伤，并把失败保留为预算限制；更宽预算只作为后续压力曲线，不能偷偷抬高单样本预算来救回。

**净收益与语境损伤分头。** 将局部细节收益、全局预算缩小导致的损伤分开预测，仍从原 33 路线中选动作。可在相同 local crop 下比较 75/25 和 50/50、再加相应 global 分辨率的匹配 null 以定位差异。监督来自实际结果，不能仅用“图像看起来复杂”当上下文损伤标签。若预测局部收益抵不过语境损失，就选 75/25 或 Global100；不是输出 Safe。

**预览信息上限。** 128×128 预览可能抹掉小目标/OCR，属于待验证瓶颈。在新增单框几何仍有 oracle 空间而 router 无法预测时，以同一目标、同容量 router 比较 128 与 192/256 预览，或保留 CNN 的 8×8 中间特征辅助定位，记录额外实际时延。ROIAlign 只能读取现有特征，不能创造缩略图中已消失的细节。提高预览清晰度不增加 Guard 的局部框数，但增加系统计算；它与增加最终 global 的清晰度需分开消融。Oracle regret 是参考，不能单凭它证明感知瓶颈。

更高分辨率、预训练视觉特征、Guard 再训练均放在政策损失/结构之后单独消融。首次优化固定 Guard，可保留当前低预算恢复训练为共同背景；不要同时换 encoder、policy encoder、candidate bank 与 Guard，使改善无法归因。

## 8. 具体实施顺序与门禁

以下为建议计划，未执行，规模与阈值均须在实际算力和内部 pilot 中定稿。

| 顺序 | 实现变量 | 共同条件 | 判断依据 |
|---|---|---|---|
| A0 | Frozen C5 的 router-only 政策干预；33 路线 oracle/regret | 同一 C5 恢复 Guard与渲染 | 确认可学习的政策收益差与路线改善空间 |
| G0 | 原库 vs 49 个多尺度/宽高比单框库的 oracle | 同一 Guard、严格预算；只改单框几何 | 区分选错、框覆盖不足与预算清晰度限制 |
| G1 | 共享框特征/几何/profile 评分头 | 旧/新库各自匹配 teacher，保留旧 C5 对照 | 新候选的实际救回、净增益与时延 |
| A1 | 原 router ＋相对 gain head＋同图 policy-pair loss | 原 33 路线、原预算；其他训练不变 | 语义同义稳定、有效翻转的 gain-delta 对齐、PER 和 regret |
| A2 | A1＋匹配布局 $E$ 监督、净收益选择门 | 同一 Guard、动作库 | 独立 null 类型的像素使用、救回/新增漏报、同局部使用率对照 |
| A3 | A2＋显式条款级实际评分 | 同容量文本条件 baseline | 条款语义、状态修改与 route score 的对应、质量与时延 |
| A4 | 语境损伤头或预览分辨率 | 每次只改一项 | 消除可重复失败并保留真实净加速 |

Pilot 建议覆盖 train 内 256–512 个基础图像及其已有政策变体，按基础图像组隔离内部验证；这是规划规模，不是已经运行的 C5 新实验。考虑到新的几何观察，先做 G0，再选择 G1/A1 的推进顺序；几何与政策损失不能同时改变后直接归因。A1–A3 在同一个冻结候选库内比较。避免只选 teacher 成功样本，报告 full teacher 失败和所有路线失败子集。先复用合法 teacher 缓存；新增 probe 成本按实际候选数审计，通过后再扩到 9,569 行。不得沿用失败多框实验的 GPU-hour 估算为本方案成本。

主要结果在同一 Guard 上比较 Global100-cap、当前 C5、匹配容量 V5/打乱政策、A1、A2、A3。打乱政策的 frozen 干预和重新训练的无政策 baseline 含义不同，都需保留。增加同局部执行率、同 profile 占比或相同平均时延的对照，以排除减少局部使用本身解释全部收益。

质量以宏召回、Unsafe recall/FPR、PER/配对两侧均正确率、worst-policy/风险组及新增 Unsafe→Safe 为主；有合法分数时在 dev 预定阈值比较 fixed-FPR recall，避免反复挑 test 阈值。按基础图像而非政策行 bootstrap，避免把同图变体当独立样本；多 seed 的候选差异再确认。

解释性同时测：条款/区域语义审计、真实与 null 的支持差、删除/替换匹配背景的差异、route regret、预测 gain 与真实 gain 的相关/校准、政策同义稳定和目标条款改变的效用变化。改变某条款后必须换框、attention 更集中、自然语言理由更流畅均不作为主解释指标。干预不能要求删掉一个区域就变 Safe，可能有冗余或其他风险证据。

效率报告完整 time-to-verdict、P50/P95、router/preview/渲染/Guard、各 view 实际 Token；核对当前约 11 ms 未解释计时差额。初期可设相对当前 C5 的时延容忍上限，但具体数值是待确定门槛。出现质量仅平均改善、政策组不改善、解释通道失真或 selector 消耗超过收益时，缩小方法主张或停止该分支。

## 9. CVPR 主张与尚未解决的问题

目前更值得检验的主张是：**动态政策下，对单框低预算视觉路径进行条款可追溯的收益建模和反事实证据监督，改善漏报与计算取舍。** 需要同时给出规范条款变化、实际像素使用、固定预算质量和真实速度四类证据。

SafeWatch/QuietPrune 约束“政策/文本指导”的新意，GapSight/VIP-Router 约束“teacher 收益路由”的新意，CounterCredit/Evidence-RL 约束“反事实像素监督”的新意；仅拼接这些组件不自动构成贡献。潜在差异是政策变更下对视觉事实、当前规则及有限预算的联合建模，是否在可复现的配对实验中优于普通 query relevance 和普通结果监督。此差异尚待验证，未修改为已证实 gap。

若 33 路线 oracle 仍明显落后完整视觉，不能承诺仅改 router 恢复 B0。5% 是压力点，应在候选方法确定后补少量更宽预算点来识别拐点；这不改变单框约束，也不把原 5% 失败抹去。短政策语义覆盖、未来未见规则与跨体系泛化仍是场景有效性的独立问题。

关联论文：[[LLM-Wiki/research/visual-token-pruning/papers/2026-zhu-gapsight.md|GapSight]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-ramachandram-pf-cbm.md|PF-CBM]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-peng-countercredit.md|CounterCredit]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md|VIP-Router]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-huang-evidence-rl.md|Evidence-RL]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md|SafeWatch]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]]；[[LLM-Wiki/research/visual-token-pruning/region-rationale-guided-safety-token-pruning.md|区域监督综述]]。
