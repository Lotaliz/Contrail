---
id: c5-global-local-importance-plan
type: synthesis
title: "Cx 双重要性指导的自适应视觉预算：方法方案 v2"
tags: [research, visual-token-pruning, multimodal-safety, adaptive-budget, visual-evidence]
project_id: visual-token-pruning
sources: [paper-arxiv-2609-10346, paper-liao-2026-resadapt, paper-arxiv-2609-22910, paper-arxiv-2609-34861, paper-arxiv-2609-27988, code-qwen3-vl-vision-process]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# Cx 双重要性指导的自适应视觉预算：方法方案 v2

## 1. 研究目标与范围

当前自适应预算方法称为 **Cx**；**C5** 专指原固定 5% 预算的历史方法与实验对照。Cx 沿用原 C5 的政策条件图像审核场景：输入图像、当前完整短政策、类别映射和审核提示，预测政策对应的标签。短政策按模板从长政策改写，是背景条件。视觉输入由全局视图和至多一个局部框组成；研究逐样本的总视觉预算及两路预算划分。

用户提出两个轻量网络分别预测全局重要性和局部重要性。本方案将其具体定义为同一审核代价尺度上的预算收益曲线，使其真正进入路线评分。方法描述不指定数据集规模、使用范围、执行顺序、门禁或失败处置。

当前方法和性能改善仍为研究假设。原始 C5 场景证据见 [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md]]；原始实验记录不改写。

## 2. 审核代价：仅 NLL 与标签不一致

令 $x=(I,P)$，候选路线 $a=(g,l,b)$，其中 $g,l$ 分别为实际全局、局部视觉 Token 数，$b$ 为单局部框。$l=0$ 表示没有局部视图。用同一目标 Guard 的预测定义

$$
C_x(a)=\mathrm{NLL}(y\mid x,a)+\lambda_{label}\mathbf1[\hat y_a\ne y].
$$

收益只由这两项的代价差产生。$\lambda_{label}$ 表示标签不一致惩罚的权重，本页不规定其具体值。没有额外 FN、FP、格式失败或 NLL 截断项；时间/Token 成本仅出现在预算规划目标中。

NLL 的标签字符串、概率归一化范围和序列长度口径在所有路线中保持一致。可沿用原 C5 的 NLL 定义；若采用合法类别内归一化，形式为 $q_c=\exp(s_c)/\sum_{c'}\exp(s_{c'})$、$\mathrm{NLL}=-\log q_y$，其中 $s_c$ 为合法标签字符串的序列 log probability。不同口径的 NLL 不混合比较。

标签不一致按当前政策及其类别映射判定。同图异策使用各自的 gold。gold 参与监督目标定义，不作为在线预算网络输入。

## 3. 两个指导指标

### 3.1 全局升级收益

$g_0$ 表示合法全局档位中最低的实际预算。

$$
G_g(x,g)=C_x(g_0,0)-C_x(g,0).
$$

含义：只有全局视图时，增加全局清晰度能够减少多少审核代价。$G_g(x,g_0)=0$；该量允许为负。参考不固定为某个百分比。

### 3.2 给定全局预算的条件局部收益

$$
G_l(x,g,l,b)=C_x(g,0)-C_x(g,l,b),\qquad G_l(x,g,0,b)=0.
$$

含义：保持全局视图不变，加入指定位置、清晰度的单局部视图，能够减少多少审核代价。它依赖全局预算及语境，可以表达局部与全局的补充、冗余和协同。

两项满足

$$
G_g(x,g)+G_l(x,g,l,b)=C_x(g_0,0)-C_x(g,l,b).
$$

因此两个指标各有独立、可计算的监督，并可共同解释整条路线相对参考的收益。这里采用“全局升级＋局部补充”的操作价值分解；它不声称是唯一、对称的因果归因。

局部指标衡量整个局部路线的增量价值，包含局部像素和新增视图接口的影响。预算价值与像素依赖是不同的解释维度。

## 4. 两个轻量网络

### 4.1 共享表示

Cx 复用原 C5 的图像 CNN、政策编码器和 cross-attention，获得全局图文特征 $h_g$、单框图文特征 $h_b$ 和政策特征 $e_P$。两个预测网络共享预览，不复制两套图像与文本编码器。框坐标和特征对应实际视图及其位置变换。

### 4.2 全局网络

输入包括 $h_g,e_P,h_g\odot e_P$、原图几何、原生参考 Token 数 $N$、候选全局预算 $g,g_0$ 和实际网格。监督为 $G_g$，不依赖局部框。

可采用轻量 MLP：LayerNorm、128/64 维隐藏层、GELU 和有符号标量输出。以同一网络的 $f_g(g)-f_g(g_0)$ 表达参考零点。模型宽度是结构示例，非实验执行约束。

