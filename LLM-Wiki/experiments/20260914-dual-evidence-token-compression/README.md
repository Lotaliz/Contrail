---
id: 20260914-dual-evidence-token-compression
type: experiment
title: "双证据视觉 Token 压缩与原生视觉尾部适配"
tags: [experiment, visual-token-pruning, token-merging, vision-language-model, multimodal-safety, representation-probing, knowledge-distillation, efficient-inference]
status: draft
created: 2026-09-14
updated: 2026-09-24
---

# 双证据视觉 Token 压缩与原生视觉尾部适配

> **状态：实验设计草案，尚未执行。** 本页整合 2026-09-09 至 2026-09-14 围绕原语义恢复实验的讨论。已运行结果只作为问题背景；新结构、损失和时延收益均为待验证假设。原始用户设计记录位于 `D:\SPPPAAACCCEEE\阿里安全\实验结果\20260909-visual-reform.md`，本页不修改或覆盖该文件。

## 问题背景与设计转向

原方案在完整视觉前缀之后保留约 10% 原生 merger groups，再训练视觉编码器后半部分，使冻结 LLM 的首类别决策位置接近全 Token 教师。已有 mixed validation 观察到：恢复路径相对纯剪枝显著降低 state loss 与全词表 logit KL，但负样本预测目标类别的 FPR 从 `0.011667` 上升至 `0.226667`，差值 bootstrap 95% CI 为 `[0.179572, 0.251623]`。这些数值来自上述用户实验记录，尚未在本目录复算。

该结果不支持“教师轨迹更接近就等于安全边界恢复”。候选解释是：学生只获得 10% 视觉输入，逐元素恢复完整教师状态是欠定目标，视觉尾部可能用类别先验或显著风险外观逼近平均教师状态，却丢失抑制误报所需的环境、反证和政策例外信息。

本实验将“完整语义恢复”改写为**任务充分的双证据压缩与融合**：

1. 视觉前缀在完整网格上提取浅层局部与全局信息。
2. 双头 selector 分别寻找关键细节证据与上下文/反证证据。
3. 被删 Token 的环境信息以 anchor-preserving residual merge 写入少量 context anchors。
4. 两类 Token 以固定总预算进入同一原生视觉尾部；不新增第二条尾部分支。
5. 原视觉尾部只需保持角色、建立跨角色关系并形成安全判别充分表示，不重建完整 Token 网格。
6. 训练期辅助头、完整教师和反事实消融在部署时删除；LoRA 合并到原权重。

## 研究问题与预注册假设

### 研究问题

1. 完整视觉前缀能否在较早层形成足以区分关键细节和环境反证的表示？
2. 双头 selector 与直接任务监督能否避免单一显著性排序造成的目标类偏置？
3. context anchor 回灌能否在不增加尾部 Token 数的条件下保留被删区域的任务信息？
4. 原视觉尾部能否通过少量、可合并的 LoRA 与 Norm 适配处理压缩后的双角色序列？
5. 中段物理 compact 后，DeepStack、位置编码和 LLM 视觉槽位能否保持一致，并兑现端到端时延收益？

### 待验证假设

- **H1（边界保持）：** 类别集合内 margin、浅层辅助分类和反事实 group ranking 的组合，比原 state-MSE + 全词表 KL 更能控制负类目标 FPR。
- **H2（双证据）：** 固定预算下，同时保留 detail 与 context/counter-evidence groups，比单头 Top-K 提高 hard-negative 边界质量；收益主要体现在固定召回下的 FPR，而不只体现在平均准确率。
- **H3（信息回灌）：** context anchor residual merge 比纯删除更好地保持反证、场景和全局语义，且优于要求视觉尾部从稀疏输入重建完整教师状态。
- **H4（受约束适配）：** 只在剪枝后前若干视觉块训练 Q/K/V/O LoRA 与 Norm，可适配稀疏输入分布，并比全量训练视觉尾部更少破坏预训练结构。
- **H5（真实效率）：** 物理缩短 packed 序列、固定或分桶 Token 预算、合并 LoRA 后，视觉编码 P50 至少降低 50%，端到端 P50 至少降低 20%。
- **H6（位置与接口）：** 保留真实 anchor 的原始视觉位置，并同步 compact DeepStack 与 LLM 视觉槽位，可避免连续重编号和伪矩形网格带来的位置错误。

H1—H6 均为假设，不是已证明贡献。

## 固定任务接口与主要变量

