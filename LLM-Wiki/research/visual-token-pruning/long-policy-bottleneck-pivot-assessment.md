---
id: long-policy-bottleneck-pivot-assessment
type: synthesis
title: "长政策瓶颈下的路线二转向评估"
tags: [research, writing, visual-token-pruning, multimodal-safety, efficient-inference, vision-language-model]
project_id: visual-token-pruning
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-singguard-team-2026-singguard, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-chen-2025-safewatch]
status: deprecated
created: 2026-09-22
updated: 2026-09-23
---

# 长政策瓶颈下的路线二转向评估

> **历史转向评估（2026-09-22）。** 用户已决定以模板短政策为背景条件，转向文本政策指导的视觉 Token 剪枝；当前方案见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|新版课题方案]]。下文保留当时的长政策瓶颈和备选路线分析。

## 决策结论

推荐将主线从“只剪视觉 token”转为：**长政策的离线编译/条款级检索 + 视觉 patch 与政策条款协同选择 + 风险约束回退**。这不是把视觉工作泛化成普通文本压缩，而是针对政策自适应图像 Guard 的实际端到端瓶颈，研究政策语义如何决定视觉证据预算。

三条候选路线的排序为：

1. **路线 2 的结构化版本：视觉—政策联合预算，作为主线。**
2. **路线 3 作为次要效果与机制验证。** 只在改善 policy-shift、worst-group 或虚假背景鲁棒性时有论文价值，不以普通 accuracy 提升作唯一主张。
3. **路线 1 只作受控实验层。** 短政策是真实部署子场景时可以报告，但不能通过筛数据规避长政策瓶颈。

## 失败假设与成本上限

用户报告的当前条件是：政策文本 token 数通常超过视觉 token 的四倍；Dyna-ViT 式 ViT 前 90% 视觉剪枝只得到 1.14× 端到端加速且分类精度严重下降。该数字尚未链接到完整原始 profiler，因此在 Wiki 中记为**用户报告的场景约束**，不是 reproduced 结果。

若将可被 90% 剪枝影响的净运行时间占比记为 $p$，忽略额外 selector 开销时，Amdahl 关系为：

$$
1.14=\frac{1}{(1-p)+0.1p},
\qquad p\approx 0.136.
$$

也就是说，测得的**有效可移除视觉路径**只占约 13.6%；将其理想地全部消除，对应约 $1/(1-p)\approx1.16\times$ 的上限，与用户估计约 1.15× 一致。若 1.14× 中包含 selector/gather 开销，则 $p$ 不是原始 ViT 份额的精确估计，但“当前实现的净可利用空间很小”仍成立。

这个结果否定的是“视觉剪枝作为主要加速来源”，不是视觉选择本身。视觉侧仍可作为政策条款检索、证据定位和鲁棒性的关键机制；只是必须同时缩短主导成本的政策输入，或改变 Guard 架构。

## 三条路线评估

| 候选 | 科学问题是否真实 | 创新风险 | CVPR 适配 | 结论 |
|---|---|---|---|---|
| 只选短政策数据 | 仅当部署本来就是短策略/class prompt 时真实 | 高：容易被质疑挑选有利设置、外推性弱 | 中低 | 不作主线；保留为长度分层的一个 regime |
| 联合压缩视觉与政策文本 | 直接命中当前主导瓶颈 | 中：MADTP 已是联合图文 token 剪枝先例，不能声称首次 | 高：若视觉—政策协同机制、图像 Guard 和视觉分析占主导 | 推荐，但应做条款级政策编译而非任意 BPE Top-k |
| 用视觉剪枝提升分类精度 | 可能存在去背景/正则化收益 | 高：可能只是校准、类别不平衡或数据增强效应 | 中：需证明视觉机制与 policy-shift/OOD 鲁棒性 | 次要主张；先用简单校准与重加权反证 |

## 为什么联合路线仍属于 CVPR

MADTP 已在 CVPR 2024 对视觉和语言分支同时做动态 token 剪枝，直接证明联合多模态压缩属于会议范围；但它使用 CLIP/BLIP 式双分支、普通短文本，并且附录显示语言分支在其任务中成本低且更敏感。当前场景正好反转：政策 token 主导 decoder-only Guard 的输入成本。

SafeEditBench/SafeGuard-VL 已在 CVPR 2026 把运行时政策变化、同图近邻 safe/unsafe 对和跨政策泛化作为视觉安全问题。PolicyShiftBench 进一步公开 2,000 个实例、265 张图和 28 个政策变体，并构造大量同图 pass/block 翻转。因此，潜在贡献不是“联合图文剪枝”，而是：

> 在长自然语言政策主导成本、且错误删除规则会造成安全漏报的图像 Guard 中，如何把政策编译为可审计条款表示，并与视觉证据联合分配预算。

## 推荐方法：Policy Compiler + Evidence Co-Selector

### 1. 离线政策编译

将完整政策解析为结构化条款：风险类别、触发条件、允许项、否定、例外、作用域和优先级。每个条款产生短文本、embedding 或少量 latent/gist token。完整政策作为教师输入和审计原件保留，不能用不可解释 soft prompt 替代全部合规记录。

固定或重复政策可缓存编译结果。必须分别报告新政策首次出现的 cold path 和重复政策的 warm path。普通 prefix/KV cache 是强基线，但不是完整解法：它可以避免重复编码，却仍保留长 policy KV，后续图像/输出 token 仍需注意这些位置。

