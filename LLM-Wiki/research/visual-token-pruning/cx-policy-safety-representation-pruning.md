---
id: cx-policy-safety-representation-pruning
type: synthesis
title: "Cx 的安全表征分支：政策条件证据保留与预算规划的关系"
tags: [research, visual-token-pruning, multimodal-safety, safety-evaluation, visual-evidence, adaptive-budget]
project_id: visual-token-pruning
sources: [paper-zheng-2025-safety-attention-heads, paper-wang-2025-sasa, paper-zou-2025-shiftdc, paper-chen-2025-safeptr, paper-wang-2026-sap, paper-chen-2025-safewatch, paper-arxiv-2609-27988, paper-arxiv-2609-34861, code-hf-2026-qwen3-vl-modeling]
status: draft
created: 2026-10-10
updated: 2026-10-10
---

# Cx 的安全表征分支

## 场景与结论

用户报告新的自适应预算实验正在运行；本轮没有接入训练环境或获得新增指标。当前主线仍见 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|Cx 双重要性预算方案]]。本页讨论另一个研究假设：用特定政策下危险/安全样本的中间表征，寻找审核需要保留的视觉证据，再指导选择。

沿用模板短政策、运行时政策变化、标签映射和全局＋至多一个局部框的场景；短政策改写是背景。数据构造沿用 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|现有场景记录]]。不指定数据规模、使用范围、执行步骤、门控、失败处理或训练日程。

**综合判断：**安全表征方向更有机会形成安全判别任务特有的贡献，但风险也更高；现有时延—收益规划与当前分辨率动作的对应关系更直接。较合理的组合是由政策条件证据分数解释“看哪里/保留什么”，由 Cx 收益与成本决定“看多清楚/给多少预算”。新增分类收益、解释忠实性和时延均未验证，不据此替换正在运行的方案。

## 已有尝试及其与本课题的距离

| 方法与证据入口 | 选择/分析信号及位置 | 已验证任务 | 对本课题的作用与限制 |
|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-zheng-safety-attention-heads.md\|SAHs]] | 安全/危险校准样本，语言层注意力头线性探针，首次生成时最后上下文位置 | 恶意输入检测、拒答、头消融 | 内部信号可用的先例；未验证早期视觉 token 的政策贡献。表5视觉探针在 VLGuard 为50% |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-wang-sasa.md\|SASA]] | 危险/良性任务的头消融；语言安全层与融合层；输出 logits 探针 | 安全检测及生成防御 | 安全表征与充分语义可能在不同层；文中“早”相对语言主干，推理仍利用后层 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-zou-shiftdc.md\|ShiftDC]] | 语言最后 token 的均值差；图文/图像描述对照偏移 | 生成安全、分类、良性误报 | 与正反样本提取方向接近；方向不是空间归因，额外两次前向不适合直接作便宜 selector |
| [[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safeptr.md\|SafePTR]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md\|SAP]] | 语言层安全参考、视觉/指令 token；恢复背景与注意力干预 | 被保护生成模型的 jailbreak/拒答 | 已有安全相关剪枝；检测 Guard 需要危险证据，不能直接照搬其抑制目标 |
| [[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md\|SafeWatch]] | 政策 chunk→视频 token cross-attention、特征/KV 剪枝 | 可定制政策视频审核与解释 | 直接的政策 Guard 剪枝先例；没有证明早期视觉判别方向或空间解释因果忠实性 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-bond-task-induced-metrics.md\|Task-Induced Metrics]] | 离线 Jacobian 敏感性，训练早期特征重要性 head | ViT 表征、深度等视觉任务 | 离线昂贵信号→在线便宜选择器的先例；不是安全任务，低分辨率实例还有减速 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-kang-when-text-matters.md\|When Text Matters]] | attention 对照区域遮挡的 NLL 影响 | 通用图文任务、Qwen3-VL | 文字条件与真实区域价值需要核对；部分早 decoder attention 弱于中层 |

本轮新增三篇为 skimmed/source-checked，复用已有笔记的阅读等级；没有把摘要筛查当精读。本轮没有找到同时验证“运行时可变安全政策＋早期视觉表征＋独立 Guard＋低时延证据剪枝”的完全相同方案。这是有限检索结果，不是首次性证明。

## 正反激活对照能回答什么

固定政策 $P$，将早期特征汇总为 $h^\ell(I)$，均值差基线可以写成：