- 模型家族、数据清单、标签协议、图像预算和确定性首类别 Token 判定继承原实验设计；执行前必须在本目录记录精确 checkpoint、数据 hash、依赖、硬件、seed 和命令。
- 视觉塔按原结构分为完整前缀与压缩尾部。第一轮候选剪枝点为视觉 block 2、4、6 之后；不能预设最早剪枝必然最优。
- 对单图原生 merger group 数 $M=THW/4$，第一轮固定 $K=\lfloor0.10M\rfloor$，同时保留较宽预算作为诊断对照。
- selector 在完整 group 级打分；一个 group 被保留时，其四个原 raw patches 必须完整、连续地进入视觉尾部。
- LLM 分类读出固定为第一个类别 Token 之前的最后有效 prompt 位置；类别码必须通过单 Token 合法性门禁。
- 主要变量包括剪枝点、detail/context 配额、是否 residual merge、是否角色 embedding、LoRA 层范围与 rank、局部/关系/类别损失组合。

## 系统结构

### 1. 完整视觉前缀

视觉 block `0...b` 处理完整网格。边界附近最后一个完整 block 同时承担信息聚合作用：detail 候选保持局部 residual，context 候选通过原 self-attention 吸收环境信息。若浅层 probe 的概念可分性或教师 group-importance 排名相关性不足，剪枝点后移，不以损失时延为由强行在不可分层选择。

### 2. 双头 selector

对 merger group $g$ 的局部表示 $h_g$、邻域表示 $h_g^{neighbor}$、原二维位置 $p_g$ 和低成本全局摘要 $h^{global}$，计算：

$$
s_g^D=f_D(h_g,h_g^{neighbor},h^{global},p_g),
$$

$$
s_g^C=f_C(h_g,h_g^{neighbor},h^{global},p_g).
$$

$s_g^D$ 表示局部关键细节，$s_g^C$ 表示环境、反证、政策例外与全局解释价值。两头独立，不使用互斥 softmax，因为同一 group 可以同时包含风险细节和消歧语境。

分别选择 $K_D$ 与 $K_C$ 个候选，去重后满足 $|D\cup C|=K$。重叠 group 只保留一次，释放的槽位分配给下一候选。第一轮比较 detail/context 配额 `75/25`、`50/50`、`25/75`；最终固定比例只由 mixed validation 决定，并始终为 context 保留最低预算，避免风险外观明显时全部槽位塌缩到 detail。

训练使用可微 soft-top-k 或 straight-through assignment，推理使用确定性 hard Top-K。最终保留 groups 按原始栅格顺序排序，不按角色重排。

### 3. Anchor-preserving residual merge

detail groups 原样保留或只接收极近邻、同语义 residual。context group $i$ 作为真实原始 anchor；被删除 group $j$ 按语义和空间共同分配：

$$
a_{ji}\propto\exp\left(\frac{\cos(h_j,h_i)}{\tau}-\lambda_s\lVert p_j-p_i\rVert_2^2\right).
$$

融合不创建虚构空间位置，而写回 anchor 内容：

$$
\widetilde x_i=x_i+\gamma_i\frac{\sum_j a_{ji}(x_j-x_i)}{\sum_j a_{ji}+\epsilon}.
$$

$\gamma_i$ 从 0 初始化。空间不连通、时间相距过远或语义多峰的 groups 不合入同一 anchor，而由多个 context anchors 覆盖。若尾部处理的是每组四个 raw patches，则按相同组内 offset 分别融合，保持原生 $2\times2$ merger 结构。

detail/context 身份可仅通过训练损失隐式形成；若不足，增加两个角色向量：

$$
\widehat h_g=h_g+\pi_g^D e_D+\pi_g^C e_C.
$$

角色向量不增加 Token 数或 Transformer 层。可选的范围信息由少量向量编码 cluster mass、中心相对 anchor 的偏移与空间方差；这是消融项，不修改 RoPE。

### 4. 原生视觉尾部的职责

两类 Token 组成同一长度为 $4K$ raw patches 的紧凑序列，进入原视觉 block `b+1...23`。不建立 detail/context 两套视觉尾部。

- 尾部早期：保持 detail 局部概念，使 context tokens 稳定携带环境摘要。
- 尾部中期：建立 detail—context 关系，让局部风险外观受场景、反证和政策例外调节。
- 尾部后期：形成足以驱动冻结 LLM 安全类别边界的联合表示。

第一轮只在剪枝后的前 4—6 个视觉块训练 Q/K/V/O LoRA，并允许对应 Norm 参数更新；更深视觉块冻结。若注意力适配后仍明显欠拟合，再消融 MLP LoRA 或向后扩展层数。LoRA rank 比较 $r\in\{4,8,16\}$，部署前合并到原权重；全尾部 LoRA 和全量训练仅作为容量上界。

