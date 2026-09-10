---
id: visual-token-pruning-gaps
type: synthesis
title: "候选研究空白：安全充分视觉前缀与最坏压缩状态训练"
tags: [research, visual-token-pruning, multimodal-safety, knowledge-distillation]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-gu-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-liao-2026-vtc-bench, paper-cai-2024-matryoshka-mm, paper-yang-2025-visionthink, paper-zhang-2026-security-pitfalls-token-compression, paper-chen-2025-safewatch, paper-liu-2025-guardreasoner-vl, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap, paper-zong-2022-self-slimmed-vit, paper-feng-2026-em-kd, paper-cho-2026-restore, paper-chen-2026-otprune]
status: active
created: 2026-09-08
updated: 2026-09-09
---

# 候选研究空白

**结论等级：** 以下是截至 2026-09-09 的有限检索中仍值得测试的问题，不是“从未探索”的断言。背景约束与候选机制分开；正式动机只使用 [[LLM-Wiki/research/visual-token-pruning/motivation.md]] 中达到门槛的事实。

## G0（当前主线）：政策因果安全充分视觉前缀

- **问题：** 能否不设计新 backbone，只保留现有视觉塔前 $d$ 层，通过训练期图文—政策监督使其成为足以支持 Guard 判定的视觉前缀？
- **直接最近邻：** EfficientVLM 已做 VLM 蒸馏与视觉层缩减；MuE 已跳过统一 VL 编码/解码层；METR 已用多出口压力和自蒸馏让早层 `[CLS]` 更任务相关；Patch Slimming 已用深层结果指导早层 patch 选择。因此“浅层+蒸馏+早剪”组合本身不新。
- **场景支持：** ResponseGuard 将其剩余 image-only 差距定位为可能的感知问题，且视觉编码器冻结；FastVLM 表明视觉编码时延在高分辨率下是必须独立优化的成本轴。
- **候选方法假设：** full-depth teacher 与多个 prefix-depth student 共享主干；训练期把原 projector/Guard 判定接到候选深度，蒸馏经人工或受控反事实确认的**政策决策效应**，而不是所有通用语义或事后 rationale。训练结束只部署一个固定深度前缀，辅助出口全部移除。
- **真正需要证明的差异：** 同 backbone、同数据、同训练算力下，超过普通截层 SFT、logit/feature KD、METR 式 early pressure；收益集中于 image-only、图文组合、OCR/小目标和长尾政策，并在固定 FPR 下成立。
- **证伪：** 普通安全 SFT+截层或 EfficientVLM/METR 改编达到相同前沿；政策反事实 loss 的增益在 text-only 条件仍存在；浅层特征在原像素干预下不依赖正确证据。任一成立则 G0 降级为工程压缩。
- **状态：** hypothesis；推荐作为 CVPR 主问题，安全投稿需叠加明确压缩绕过威胁。

## G0-A（与 G0 联合）：最坏压缩状态而非平均多预算训练

- **问题：** EPIC/ViCO 类平均或渐进多预算训练可能掩盖少数会造成 unsafe→safe 漏报的输入×patch×深度组合。安全模型是否应直接优化这一压缩状态尾部？
- **候选方法假设：** 定义压缩格 $z=(r,k,d,m)$，包含像素分辨率、patch 数、视觉深度与 mask。每个样本只回传 top-$q$ 或 CVaR 的高损失状态；unsafe 样本重点惩罚 harmful flip，safe 样本用独立校准约束 FPR。状态采样器只在训练期存在，部署仍为固定 shape。
- **反证：** Once-for-All/M3/EPIC 已有多预算共享训练，VisPCO 已优化预算配置；DRO/CVaR 也不是新优化原语。贡献只能来自**压缩格上的安全漏报尾部**、跨未见状态泛化和 G0 的交互，而非“使用 max loss”。
- **证伪：** 等量 hard-example 重采样、类别重加权或随机预算达到相同结果；最坏状态训练只提高 unsafe prior 并恶化固定 FPR；未知 mask/分辨率不泛化。
- **状态：** hypothesis；与 G0 形成一个方法，不单独投稿。

## G0-B（高风险高收益输入方案）：全局底图 + 稀疏高清证据残差

- **问题：** 纯 Top-K 早剪可能删除低显著度危险证据，纯 resize 又会抹去小字。能否在首个自注意力前用固定 token 数同时保留全局覆盖和少量高清细节？
- **候选方法假设：** 低分辨率全图形成不可删除的 global canvas；从高清 patch embedding 中只追加固定 $K$ 个 residual tiles。训练期由 full teacher 的政策反事实效应监督 tile，部署可用极小 patch scorer；位置编码沿用原坐标，不新增 memory/Q-former。
- **直接最近邻：** 混合尺度 tokenization、Dyna-ViT 的 pre-encoder saliency、QuietPrune 的 query-guided early pruning 与 FastVLM 的分辨率—token 联合优化均高度相邻。
- **必须证明的差异：** 在相同首层 token、selector 时延和真实输入像素读取成本下，覆盖式双尺度输入对 small/OCR/角落危险证据优于 QuietPrune、低清 resize、均匀网格及 saliency Top-K；安全监督而非单纯更高有效分辨率解释收益。
- **证伪：** cheap selector 成本吃掉视觉层收益；只需增大统一分辨率即可匹配；高分 tile 对无关 OCR/纹理过拟合；固定 shape 在实际 kernel 中无加速。
- **状态：** hypothesis；新颖性风险高于 G0，先作为第二阶段组件。