$$
d_P^\ell=\mathbb{E}[h^\ell(I)\mid y_P=\mathrm{Unsafe}]-\mathbb{E}[h^\ell(I)\mid y_P=\mathrm{Safe}].
$$

它回答“这层是否存在与该政策标签相关的方向”。线性探针衡量信息能否被简单读出。二者都不能直接回答“哪个 token 删掉会导致漏报”；可分类性、空间位置和实际决策贡献是不同对象。激活范数大、注意力高、梯度绝对值大，也不自动等于该政策的必要证据。

危险与安全图片还可能同时在数据来源、文字样式、背景、类别比例上不同，探针可能捕捉这些捷径。现有数据的同图政策翻转能固定像素，帮助区分固定物体先验与政策判别；有害/良性内容相近的对照能帮助解释方向是否仅识别物体。这里说明对照的含义，不规定校准集范围或数量。

完整原图训练的探针与低分辨率预览探针的可观察信息不同。前者可以证明原图有信息，不能证明 Cx 的便宜预览能识别该信息。小目标在预览中不可见时，换评分或增加离线监督无法从已消失的像素中恢复它。

## Qwen3-VL 的位置边界

核对 [Transformers 官方实现](https://github.com/huggingface/transformers/blob/main/src/transformers/models/qwen3_vl/modeling_qwen3_vl.py) 的 `Qwen3VLVisionModel.forward`：原生视觉分支接收图像 patch 与网格，不接收政策；DeepStack 视觉特征在语言分支注入。未核验用户本地改动，本次读取 main，未固定 revision。

因此，在相同图像预处理与确定性推理下，**同一图像的原生早期 ViT 激活不会因政策翻转而变化**。这不妨碍用不同政策训练出不同探针权重，但“特定政策”必须体现在外接读出函数中，不能写成视觉塔已经看到了政策。

可用的形式是：

$$
q_\phi(y\mid Z^\ell(I),e(P)),\qquad
s_j=f_\phi(z_j^\ell,e(P),h_{global},pos_j).
$$

$e(P)$ 应包含禁止、允许和例外语义；类别映射应恢复语义标签，避免把洗混后的输出槽位当安全概念。可用政策条件 MLP 或小型 cross-attention 读出，结构大小不在本页规定。有限政策族的独立探针是诊断基线，不保证组合政策或未见政策泛化。

两种部署位置有不同成本：复用原 Cx 预览时，内部特征主要作为离线监督；直接读取原生早期 ViT 时，需支付该前缀的完整图像计算，后续 token 剪枝才可能节省后续层。后者不能先计算候选局部的 ViT 特征，再把同一分数宣称为免成本的裁图前决策。在线读完整 LLM 激活或梯度再做 pre-ViT 决策会付出已经完成的计算，尤其不适合当前短输出 Guard。

Qwen3-VL 还通过 DeepStack 传递多个视觉层的特征。token 级干预需要说明改变哪条路径及如何维持网格对应；单个层的激活被替换，不等于所有视觉旁路里的同一证据都已删除。

## 更适合本场景的解释目标：判别证据保留

以下为**项目方法假设**，不是上述论文已验证的安全保证。解释对象宜是“删除这一位置，会怎样改变当前政策下的正确判别”。它应覆盖危险依据、允许依据、例外及必要语境。

**假设例子：**政策为“禁止对人开枪，允许陈列枪械”。枪的局部纹理可能同时出现在两类图像中；仅保留最像危险原型的区域会误判陈列图。人物、动作和陈列环境同样是判别证据。换为“所有枪械均禁止”时，重点又会改变。该例子解释方法，不声称当前数据包含对应规则。

### 离线贡献信号与便宜预测

保持当前审核代价的组成：

$$
C=-\log p(y\mid I,P)+\lambda_{label}\,\mathbf{1}[\hat y\ne y].
$$

对指定层的视觉 token 或区域做明确的替换干预，代价差为：

这里 $C(Z^\ell,P,y)$ 表示在该层设定特征后继续执行相应 Guard 路径得到的代价，其他上下文与干预接口保持明确；不是仅凭探针输出计算最终 Guard 效果。

$$
\Delta C_S=C(Z^\ell_{S\leftarrow Z^0},P,y)-C(Z^\ell,P,y).
$$

正值表示该干预损害正确判别，负值表示该位置在这次干预下可能干扰判别。$Z^0$ 是注明语义的替换参考；置零、背景替换、直接删 token 会改变不同东西，不能混用。它是给定模型和干预的贡献，不是普遍区域真值。

用于离线近似的梯度信号可以是：

$$
\widetilde{\Delta C}_j=
\left\langle\nabla_{z_j}\mathcal L_{NLL},\ z_j^0-z_j\right\rangle.
$$

这是 NLL 的一阶变化，保留方向；标签不一致项不连续，不直接求梯度，只有实际前向的 $\Delta C$ 才包含它。梯度不保证大幅删除时仍准确，也不把 token 的独立分数自动变成联合贡献。激活/attention 可作读出输入或对照，最终解释仍与分类贡献核对。完整教师自身错判时，其预测方向也不是可靠真值；校准标签监督与教师错误要在解释中区分。

这种设计与当前路线收益使用同一个判别目标。差别在监督分辨率：原路线收益告诉模型“哪种全局/局部输入整体更好”，内部贡献信号帮助解释“哪些证据影响这条路线”。仅改成 gradient×activation 属于通用归因，不能单独声称安全创新。

### 如何接回当前 Cx

- **选择位置：**将政策条件证据分数汇聚为候选单框的特征/得分，同时读全局语境；最终仍输出至多一个框。框内分数之和可作输入，但不是经过验证的条件局部收益。
- **分配清晰度：**Cx 全局升级收益与给定全局的局部增量收益继续决定实际分辨率；收益仅含 NLL 和标签不一致，成本保持显式。
- **解释：**展示当前条款、空间证据、所选框及预计收益的关系。高亮图本身没有证明必要性；实际删除/替换后判别变化提供更强的忠实性证据。

单框无法覆盖分散证据、细长结构或低清全局中失去的语境时，证据分数不能突破动作空间上限。该方向与自适应预算互补，不因此引入多个裁图。直接选择不连续原生 token 是另一压缩动作，需要单独说明位置、merge 与 DeepStack 接口，不能默认为当前 Cx 裁图结构已经支持。

## 两条方向的比较

| 维度 | Cx 时延—收益规划 | 政策条件安全表征/证据选择 |
|---|---|---|
| 主问题 | 如何用成本换取判别质量、何时需要清晰度 | 当前政策需要什么证据、怎样避免剪掉依据 |
| 与当前模块适配 | 直接对应全局/单局部分辨率配置 | 可接选择器与离线监督；原生 ViT 路径另有接口成本 |
| 最可能的优势 | 困难图像更清晰、可控制逐样本成本 | 相同资源下政策响应、稀少危险细节、允许/例外依据及解释忠实性 |
| 主要风险 | 平均收益掩盖困难子群；预览不充分 | 早层语义不充分、类均值捷径、归因不忠实、读出成本抵消节省 |
| 安全专属性 | 已用政策标签、NLL和翻转样本，已有任务条件 | 必须证实政策改变证据需求；使用激活本身不产生专属性 |
| 当前证据 | 用户新实验运行中，结果未提供 | 近邻支持技术组件；本场景效果尚无证据 |

**判断：**若问“哪个更容易先得到可用的质量—时延改善”，更看好现有 Cx；若问“哪个更有机会说明安全审核为何需要专门剪枝”，更看好政策条件证据保留。后者优势来自运行时规范与视觉事实的关系、同时保留禁止和允许依据，而非宣称安全标签天然对应一个通用向量。

支持独有优势的证据维度包括：匹配实际预算/时延的漏报与误报、固定误报水平的危险召回、同图政策翻转的正确响应、允许/例外样本、风险子群，以及解释与干预影响的一致性。热图更漂亮、探针准确率高或用了更多预算，均不足以单独支持该结论。这些是判断维度，不是新的执行安排或门控阈值。

## 候选缺口与未决问题

SAHs/SASA/ShiftDC 支持内部安全信息分析，SafeWatch 提供政策条件剪枝的反例，SafePTR/SAP 提供安全相关 token 干预的反例。因此“首次安全感知剪枝”“首次内部激活指导选择”“首次政策剪枝”均不能由本轮材料支持。更具体的候选问题是：**把可变政策下的判别依据离线转为便宜的空间选择信号，是否能在同成本下同时维持危险检出与允许项判别，并提供忠实解释？**目前只列为候选研究问题，未新增正式 motivation。

未决项：Qwen3-VL 已训练 Guard 哪个早层能读出足够信息；完整图与预览的信号差距；读出是否依赖政策；单框覆盖上限；离线归因向低预算路由的迁移；完整在线读出开销。没有新增实验数字或复现结论。

检索范围与阅读边界见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md]]；方法比较见 [[LLM-Wiki/research/visual-token-pruning/comparison.md]]。