## Selector 与视觉尾部的训练信号

### 1. 类别集合内 margin

设注册类别 Token 集为 $\mathcal C$，正确类别为 $y$。只读取第一个类别 Token 之前位置的注册类别 logits：

$$
m_y=z_y-\log\sum_{c\in\mathcal C,c\ne y}\exp z_c,
$$

$$
L_{multi-margin}=\operatorname{softplus}(\mu-m_y).
$$

对高风险目标类别 $O$，额外定义：

$$
d_O=z_O-\log\sum_{c\in\mathcal C\setminus\{O\}}\exp z_c,
$$

令 $t=1$ 当 $y=O$，否则 $t=-1$：

$$
L_O=\operatorname{softplus}(\mu_O-t d_O).
$$

该损失把梯度集中在真实类别竞争边界，而非全词表无关 Token；它仍经过完整尾部，不能单独解决梯度路径过长。

### 2. 浅层辅助分类头

训练期辅助头只读取 soft-selected groups：

$$
r_{sel}=\frac{\sum_g a_g\phi(h_g)}{\sum_g a_g+\epsilon},
$$

$$
L_{aux}=\operatorname{CE}(C_{aux}(r_{sel}),y)+\lambda_mL_{aux-margin}.
$$

优先使用类别 query 对各 group 产生证据分数，再做 selected-only 聚合，以保留 group—类别归因。辅助头先在完整、随机预算和教师选集上训练，再冻结并训练 selector，防止辅助头与 selector 同时自由适配形成捷径。推理时删除该头。

### 3. 反事实 group ranking

在训练集子集上离线遮挡或删除 group，使用真实类别 margin 定义：

$$
\Delta_g=m_y(x)-m_y(x\setminus g).
$$

$\Delta_g>0$ 表示该 group 对正确边界必要。对非目标样本，该定义会把压低目标类别的反证或环境 group 赋予正重要性。使用 listwise KL 或 pairwise ranking 训练 selector；教师错误样本单独标记，不把错误教师决策当作可靠因果标签。

### 4. 双概念监督与全局语义

风险概念与反证概念采用独立多标签 probe：

$$
r_g=\sigma(P_R(h_g,h_g^{neighbor},h^{global})),
$$

$$
b_g=\sigma(P_B(h_g,h_g^{neighbor},h^{global})).
$$

风险概念覆盖局部风险实体、属性、行为和文字；反证概念覆盖医学/教育、艺术、商品、体育/海滩、新闻警示、否定文本和政策例外。概念表必须按实际标签政策审定，不由模型自由命名后直接作为真值。

局部与全局贡献分开记录：

$$
e_{g,k}=w_k^Lh_g+w_k^Gh^{global}+h_g^\top A_kh^{global}.
$$

全局浅层摘要通过注册类别分布蒸馏，而非强制拟合教师全部高维状态：

$$
L_{global}=\operatorname{KL}(p_T^{\mathcal C}\parallel p_G^{\mathcal C}).
$$

概念 probe 与全局辅助读出优先作为训练期监督；在线 selector 只保留已经被塑形的两组打分头，避免把多个辅助网络带入 serving。

### 5. 角色保持与跨角色关系

在尾部早期，对 detail tokens 对齐教师相同原始位置的特征方向和风险概念：

$$
L_D=\frac{1}{|D|}\sum_{g\in D}\left[1-\cos(h_{g,S}^{l},h_{g,T}^{l})\right]+\lambda_R L_{risk-concept}.
$$

对 context tokens，聚合后蒸馏教师类别分布与反证概念：

$$
L_C=L_{global}+\lambda_B L_{counter-concept}.
$$

在尾部中层匹配教师选中子集的 detail—context 关系，而不重建完整 Token 网格：

$$
R_T=\operatorname{Norm}(H_{T,D}H_{T,C}^{\top}),\qquad
R_S=\operatorname{Norm}(H_{S,D}H_{S,C}^{\top}),
$$

$$
L_{cross}=\lVert R_S-R_T\rVert_F^2.
$$

逐元素完整状态 MSE 降为低权重诊断项。主目标是类别边界、概念保持、反事实重要性和跨角色关系。

### 6. 预训练结构锚定

LoRA 本身不保证预训练功能不变。训练中混入完整 Token replay：

