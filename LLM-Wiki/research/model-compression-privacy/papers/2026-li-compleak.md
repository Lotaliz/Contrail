---
id: paper-note-li-2026-compleak
type: paper-note
title: "CompLeak: Deep Learning Model Compression Exacerbates Privacy Leakage"
authors: ["Na Li", "Yansong Gao", "Hongsheng Hu", "Boyu Kuang", "Anmin Fu"]
year: 2026
venue: "USENIX Security 2026"
source_id: paper-li-2026-compleak
project: model-compression-privacy
reading_level: deep-read
verification: source-checked
relevance: standalone
priority: medium
tags: [paper-note, research, membership-inference, model-compression, unstructured-pruning, quantization]
status: active
related: [model-compression-privacy]
created: 2026-09-15
updated: 2026-09-15
---

# CompLeak: Deep Learning Model Compression Exacerbates Privacy Leakage

## 书目信息

- 作者：Na Li、Yansong Gao、Hongsheng Hu、Boyu Kuang、Anmin Fu。
- 会议：35th USENIX Security Symposium，2026，pp. 6545–6564。
- 官方页面：[USENIX Security 2026](https://www.usenix.org/conference/usenixsecurity26/presentation/li-na)。
- 原始论文：[[LLM-Wiki/raw/papers/2026-li-compleak.pdf|USENIX 正式版 PDF]]。
- 开放科学：官方记录为 Distinguished Artifact Award；USENIX Security 2026 Artifact Evaluation 页面标记 Artifact Available、Functional、Results Reproduced。论文笔记本身未执行本地复现，因此 verification 仍为 `source-checked`。

## 一句话结论

论文真正证明的并不是“一个压缩模型天然比原模型更泄露”，而是：**压缩使同一训练过程产生多个相互关联、但对成员与非成员反应不同的模型视图；攻击者联合查询原模型与压缩模型或多个压缩版本时，这些差分视图会成为额外的成员推断信号。**（§1、§4–§6）

## 研究问题与场景

### 场景

模型提供方为了端侧、移动端和 IoT 部署，发布同一模型的全精度版以及不同压缩程度的剪枝、量化或权重聚类版本。攻击者希望判断目标样本是否属于原模型的训练集。例如，对医学模型做成员推断，可能暴露某人是否参与某项临床试验。（§1.1，pp. 6545–6546）

### 核心研究问题

作者明确提出：**随着攻击者能访问的压缩模型版本增加，模型压缩是否加剧隐私泄露；若会，加剧到什么程度？**（§1.1，p. 6546）

形式上，给定目标样本 $x$ 和受害模型 $M$，成员推断攻击学习：

$$
A(x,M)\rightarrow\{0,1\},
$$

其中 1 表示 $x$ 属于训练集，0 表示不属于。（§2.2，p. 6548）

### 三档攻击场景

| 变体 | 攻击者可访问模型 | 要回答的问题 | 新方法程度 |
|---|---|---|---|
| CompLeakNR（No Reference） | 原模型或某一个压缩模型 | 单独看每个模型时，压缩模型的成员泄露是否更强？ | 复用 6 类已有 MIA，主要作为基线 |
| CompLeakSR（Single Reference） | 原模型 + 一个配对压缩模型 | 压缩操作引起的输出变化是否对成员/非成员不同？ | 新的成对 posterior 元数据构造 |
| CompLeakMR（Multiple References） | 多个压缩模型；设置 1 还可访问原模型，设置 2 不可访问 | 跨压缩程度、跨压缩操作的互补泄露能否进一步放大攻击？ | 联合 posterior/元 posterior 与跨版本 loss 轨迹 |

图 1 给出三种场景的关系；§3 和 §6.1 进一步定义攻击者知识。（pp. 6546、6549、6554）

## 威胁模型

### 攻击者知识

- 黑盒访问受害模型的完整 posterior probability distribution；CompLeakSR 访问原模型和一个压缩版，CompLeakMR 访问多个压缩版，较强设置还访问原模型。
- 拥有与受害训练集同分布、但样本不重叠的影子数据集 $D_s$。
- 知道受害模型架构、压缩配置以及待审计样本的真实标签。
- 可训练与受害模型相同架构、相同压缩设置的影子原模型和影子压缩模型。（§3，p. 6549）

### 目标与边界

目标仅为典型**分类任务**上的样本级成员推断。论文不声称直接恢复训练样本，也不覆盖只返回 hard label 的 API、未知架构/压缩配置、分布不匹配的影子数据或查询受限场景。

## 方法

### 1. CompLeakNR：建立单模型基线

作者把只利用一个目标模型信息的现有攻击统称 CompLeakNR，包括三类方法：（§4.1，p. 6549）

1. **训练式 MIA**：
   - Shokri 等：以 posterior 作为元特征；
   - Nasr 等：posterior 与真实标签拼接；
   - SAMIA：面向单个剪枝模型，把 posterior、sensitivity、真实标签输入 Transformer 元分类器。
2. **阈值式 MIA**：基于 entropy loss 或 modified entropy 设阈值，无需训练元分类器。
3. **RMIA**：基于目标样本与随机总体样本的成对似然比检验。

这一步不是创新攻击，而是刻画每个版本单独暴露多少隐私，并为 SR/MR 提供对照。

### 2. CompLeakSR：利用压缩前后的差分视图

#### 设计观察

同一样本在原模型和压缩模型上的 posterior 差异，对成员通常比对非成员更明显。作者用 KL divergence 可视化这一现象；即使压缩后单模型的 MIA 变弱，压缩造成的**变化量**仍包含成员信号。（图 2、§5.1，pp. 6547、6551）

#### 攻击流程

1. 将影子数据 $D_s$ 划分为不相交的影子训练集与影子测试集。
2. 训练影子原模型 $M_o^s$，再按目标配置压缩为影子模型 $M_c^s$。
3. 对每个影子样本查询两模型，获得 posterior $P_o^s$ 与 $P_c^s$。
4. 按 $P_o^s$ 的概率降序排列类别，并对 $P_c^s$ 使用相同排列，得到对齐后的 posterior；构造两种主要元特征：
   - $\tilde P_o^s \Vert \tilde P_c^s$；
   - $\tilde P_o^s \Vert \tilde P_c^s \Vert y$，其中 $y$ 为真实标签 one-hot。
5. 以影子训练样本为 member、影子测试样本为 non-member，训练二分类元分类器；在线阶段对受害原模型与压缩模型构造相同特征并预测成员身份。（图 3、§5.2，pp. 6551–6552）

附录 B 还测试了直接拼接和两 posterior 的 $L_2$ 距离；完整排序后的 posterior 拼接整体更强，说明攻击需要细粒度的全分布变化，而非单一距离。（p. 6562）

### 3. CompLeakMR：聚合多个压缩版本

作者发现，直接把多个压缩模型的 posterior 像 SR 一样简单拼接并不充分，因为不同压缩版本之间的 posterior 变化很细微。因此 MR 提取两类更稳定的跨版本信号。（§6.2，pp. 6554–6555）

#### Posterior concatenation

- **Adversary 1（可访问原模型）**：先为每个压缩版本训练一个 CompLeakSR 元分类器；对同一样本收集这些 SR 元分类器输出的“成员 posterior”，再按版本拼接。
- **Adversary 2（不可访问原模型）**：无法训练 SR 对，因此直接拼接各压缩模型对任务类别的 posterior。

#### Loss concatenation

对每个压缩版本 $M_{c_i}$，利用真实标签计算交叉熵：

$$
L_i=-\sum_{k=1}^{C}y_k\log p_k^{(i)},
$$

再按压缩程度排列并拼接 $L_1\Vert L_2\Vert\cdots\Vert L_n$。作者的观察是：随着剪枝率增加，成员损失总体上升，而非成员损失更易波动，方向和幅度不同（图 8，p. 6555）。

#### 最终分类

把 posterior concatenation 与 loss concatenation 堆叠，训练 MLP 成员分类器。图 7 的 t-SNE 和附录表 20 显示 posterior 是主要贡献项，loss 单独较弱，但二者结合最好。（图 6–8、表 20，pp. 6554–6555、6564）

## 实验设计与每组实验的目的

### 基础实验矩阵

| 维度 | 设置 |
|---|---|
| 图像数据与模型 | CIFAR-10/ResNet18、CIFAR-100/ResNet50、Mini-ImageNet/VGG16、Tiny-ImageNet/MobileNetV2 |
| 文本分类边界案例 | SST-5 上微调 BERT-base 与 GPT-2，30 epochs |
| 剪枝 | NNI 的 L1 非结构化剪枝；通常 60%、70%、80%、90%，Tiny-ImageNet 为 40%–70%；遵循 train–prune–finetune |
| 量化 | 经典模型使用 PyTorch Mobile int8 QAT；BERT/GPT-2 使用无需再训练的 int8 dynamic post-training quantization |
| 权重聚类 | TF-Lite/PyTorch，逐层 K-means；典型 centroid 数 4、8、16 |
| MIA 对照 | Shokri、Nasr、entropy、modified entropy、SAMIA、RMIA |
| 元分类器 | LR、DT、MLP、RF；正文主要报告最弱 LR 与最强 RF，CompLeakMR 使用 MLP |
| 指标 | TPR@0.1% FPR、balanced accuracy、AUC |
| 效用控制 | 报告压缩前后的训练/测试准确率；原模型训练采用 L2 正则与 early stopping |

来源定位：§4.2 与表 1（pp. 6549–6550）、§7 与表 9/图 9（pp. 6556–6557、6564）、附录 A（p. 6562）。正式版摘要的覆盖是 6 种模型架构、5 个图像/文本数据集；早期 arXiv 摘要中的 7/6 口径不用于本笔记。

### 实验—目的—结果

| 实验 | 目的 | 关键结果 |
|---|---|---|
| CompLeakNR 逐版本攻击（表 2–4、11–15） | 检查“单个压缩模型本身是否更泄露” | 轻度剪枝、int8 QAT、较多聚类中心与原模型相近；高度剪枝或少聚类中心通常更不易受 MIA。故单版本证据不支持标题的无条件读法。 |
| CompLeakSR（表 2–4） | 验证压缩前后 posterior 差分能否揭示额外成员信息 | Mini-ImageNet/VGG16 的 90% 剪枝下，最佳单模型攻击 TPR@0.1% FPR、balanced accuracy、AUC 分别为 2.3%、64.6%、70.1%；SR 提升到 25.5%、79.9%、88.6%。int8 QAT 上 SR 的 AUC 达 98.3%、balanced accuracy 达 91.1%。 |
| CompLeakMR，Adversary 1（表 6） | 检验多压缩版本是否继续叠加互补泄露 | 4 个剪枝模型联合：61.3% TPR@0.1% FPR、94.8% balanced accuracy、98.9% AUC；联合三类压缩共 8 个版本：95.7%、98.8%、99.9%。表 6 为 5 次重复的均值。 |
| CompLeakMR，Adversary 2（表 7） | 去掉原模型访问，测试更现实的多压缩版本场景 | 三类压缩联合相对最佳单压缩 SAMIA 提升 9.7 pp balanced accuracy、14.2 pp AUC，达到 71.4%/80.6%；但 TPR@0.1% FPR 仅 8.8%，明显弱于 Adversary 1。 |
| 压缩模型数量消融（表 8） | 验证增强是否随可访问版本数单调增加 | 剪枝版本从 1 个增至 4 个时，TPR 从 40.2% 升至 61.3%，balanced accuracy 从 85.8% 升至 94.8%，AUC 从 93.9% 升至 98.9%。 |
| Compression vs. Duplication（表 17） | 排除“任何多个近似模型都能靠集成增强攻击”的解释 | 不同超参数重复训练的参考模型也会增强 MIA，但明显弱于压缩版本：MR 的 balanced accuracy/AUC 为 73.1%/83.0%，多剪枝版本为 94.8%/98.9%。 |
| 易受攻击样本与 KNN-Shapley（图 4–5） | 分析额外成功攻击落在哪些样本 | 从原模型攻击失败转为 SR 成功的样本大多是 member；这些易泄露成员在 KNN-Shapley 下相对更“重要”。这是相关性分析，不等同于敏感属性或因果价值。 |
| 微调数据比例（表 5） | 分离压缩后再训练使用哪些数据的影响 | 仅用原训练集子集恢复压缩模型时，被用于微调的 $D_f$ 比未使用的 $D_{nf}$ 更易泄露；比例越小，二者差距越明显。 |
| DP-SGD（表 16） | 测试标准隐私防御能否压低 CompLeak | 噪声增大后所有攻击下降，但 SR 仍强于 NR；文中给出的隐私预算约为 $\epsilon=707.15$ 与 $32.92$（$\delta=10^{-5}$），形式保证很弱，不能视为严格 DP 防御已充分评估。 |
| BERT/GPT-2 + SST-5（表 9、图 9） | 测试中等规模基础模型的分类微调边界 | 层剪枝下 SR 仍常最强；无再训练的动态 PTQ 会降低所有 MIA，尤其 BERT 成员准确率明显下降。这支持“再训练与输出差分”比“压缩”二字本身更关键。 |
| 过拟合、数据集与组件消融（表 18–20） | 检查风险来源与适用条件 | 过拟合越强，攻击通常越强；作者推测复杂数据集带来更大的成员/非成员压缩差分；MR 中 posterior 是主信号，loss 提供增益。 |

## 主要结论

### 作者主张

1. CompLeak 是首个同时覆盖剪枝、量化、权重聚类以及单/多压缩版本访问场景的系统性隐私评估框架。（§1.2、§9）
2. 压缩对成员和非成员的输出影响不同，成对比较原模型与压缩模型可暴露单模型攻击遗漏的成员信息。（图 2、§5）
3. 不同压缩版本提供互补视图，多版本联合会进一步增强成员推断，即使原模型不可访问也仍有增益。（§6、表 6–8）
4. 风险与压缩后使用原训练数据再训练密切相关；使用独立辅助数据恢复、采用无需微调的 PTQ、限制输出到 hard label 是候选缓解方向。（§7）

### 由实验直接支持的较窄结论

- 在本文的分类模型、数据集、完整 posterior、同分布影子数据与已知压缩配置条件下，SR/MR 显著强于逐个模型攻击。
- 单个高度压缩模型通常**不是**更危险，而是更低容量导致 CompLeakNR 下降。
- 最强结果主要来自可访问原模型及多个压缩版本的强攻击者；只访问多个压缩模型时仍有效，但低 FPR 下绝对 TPR 明显较低。
- 无压缩后再训练的动态 PTQ 没有复现 QAT 那样强的额外泄露，说明结论依赖压缩流水线而非纯数值表示变化。

## 评审式评价

### 优点与创新性

1. **问题定义具有部署真实性**：模型服务确实可能发布 fp32、int8 和多个稀疏度版本；论文把“版本集合”提升为隐私攻击面，而不是只测一个模型。
2. **先否定朴素命题，再建立差分攻击**：NR 显示高度压缩模型更安全，SR/MR 再证明关联版本会增加泄露，逻辑比直接报告一个更强攻击完整。
3. **攻击方法与机理观察相互对应**：SR 使用压缩前后全 posterior 的差异；MR 使用跨压缩程度的 meta-posterior 与 loss 轨迹，而非无解释地堆叠模型输出。
4. **实验覆盖较广且有关键控制**：三类商用框架支持的压缩操作、四个经典视觉架构、两个文本模型、多种 MIA、低 FPR 指标、重复模型对照、DP-SGD、过拟合和组件消融。
5. **可复核性较强**：官方 artifact 提供原模型训练、压缩和三类攻击脚本，且获得 Functional 与 Results Reproduced 标记。

### 关键局限

1. **标题需要条件化理解**：核心放大来自同时暴露相关版本；若部署只发布一个高度压缩模型，它可能比原模型更难做成员推断。更准确的安全结论是“多压缩版本发布与压缩后再训练扩大隐私攻击面”。
2. **威胁模型较强**：完整 softmax、真实标签、同分布影子数据、准确架构和压缩参数均已知。真实 API 常只给 top-k、logit 截断或 hard label，查询预算也可能受限。
3. **最强数字混合了更多信息源与更多查询**：SR/MR 的输入维度和模型访问数天然高于 NR。重复训练模型对照缓解了这一质疑，但仍缺严格匹配查询预算、输出位数和参考模型数量的全面比较。
4. **压缩与再训练没有完全因果解耦**：主实验的剪枝、QAT、聚类通常含原训练数据微调；动态 PTQ 反而泄露较弱。因而“容量变化”“重新记忆训练样本”“多视图关联”各自贡献仍需正交实验。
5. **任务范围有限**：大部分证据来自过拟合较明显的图像分类器；BERT/GPT-2 仅用于 SST-5 分类微调，不代表大规模生成式 LLM。作者也明确承认，当底层任务的 MIA 接近随机时 CompLeak 不工作。（§8）
6. **统计报告不够完整**：表 6、7 报告五次均值，但正文表格未给标准差或置信区间；大量配置只报告点估计。
7. **防御证据有限**：DP-SGD 的 $\epsilon$ 很大；辅助数据微调、PTQ 和 hard-label 输出主要是讨论或局部实验证据，尚无系统的效用—隐私—压缩率三维 Pareto 评估。
8. **其他隐私攻击仅是推测**：论文关于白盒 MIA、property inference 和 model inversion 可能增强的讨论没有相应实验，不能当成已证实结论。（§7）

## 如何准确引用这篇论文

推荐表述：

> CompLeak 表明，在分类任务上同时发布原模型与压缩模型、或多个相关压缩版本，会产生可被成员推断利用的跨版本差分信号；压缩后用原训练数据再训练会进一步强化部分样本的泄露。

不推荐表述：

> 所有模型压缩都会让单个模型更泄露隐私。

后者与 CompLeakNR 以及动态 PTQ 结果相冲突。

## 证据定位

| 陈述 | 位置 |
|---|---|
| 研究问题、三种场景与贡献 | §1.1–§1.2，图 1，pp. 6545–6547 |
| 压缩与 MIA 背景 | §2，pp. 6548–6549 |
| 黑盒威胁模型 | §3，p. 6549 |
| CompLeakNR 方法、设置与逐模型结果 | §4，表 1–4，pp. 6549–6551；附录表 11–15，pp. 6563–6564 |
| CompLeakSR 的差分观察与攻击流程 | §5，图 2–5、表 2–5，pp. 6551–6553 |
| DP-SGD 实验 | §5.4、附录表 16，pp. 6553、6563 |
| CompLeakMR 两类攻击者、方法、主结果 | §6，图 6–8、表 6–8，pp. 6553–6556 |
| 重复训练对照、RMIA、BERT/GPT-2 | §7、表 9、附录表 17，pp. 6556–6557、6564 |
| 局限与结论 | §8–§9，p. 6557 |
| 过拟合、数据集与组件消融 | 附录 E–F，表 18–20，p. 6564 |

## 待验证问题

- Artifact Evaluation 的复现范围集中在 CIFAR-10/ResNet18；论文其余视觉与文本配置虽有官方代码/数据，但本笔记未独立运行。
- 尚需在 posterior 截断、top-k、hard label、查询限额与影子分布偏移下重新评估攻击强度。
- 尚需以相同效用、相同模型访问数和相同查询预算比较：压缩版本、多随机种子独立训练版本、checkpoint 版本与真正异构模型 ensemble。
- 本文未覆盖知识蒸馏与结构剪枝；不能把结论直接扩展到不同架构的学生模型。