### 4.3 局部网络

输入包括 $h_g,h_b,e_P,h_b\odot e_P$、框位置/面积/宽高比、原图几何、$N,g,l$ 和两视图实际网格。监督为 $G_l$；它同时读取全局语境及预算，而非只读取局部特征。

可采用同类 MLP。$l=0$ 的指标定义为零，非零局部档位允许有符号输出。两支输出使用共同审核代价单位，数值缩放不改变其相对尺度。

双指标直接参与最终路线分数，不额外设置能绕过它们的自由评分分支。

## 5. 三档预算与总预算规划

全局、局部各三个请求档位。示意配置：

| 视图 | 三档 | 含义 |
|---|---|---|
| 全局 | 16、64、full | 较低、较高及原生完整全局预算 |
| 局部 | 0、8、16 | 无局部、较低及较高局部预算 |

局部三档包含 0，所以具有两个非零局部清晰度。上述具体 Token 数仅是可替换示例；档位对应实际合法网格。固定一个候选框时最多形成 $3\times3=9$ 个逻辑配置，实际等价输入可以共用同一配置表示。

收益比较中的 mixed 路线与对应 global-only 路线具有相同全局输入。预算描述实际送入编码器的网格；原图信息分辨率与编码器 Token 数分别记录。插值放大不增加原图信息，但不能由此直接推断它对视觉编码和分类没有价值。

### 5.1 小图条件下的档位适配

用户最新报告当前全图平均约 400 个视觉 Token，此处作为场景观察记录，不规定数据集规模或使用范围。忽略宽高比、补边和网格取整，面积为 1/16 的局部参考约 25 Token，1/9 约 44 Token。原先 0/16/64 的示例未贴合该条件；0/8/16 是更保守的绝对档位示例，实际档位仍取决于合法网格。

更一般的三档表达可以为

$$
\mathcal B_l(b)=\{0,\mathcal Q(\alpha K_{ref}(b)),\mathcal Q(K_{ref}(b))\},\qquad 0<\alpha<1.
$$

$K_{ref}(b)$ 为该裁图按原像素尺寸、采用一致预处理口径得到的参考视觉 Token 数；$\mathcal Q$ 表示合法网格映射，$\alpha$ 是未固定的相对档位参数。固定三档的语义为无局部、降采样局部和参考清晰度局部，而非所有裁图使用相同绝对 Token 数。$K_{ref}$ 不定义为模型不能超过的硬上限。

框面积与预算档位承担不同作用。扩大框能够增加覆盖与语境；同样局部 Token 下，它会降低单位图像面积的采样密度。因而 1/9 单格不是仅为达到某个 Token 数而设的必然选择。保留原定位网格、使单个 ROI 窗口稍大或有重叠，是单框结构的另一种表达，不要求改为多框。

Qwen 官方预处理支持指定 resize 尺寸及像素范围，`smart_resize` 包含上采样分支，所以小裁图的原尺寸参考 Token 数不等于编码容量上限。更大的编码网格可能改变模型的表示尺度，是否改善审核尚未在 Cx 验证；不能把插值放大写成恢复真实细节。源码边界见 [[LLM-Wiki/research/visual-token-pruning/qwen3-vl-resolution-budget-notes.md]]。

### 5.2 收益与总预算

联合路线分数为

$$
S_x(g,l,b)=\widehat G_g(x,g)+\widehat G_l(x,g,l,b)-\lambda_{cost}\operatorname{Cost}_x(g,l,b).
$$

$$
a^*=\arg\max_{a\in\mathcal A_{legal}}S_x(a),\qquad
K_{total}=g^*+l^*,\quad\rho_g=\frac{g^*}{g^*+l^*}.
$$

Cost 可表达实际 Token 或预期时延，$\lambda_{cost}$ 的单位随之确定。本文不规定成本权重、阈值或扫描方案。时延属于计算取舍，不属于视觉贡献标签。

两个累计指标的比例不直接等于 Token 比例。更准确的指导量是追加预算的条件边际收益：