$$
L_{dense-anchor}=\sum_l D\left(F_{W+\Delta W}^{l}(X_{full}),\operatorname{stopgrad}F_W^{l}(X_{full})\right),
$$

并约束 $\lVert\Delta W\rVert_F^2$。完整教师关闭 LoRA，稀疏学生开启 LoRA；无需复制两套尾部权重。

## 位置、DeepStack 与物理 Compact 约束

### 融合 Token 的位置语义

一个融合 Token 无法用单一 RoPE 精确表示多个不连续原位置。本实验固定采用真实 anchor 的原位置：RoPE 表示“该区域摘要锚定在哪里”，融合范围、角色和 cluster mass 写入内容表示。连续 centroid RoPE、相位混合和多位置 attention 会修改预训练位置分布或 attention kernel，只作为远期研究，不进入第一实现。

### 中段缩短序列的必要同步

中段剪枝必须真实把张量第一维从 $\sum_iN_i$ 变为 $\sum_iK_i$；乘零或 attention mask 不计为真实加速。实现必须同步：

1. 从完整视觉位置编码 gather 所选 raw patch 的二维/时空位置，不连续重编号。
2. 按每张图实际稀疏长度重建 packed `cu_seqlens` 与 `max_seqlen`，禁止跨图 attention。
3. 每个选中 merger group 保留四个连续 raw patches，并按原 group index 排序。
4. 主 merger 和所有 DeepStack merger 使用相同 group-index digest，各输出严格 $K$ 个 embeddings。
5. LLM 的 image placeholders、`inputs_embeds`、`attention_mask`、M-RoPE `position_ids`、`visual_pos_masks` 和 cache 位置同步 compact。
6. 先在 `keep_ratio=1.0`、merge/LoRA 关闭时证明 custom path 与 stock path 数值一致，再测试压缩条件。

为适配 serving，第一实现使用固定 $K$ 或少量预算 buckets、一次 GPU gather 和后续标准稠密 FlashAttention；不使用任意块稀疏 mask。动态 Top-K、排序、pack 和 fusion 的时间单独计入 selector/compact latency。

## 训练阶段

| 阶段 | 可训练部分 | 主要目标 | 停止或进入下一阶段条件 |
|---|---|---|---|
| A：浅层可分性 | 训练期类别/概念 probes | 判断剪枝点是否能解码风险、反证和类别边界 | probe 与教师 group ranking 无有效关系则后移剪枝点 |
| B：selector 预热 | 双头 selector；辅助头冻结 | $L_{aux}+L_{rank}+L_{budget}$ | 两头均有非零选择率，hard negatives 的 context coverage 不塌缩 |
| C：尾部适配 | 前 4—6 个尾部块 LoRA、Norm | $L_D+L_C+L_{cross}+L_{dense-anchor}$ | dense replay 不显著退化，稀疏边界改善 |
| D：联合训练 | selector、LoRA、Norm | 类别 margin、概念、关系、有限 KD | mixed validation 选择 checkpoint |
| E：硬选择校准 | hard Top-K forward；代理梯度或冻结 selector | 消除 soft/hard gap | 通过边界、位置、DeepStack 和时延门禁 |

建议总目标为：

$$
\begin{aligned}
L={}&\lambda_1L_{multi-margin}+\lambda_2L_O+\lambda_3L_{aux}
+\lambda_4L_{rank}+\lambda_5L_{concept}\\
&+\lambda_6L_{global}+\lambda_7L_{cross}
+\lambda_8L_{dense-anchor}+\lambda_9L_{budget/diversity}.
\end{aligned}
$$

各项先按 batch 统计量归一化，并监控到 selector score 的梯度范数；不直接复用原实验的类别权重作为默认值。

## 基线与消融矩阵

| ID | Selector/压缩 | 视觉尾部 | 目的 |
|---|---|---|---|
| `F0-full` | 无压缩 | 原冻结尾部 | 完整教师与质量上界 |
| `P0-prune` | 原单头 hard Top-K | 原冻结尾部 | 纯剪枝基线 |
| `P1-single-direct` | 单头 + margin/aux/ranking | 原冻结尾部 | 隔离直接监督收益 |
| `M0-single-merge` | 单头 + anchor residual merge | 原冻结尾部 | 隔离信息回灌收益 |
| `D0-dual-prune` | detail/context 双头，不 merge | 原冻结尾部 | 隔离双证据选择收益 |
| `D1-dual-merge` | 双头 + context residual merge | 原冻结尾部 | 主压缩结构、无适配 |
| `L0-lora-only` | 双头、不 merge | 前部尾块 LoRA + Norm | 隔离稀疏分布适配 |
| `D2-proposed` | 双头 + context residual merge | 前部尾块 LoRA + Norm | 推荐完整方案 |
| `L1-full-tail-lora` | 同 `D2` | 全尾部 LoRA | LoRA 容量上界 |
| `FT-full-tail` | 同 `D2` | 全尾部全量训练 | 结构破坏与容量对照 |