### 2. 高召回条款检索

用低分辨率图像、patch projection 或廉价视觉概念预测与条款 embedding 匹配，选择候选政策子集。选择目标不是最小 Top-k，而是覆盖所有可能违规条款；保留全局摘要、否定/例外和不确定条款，必要时退回完整政策。

### 3. 政策—视觉协同选择

候选条款指导 pre-ViT patch 选择；视觉证据反过来修正条款集合，形成二部覆盖而非两个独立 Top-k。训练使用完整政策+完整视觉教师、同图异策边界对、预算一致性和 unsafe-to-safe flip 惩罚。

### 4. 风险约束动态回退

对政策新颖度高、OCR、小目标、多区域关系或分类 margin 低的样本扩大两侧预算，最高退回 full policy + full vision。优化目标是 fixed benign FPR 下 unsafe recall 的非劣，而不是平均 token 数最小。

## 数据策略：不从零造完整数据集

LlavaGuard 仍可作为固定分类体系基线，但不是唯一可用资源：

- SafeEditBench：五种政策、62 组近邻 safe/unsafe 图像对，适合外部跨政策和局部证据评测；
- PolicyShiftBench：2,000 个评测实例、265 张图、28 个政策变体，并有公开训练语料，适合同图异策与政策翻转；
- SingGuard：已有运行时动态规则与简短/详细政策形式，可作为相邻多模态 Guard 证据。

这些资源未必直接满足短政策训练规模要求。更合理的补充不是重新造全部图像，而是在相同政策语义下建立**长度阶梯**：完整原文、相关条款集合、人工/规则校验的等价短述、类别名。按图像和政策家族切分，验证压缩保持标签与例外，而不是只让文本变短。

## “剪枝提升精度”必须先过的反证

2B 模型难以平衡 harmful/benign recall，优先怀疑阈值、类别先验和训练损失，而不是默认视觉冗余造成。建立视觉剪枝精度主张前，至少比较：

- 固定 benign FPR 的阈值校准、温度缩放和分组校准；
- class-balanced/focal loss、logit adjustment、困难负例采样；
- full-token 模型上的随机 patch dropout、低分辨率和背景扰动；
- 相同训练数据与算力的 full-token SFT/KD；
- policy-blind 与 policy-conditioned 剪枝。

只有当视觉选择在这些对照后仍改善同图政策翻转、worst-policy、OOD 背景或小证据子群，才能写成“证据瓶颈减少虚假相关”。普通平均 accuracy 上升更适合作为附带结果。

## 更激进但可能更合适的替代架构

若 Guard 只输出短标签/类别，2B 自回归 MLLM 本身可能是错误计算载体。可把下列方案列为强基线，甚至在联合剪枝失败时升为主线：

1. 小型 policy encoder 将政策编译并缓存；
2. 视觉 encoder 输出可变预算证据 token；
3. 浅层 cross-attention/classification head 直接判定；
4. 仅对低置信或需解释样本调用完整生成式 Guard。

该架构优化的是“摊销后的政策自适应 Guard”，潜在收益大于在长 decoder prompt 中删少量 token；代价是必须证明未见政策和复杂例外仍能泛化。

## 关键实验与投稿门槛

### 成本矩阵

在至少两个 backbone 上做政策长度 × 图像分辨率的二维网格，分别报告 visual encoder、policy compiler、retrieval/co-selection、LLM prefill、verdict decode 的 P50/P95、吞吐、显存和冷/热缓存路径。

### 质量指标

核心指标为 unsafe recall at fixed benign FPR、worst-policy/worst-category recall、Policy Shift Score、同图异策一致性、unsafe-to-safe flip、条款召回和 OCR/小目标子群；平均 accuracy 只作辅助。

### 强基线

full tokens、Dyna-ViT/QuietPrune 式纯视觉剪枝、只做政策 KV cache、Gist/soft prompt、抽取式条款选择、视觉与文本独立剪枝、联合 co-selector、较小分辨率/骨干、非生成式双塔 Guard。

### Go / No-Go

- **Go：** 在真实长政策分布上，联合方案在固定安全质量下明显超过 pure-visual 的约 1.15× 上限；协同选择优于两侧独立压缩；未见政策和政策翻转不崩溃。
- **降级为次要结果：** 视觉剪枝只改善平均 accuracy，校准/重加权可复制全部收益。
- **No-Go：** 简单政策摘要、KV cache 或更小模型达到相同前沿；联合选择只在短政策/低分辨率上有效；高危条款召回随压缩不可接受地下降。

## Claim—evidence—citation map

| 论文论点 | 当前证据 | 写作边界 |
|---|---|---|
| 纯视觉加速在目标 workload 中有硬上限 | 用户报告的 token 分布、1.14× 复现和 Amdahl 推导 | 需补原始 profiler；不能写成普遍 VLM 结论 |
| 联合图文 token 工作符合 CVPR 范围 | MADTP, CVPR 2024 | 反证首次联合剪枝；架构与长政策 Guard 不同 |
| 政策自适应图像 Guard 有公开评测基础 | SafeEditBench、PolicyShiftBench | 不等于已有短政策大规模训练集；需统计长度和许可 |
| 政策可被编译/缓存 | Gist Tokens | 普通提示质量不能替代安全条款保持；墙钟收益需实测 |
| 视觉剪枝可能提升鲁棒性 | 当前仅为 hypothesis | 必须先排除校准、类别不平衡和训练正则化解释 |