$$
m_g=\frac{[\widehat G_g(g')+\widehat G_l(g',l,b)]-[\widehat G_g(g)+\widehat G_l(g,l,b)]}{g'-g},
$$

$$
m_l=\frac{\widehat G_l(g,l',b)-\widehat G_l(g,l,b)}{l'-l}.
$$

全局升级可能改变局部价值，因此 $m_g$ 包含局部收益变化。绝对收益及其饱和位置影响总预算；两路边际收益影响预算划分。

## 6. 监督目标与中间特征

两个网络可分别回归 $G_g,G_l$：

$$
\mathcal L=\mathbb E_x[\mathcal L_g(\widehat G_g,G_g)+\mathcal L_l(\widehat G_l,G_l)].
$$

回归损失可采用 Huber。每个全局档位对应独立全局监督，局部监督以对应全局档位为条件；两项均来自同一目标 Guard 和一致输入定义。本文不规定训练日程、采样范围、恢复顺序或 checkpoint 选择方法。

注意力、激活和 gradient×feature 可提供辅助监督或相关性描述。当前区域 query 对全部政策 key 的 softmax 权重和为 1，直接求和无法形成区域重要性。归一化 attention 的全局/局部比例也不能单独提供总预算所需的绝对尺度。

一种中间敏感度形式为

$$
Q_v=\frac1{K_v}\sum_{j\in v}\left\|z_j\odot\frac{\partial\mathrm{NLL}}{\partial z_j}\right\|_1.
$$

它表示局部敏感度近似，与实际增加预算带来的收益不等价。层位、特征尺度和 Token 数影响其数值。最终 Guard 的中间量属于监督侧信息，预算网络的部署输入仍为执行前可得的图文特征。

## 7. 两种局部收益定义的用途

### 7.1 全局基础上增加局部：适合 Cx 预算规划

$G_l=C(global)-C(global+local)$ 回答：**在当前全局清晰度下，为这个局部增加预算是否值得？** 它与 Cx 的全局＋单框输入一致，直接表达局部的增量需求。

全局已看清风险时，某个局部可以独立判得很准，但其条件收益仍很低；全局模糊时，同一个框的条件收益可能很高。该差异恰好是预算分配需要的信息。

增加局部意味着增加总预算，所以这里是增量收益。若研究固定总预算内的分配取舍，可比较相同总 Token 的 global-only 与 mixed 配置；三档库中存在相应配置时，该比较可由共同路线分数表示。

### 7.2 只看局部和位置：衡量独立充分性

令 $C_x^{only}(l,b)$ 表示只输入该局部及原图位置信息时的审核代价。其效用可以表示为 $U_l^{only}=-C_x^{only}(l,b)$，也可相对一个明示 reference 定义收益。**局部-only 代价本身不自动等于条件增量收益。**

该量回答：**仅凭这个局部，能否完成当前政策下的整图审核？** 它适合描述区域的独立充分性、局部证据能力或局部-only 路线。它不包含全局是否已经覆盖该证据，因此不能直接代替 $G_l$；与 $G_g$ 相加也不保留前述总收益恒等式。

局部内容与标签之间可能依赖场景、行为关系及政策例外。例如局部出现持枪人物，周边画面可能提供影视拍摄、玩具或体育活动等判定线索。只保留局部会失去这些线索；原图坐标提供位置，不提供被移除的语义内容。

crop＋坐标与保留原画布、遮蔽框外像素具有不同的缩放、布局和输入分布。遮蔽像素也不会自动减少被视觉编码器处理的 patch 数，不能直接视为同成本的局部输入。

**本方案的研究判断：条件局部收益作为主预算指标；局部-only 效用作为可选的独立充分性描述。** 两者解释不同的问题，尚无 Cx 的实验证据证明一种在所有场景都更好。

## 8. 可解释性与方法边界

规划解释包含两支收益曲线、候选成本、实际全局/局部 Token 和路线分数。曲线的真实预测准确性、政策变更响应和对最终规划的影响，是不同的解释维度。

像素依赖可描述为相同位置、网格和全局输入下，真实局部与匹配替换局部的代价差：

$$
E_l=C_x(g,l,b;local_{null})-C_x(g,l,b;local_{real}).
$$

该量与 $G_l$ 不同：前者关注返回像素的作用，后者关注整个局部路线的增量价值。独立充分性、条件增量价值和像素依赖不互相替代；它们也不自动构成唯一因果归因或安全保证。

## 9. 来源和关联

VIP-Router 支持离线效用回归方向，ResAdapt 支持编码前图文预算控制方向；CounterCredit 区分追加视觉调用的决策价值与返回像素的证据价值。When Text Matters 和 Task-Induced Riemannian Metrics 提供中间信号与任务敏感度的相邻证据。它们没有直接验证本页双收益分解在政策 Guard 上的性能。

- [[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-liao-resadapt.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-peng-countercredit.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-kang-when-text-matters.md]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-bond-task-induced-metrics.md]]

方法配置见 [[LLM-Wiki/experiments/20261010-cx-global-local-importance/defaults.yaml]]；记录入口见 [[LLM-Wiki/experiments/20261010-cx-global-local-importance/README.md]]。用户报告新的自适应预算实验运行中，实际配置尚未核验，未提供新实验结果。

安全角度的并行选择器假设见 [[LLM-Wiki/research/visual-token-pruning/cx-policy-safety-representation-pruning.md|政策条件证据保留调研]]；本页预算与代价定义保持。