## G1（优先级 1）：学生可观察性约束的跨分辨率蒸馏

- **问题：** 教师可靠性是否不足以判断一个低预算训练目标是否可学习？高清教师正确，但低清已看不见决定性小字时，强 KL 可能鼓励语言猜测。
- **支持：** TBD §5 承认压缩信息损失；VTC-Bench 区分分辨率敏感样本；本地 XGuard 的 resize 与保留高清特征路径质量/时延不同。
- **反证与最近邻：** ViCO、EPIC、TBD 已做一致性/可靠蒸馏；LOREAL 的相关低分辨率蒸馏正文本轮无法访问。因此不能把高清→低清命名为新颖性。
- **可行方法假设：** 训练期人工/受控反事实标注 evidence-visible、ambiguous、erased。仅在可见且标签成立的样本强对齐关系/判别；证据缺失时监督“需要更多输入”或条件分布，而非复制高清自信。可使用现有词表标签，不加新 head。
- **难点：** 可见性不是教师置信度，不能用 full/pruned 错对自动当真值；自然图像的可观察性只能估计。
- **证伪：** 等数据/算力下 TBD+普通安全 SFT 已达相同前沿，或可见性分组不预测压缩错误，则淘汰主贡献。
- **状态：** hypothesis；不可观察导致的信息界限有逻辑依据，但其频率与可训练收益均未测量。

### G1-A：安全证据加权的线性可恢复性，而非全特征复制

- **直接最近邻：** SiT/FRD 已用仅训练时存在的非线性 RTSM，把 $K$ 枚非结构化压缩 token 恢复成 $N$ 枚 token，并逐 block 最小化教师—学生特征 MSE；EM-KD 已用 Hungarian matching 解决不等长视觉 token 对应，并蒸馏视觉词表语义与图文 affinity；OTPrune 已在选择阶段最小化 full/pruned token 分布差异；RESTORE 已校准压缩前后的位置与注意力失真。
- **不能声称：** “首次恢复剪枝 token”“首次不等长 token 对齐”“首次用训练期 decoder 且推理丢弃”“首次分布/关系对齐”均不成立。将学习型 RTSM 换成普通最小二乘，也不足以形成顶会贡献。
- **候选方法假设：** 给定第 $l$ 层完整教师 $T_l\in\mathbb{R}^{N\times D}$、压缩学生 $S_l\in\mathbb{R}^{K\times D}$ 与由 selector/merge 产生的对应矩阵 $A_l$，训练期求 ridge 恢复器
  $$R_l^*=\arg\min_R\lVert W_e\odot(T_l-RS_l)\rVert_F^2+\lambda\lVert R\rVert_F^2,$$
  其中 $W_e$ 只提高经像素干预验证的安全证据、OCR 和图文—政策关系位置权重。恢复器只产生训练 loss，部署时移除；学生仍用固定 $K$ 和原模型结构。
- **真正可能有价值的差异：** 不是重建全部背景，而是检验“少量 token 对安全充分子空间是否线性可恢复”，并把可恢复性作为预算/深度选择和蒸馏门控。还应对齐 evidence→text/policy affinity、unsafe margin 与原像素干预效应，分别消融普通 MSE、SiT 式学习 decoder、EM-KD 匹配和 OTPrune 分布目标。
- **关键界限：** 模型结构剪枝中的最小二乘通常校准同一输入下的通道/层输出；token 剪枝会删除随样本变化的空间观测。若危险小字只存在于被删 patch，固定线性映射无法从不存在的信息中恢复它。硬选择矩阵的伪逆往往只会把缺失位置补零；只有保留 token 已通过 attention/aggregation 收集相关信息时，线性恢复才可能成功。
- **证伪：** 安全加权恢复相对普通 feature KD/RTSM 没有独立收益；增益只来自更大训练量；恢复误差不预测 unsafe→safe flip；或必须保留训练 decoder 才有效。任一成立则作为训练诊断而非主贡献。
- **状态：** hypothesis；比普通高清→低清 KL 更接近可发表的机制问题，但需先用小规模线性探针验证。

## G2（优先级 2）：图文—政策关系的压缩前学习