额外消融包括剪枝点、$K_D/K_C$、角色 embedding、空间半径、是否保存 extent、rank、LoRA 模块范围、完整状态 MSE 权重和熵项。信息熵只作为不确定性或多样性信号，不单独定义 Token 重要性。

## 指标、成功标准与停止条件

### 质量与安全边界

- 注册类别 accuracy、macro/worst-class recall、目标类 recall、负类目标 FPR、ECE。
- 固定目标 recall 下的 FPR，以及固定 FPR 下的目标 recall。
- `full→compressed`、`prune→proposed` 的逐样本翻转，单列 hard negatives、OCR、小目标、图文冲突、医学/教育/艺术/商品等政策边界切片。
- 候选成功门槛沿用原设计：目标类 recall 相对 full 下降不超过 2 pp；proposed 相对对应纯剪枝的负类目标 FPR 增量 95% CI 上界不超过 2 pp。正式运行前冻结口径。

### Selector 与解释

- detail/context 选择比例、重叠率、空间覆盖、概念覆盖和选择稳定性。
- 删除/回插 top groups 对 gold margin 的影响，相对随机/均匀组的因果排序增益。
- 训练期 concept probe 的 AUROC、top-activation patch purity 与 concept completeness；probe 可解码性不单独视为因果解释。
- 被选原因至少可分解为局部风险、反证/环境、全局语境、边界不确定性和新增覆盖，而不只输出一个不可解释标量。

### 效率

- processor、完整视觉前缀、selector、Top-K/排序、fusion/compact、稀疏视觉尾部、四个 merger、LLM prefill、TTFT、decode、端到端 P50/P95。
- 记录每个尾部 block 的实际输入 shape，证明序列真实缩短。
- 报告 LoRA 合并后的延迟；未合并 adapter 的额外矩阵乘不作为部署主结果。
- 候选成功门槛为视觉编码 P50 至少降低 50%、端到端 P50 至少降低 20%；FLOPs 不替代实测时延。

### 立即停止条件

- `keep_ratio=1.0` 无法复现 stock 视觉、DeepStack 或首类别 logits。
- 视觉位置、`cu_seqlens`、merger group、LLM 视觉槽位或 cache 长度不一致。
- compact 后后半段仍处理原序列长度，形成伪剪枝。
- 任一图像跨样本 attention、非有限 loss、非零视觉样本 detached loss。
- 双头选择塌缩为单头，或 context 最低预算在 hard negatives 上失效。
- mixed validation 的目标 FPR 门禁失败；不得以 state/KL 改善继续固定测试或时延结论。

## 证据边界与待完成项

- 当前只有原方案的一次负向结果；新架构尚无运行、方差、时延或跨模型证据。
- 10% 是压力预算，不是最优预算结论。若 context/detail 概念在早层不可分，应增加完整前缀深度或预算，而非让视觉尾部猜测缺失信息。
- anchor RoPE 是兼容原编码器的近似语义；它不能无损表达跨越多个不连续位置的融合 Token。非连通区域必须拆分为多个 anchors。
- context residual merge 会低通化局部细节，因此只向 context anchors 回灌；detail anchors 默认不做远距离平均。
- 精确模型、数据、代码、环境、命令、seed、预算和 checkpoint 需在执行前补全；本页不授权高成本运行。

## 关联实体与来源

- [[LLM-Wiki/research/visual-token-pruning/overview.md|视觉 Token 剪枝研究项目]]
- [[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md|历史方案清理记录]]
- [[LLM-Wiki/research/visual-token-pruning/token-merging-landscape.md|视觉 Token 合并路线与证据边界]]
- [[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|ViT Token 剪枝与位置基础]]
- [[LLM-Wiki/concepts/methods/deepstack-visual-token-injection.md|DeepStack 视觉 Token 注入]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-etc.md|ETC：任务相关视觉信息蒸馏]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-otprune.md|OTPrune：子集覆盖与无恢复压缩]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-cho-restore.md|RESTORE：位置与注意力失真校正]]
- [[LLM-Wiki/experiments/20260908-bidirectional-token-intervention/README.md|双向视觉 Token 因果干预审计]]