- **问题：** 不新增推理 token，能否将复杂政策判断所需的关系编码进原生少量表示和首标签状态？
- **支持：** 原方案已有感知保持/政策绑定候选；Att-CoT 提供过早承诺相邻证据；SafeWatch/GuardReasoner-VL 说明政策推理的任务相关性。
- **反证：** ETC 已研究任务统计量，TBD 已做答案 margin，Evidence-RL 已用局部干预训练；“加关系 loss”容易只是组合。
- **方法假设：** 同图不同文本/政策、同文不同图的最小对照；训练期教师可用短推理，学生只产生 verdict。对齐经反事实验证的关系效应，而非事后 rationale 字面相似度。
- **验证：** 模态交换、否定/引用/教育语境、同物体不同动作；text-only/image-only 对照；测试集不得共享合成模板与背景。
- **证伪：** 普通 hard-example SFT 或更长在线推理即可解释全部收益；视觉依赖无改善；复杂类别仅靠文本先验，则降级。
- **状态：** hypothesis；不得声称无损将任意 CoT 计算压入一次前向。

## G3（优先级 3）：对安全决策干预效应进行压缩训练

- **问题：** 保持 verdict 不保证仍依赖正确证据；能否同时保持证据删除效应与无关背景不变性？
- **支持：** 本地双向干预计划与 label-first 中介问题。
- **反证：** Evidence-RL 的局部证据/非证据对照是直接先例；还需比较 ERASER/FRESH，不可称首次因果训练。
- **方法假设：** 在 full 与 compressed 两路上共享经验证的区域/span 干预，学习相关证据效应一致性；先在非 RL 的 SFT 上验证。
- **证伪：** 只有内部 mask 有效、原像素干预无效，或相同证据奖励在未压缩模型也带来同等收益且无压缩交互，论文应定位为普通 grounding。
- **状态：** hypothesis；与 G2 作为消融，不应同时另立复杂主线。

## G4（安全方向优先）：压缩训练能否扩大 Guard 绕过面

- **问题：** 平均蒸馏恢复后，攻击者是否能让危险证据在压缩/低分辨率路径中消失，而 full Guard 仍检出？
- **支持：** Security Pitfalls 证明压缩状态可引入专属脆弱性；OOD-VTP 的拒答改善说明目标定义会改变评价方向。
- **反证：** 已有 CAA/T-CAA；不能把其在 Guard 上迁移一次当成完整创新。
- **方法假设：** 训练期受约束的证据位置、尺度、OCR 对比度和图文关系扰动；以 Guard 漏报风险而非一般回答差异训练，同时保留良性 FPR 和 full-path 能力。
- **验证：** full/pruned×clean/perturbed 四格；针对已训练防御重新评测，含未知预算、压缩算子和政策；检查自动升级被诱发的拒绝服务式成本。
- **证伪：** 攻击只破坏可读性/改变真值，或 full 同样失败；收益来自始终判 unsafe/始终跑高清；则不成立。
- **状态：** hypothesis；可与 G1 共用训练数据和学生，安全四大投稿需独立威胁模型与防御证据。

## G5（增量备选）：按困难证据组设计预算课程

- **支持：** EPIC、ViCO、M3 已表明预算训练可行；DualSpeed 揭示完整/压缩行为失配。
- **剩余问题：** 将安全子群下限与多预算共享训练结合，能否减少预算间负迁移、教师错学和 full-path 遗忘？
- **反证：** 多预算 curriculum、可靠教师、group reweighting 都不是新原语。
- **验证/停止：** 同等算力对比固定预算、多预算、常规重加权；若只需重采样即可解决，作为实用增量而非首选顶会主线。
- **状态：** hypothesis；不把严重度加权当安全保证。

## G6（低优先）：训练识别不可压缩样本，按收益补充观测

- **支持：** 可见性边界与固定延迟约束；本地 resize 快但长尾风险未定。
- **反证：** VisionThink/ViR/ET-Prune 已有相关路由或动态预算。
- **剩余问题：** 在低 FPR、困难召回和补看成本共同约束下，训练出的升级动作是否优于 entropy 阈值？
- **验证/停止：** 先给固定预算 Pareto 曲线；再报告路由覆盖率、升级率、含双跑的 P99。若所有困难样本都双跑且尾时延无益，不作为主贡献。
- **状态：** hypothesis；训练/决策扩展，serving 调度仍最后考虑。

## 信息界限：不能训练恢复不存在的信息

若两幅图在给定压缩操作后得到完全相同的输入，文本与政策也相同，而真实标签相反，则任意只接收该输入的确定性 Guard 必须对二者作出同一决定，至少错一个；随机模型也无法保证同时正确。这是本项目的逻辑推导，非引用论文结果。它不证明真实数据通常如此；需用受控配对与人工可读性检查测量近似情形。

因此“最低时延、最高召回”应作为约束下的 Pareto 问题。缺失信息需要更多观测或接受错误/升级，不能靠蒸馏宣传消除。
