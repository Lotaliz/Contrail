---
id: c5-adaptive-total-budget-plan
type: synthesis
title: "C5 自适应总预算：一次路由、单局部框与高清救回收益"
tags: [research, visual-token-pruning, multimodal-safety, adaptive-budget, dynamic-inference]
project_id: visual-token-pruning
sources: [paper-arxiv-2609-10346, paper-arxiv-2609-13804, paper-ding-2026-et-prune]
status: active
created: 2026-10-09
updated: 2026-10-10
---

# C5 自适应总预算

**2026-10-10 主线更新：** 用户明确不锚定 5%，先做逐样本预算划分，暂不考虑 batch。最新主设计改为实际 $(K_g,K_l,b)$ 配置选择与最小充分配置监督，见 [[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md|逐样本视觉预算分配]]。本页 5%→20% 二选一保留为历史 pilot 选项，不再作为核心方法；平均 5% 不是当前约束。

## 1. 决策与证据边界

下一步优先验证：**复用当前政策条件 preview/router，在运行 Guard 前决定总视觉预算，让可被高清救回的图像—政策条件使用更多视觉 Token。** 保持单局部框；预算变化同时作用于合法视觉网格、图像渲染和 Guard 实际输入，不只调整名义比例。

用户的 NLL 收益 router 几乎不选 50/50、总体指标无明显改变，见 [[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md|最新观察]]。它支持总预算值得优先试验，未证明 router 已达到上限。NLL-only 与旧安全代价不同、固定单格几何、Guard 适配等替代解释仍保留。无需先继续堆 router loss；先测几档高清分支是否有可学习的实际收益。

| 主张 | 证据/来源 | 当前级别 |
|---|---|---|
| profile 分布改变、总体质量接近旧方法 | 本次用户报告 | 定性观察，缺具体数字与配对统计 |
| 极低预算的全局清晰度可能不足 | 原 C5 错误实例与用户后续错误分析 | 场景证据，非总预算因果结论 |
| 轻量 preview 可预测候选效用 | Wiki 的 VIP-Router 笔记及原文 §3.4 | 公开普通 VLM 先例，未验证 C5 |
| 自适应预算不保证所有任务获益 | Wiki 的 StepPrune 消融 | 反例，需同平均成本比较 |
| 高清预算门可改善 C5 | 本页设计 | 待验证假设 |

## 2. 最小版本：当前 5% 路线与高清全局二选一

第一版不同时扩框库或重新设计条款分解。复用现有图像 CNN、文本 Transformer、cross-attention 和区域/profile 输出，得到共享预览特征 $h(I,P)$ 及当前低预算路线

$$
a_L(I,P)=\mathrm{C5}_{frozen}(I,P;5\%).
$$

增加一条高预算候选

$$
a_H=(20\%,\mathrm{Global100}).
$$

5%/20% 是**建议试验档位**，不是已验证最优值；先通过固定预算曲线确定 20% 是否足够、有无时延价值。高清全局同时覆盖整图，适合诊断全局模糊和选错局部；若只把原错误局部放大，可能仍遗漏真正证据。这里 Global100 的“100”表示全部当前预算给 global，不是原图 100% 视觉预算。

在线链路：

```text
原图＋政策
  → 一次现有 preview/C5 router
  → 当前 5% 路线＋新增预算门
  → 选当前 5% 输入，或 20% 全局输入
  → 根据选定预算从原图渲染
  → 一次 Guard → A–J
```

预算门输入可复用全局/区域图文特征、原 route 分数、所选框/profile、原图宽高、原视觉 Token 数 $N$ 与高低候选的实际 Token 数。可以先冻结 C5，只训练一个小 gate/收益 MLP，检查原特征是否足够；不足时再独立消融共享 encoder 微调或更清晰预览。

这个版本只加入预算决策，在线不先跑一次低预算 Guard 再判断是否重跑；后者会支付额外 Guard 成本，是另一种级联方法。预算门所有输入都必须在最终 Guard 调用前可得到。

## 3. 门应该学习高清救回收益

冻结同一个、能处理这些预算的 Guard，离线运行 $a_L,a_H$，用各政策 gold 计算已冻结的安全任务代价 $C_{task}$。保留原 NLL、错类、Unsafe→Safe/误报处罚的定义与权重，并保存各分量；不只按 raw logit 或总体 accuracy 产生标签。

$$
B(I,P)=C_{task}(I,P,a_L)-C_{task}(I,P,a_H).
$$

训练一个预测 $\widehat B_\phi$ 的 Huber 回归头。$B>0$ 表示高清减少任务代价，负值允许保留，用于记录高清退化。还可保留原安全惩罚或联合二候选分布监督，逐项消融，不假定新目标必然有效。

以实测完整 E2E 的增量 $\Delta t=t_H-t_L$ 决策：

$$
\mathrm{choose\ high}\quad\Longleftrightarrow\quad
\widehat B_\phi-\lambda_t\widehat{\Delta t}>\eta.
$$

$\lambda_t$ 表达质量—时延取舍，$\eta$ 是验证集校准的可选 deadzone；都不能按最终 test 调整。时间项可用按 $N$、实际网格、view 数等拟合的成本表/小模型，须计入 preview、policy、gate、resize/render、vision、prefill/decode 与未列 Python 开销。

总预算变大但 view 从两个减为一个时，$\Delta t$ 不必为正，必须实测；不能假定 20% Token 就是 5% 的四倍时延。分别统计低路径错/高路径对、低对/高错、两者都对/都错；不要只筛 B0 正确或高预算正确的样本来训练并评价。

目标是“高清是否能改善当前低路径”，不是泛化的困难度、是否 Unsafe 或低预算分类熵。某些难图在高预算仍错误，不应一律标为必须升级；某些图像低预算自信但漏掉小目标，也可能值得升级。当前 128×128 预览能否预测这种收益仍是可观测性问题。

## 4. 第二版：共同尺度的预算—路线联合选择

二选一门通过后，尝试 $\mathcal B=\{5\%,10\%,20\%\}$。完整动作写成

$$
a=(\beta,\rho,b),\qquad
\rho\in\{\mathrm{Global100},75/25,50/50\}.
$$

沿用原 16 单格时，每个预算最多 33 路线，三个预算最多 99 条逻辑路线；不要将它与“49 个几何框×两个 profile＋Global100”的另一种 99 路线混淆。所有合法性、alias 和 Token 规划按实际渲染去重/屏蔽。先不把总预算与几何扩展同时作为新变量。

在原 preview 特征上接共享候选评分器。每次编码图像与政策一次，给候选 head 增加 $\beta,\log\beta$、绝对 $K_g,K_l$、原 $N$、原图宽高、框几何与 view 数。仅输入名义比例不足，因为不同原图同 5% 的实际 Token 和可见性不同。不同候选只运行小 head，最终只渲染/执行选中的路线。

**跨预算必须使用共同 reference：**

$$
a_{ref}=(5\%,\mathrm{Global100}),\qquad
G(a)=C_{task}(a_{ref})-C_{task}(a).
$$

不能把每个预算各自的 Global100 都归零后直接比较 gain：那会抹掉 10%/20% 全局图相对 5% 的质量改善。也可直接预测同尺度的绝对任务代价。若按候选分别标准化，选路前恢复原尺度；policy-pair 差分也使用可比较尺度。

部署时按

$$
a^*=\arg\max_{a\in\mathcal A}
\left[\widehat G(a)-\lambda_t\widehat{\Delta t}(a)\right]
$$

联合决定总预算、全局/局部比例和框。不先按预算概率总量选预算，再在该预算里选路线。保留 50/50 作为可用动作：5% 时全局损伤大，不证明更宽预算下也无用。

共享预算输入可以借鉴 [[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md|VIP-Router]]，但该论文主要在给定外部比例下选择剪枝策略并允许 Full 回退，并未验证本页 5/10/20 联合预算的政策 Guard。[[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-stepprune.md|StepPrune]] 的 STOP 和 [[LLM-Wiki/research/visual-token-pruning/papers/2026-ding-et-prune.md|ET-Prune]] 的证据预算提供近邻及失败边界，不需要迁移其完整视觉塔或顺序推理结构。

## 5. 预算规划与 Guard 适配

复用已有严格预算 planner：名义 $K_\beta=\max(2,\mathrm{round}(\beta N))$，再在合法二维网格得到 $K_{eff}(\beta)$。高预算必须让从原图生成的真实 global/local 网格变大。保持输入宽高比、至少一个 Token/视图、全局＋至多一个局部框、合并和位置接口有效。记录每 view 实际 Token、有效内容/补边，不能只改 router 的预算字段而给 Guard 相同模糊图。

先在小型内部验证检查当前恢复 Guard 是否已经能处理 10%/20%。如果高清质量改善且旧 5% 不退化，可以先冻结当前 Guard 做预算门；如果只适配 5% 后的 Guard 对新网格异常，不要直接拒绝预算假设。

必要时做**一个共享多预算 Guard 的恢复训练**：在同一训练集、政策变体、原 profile 接口下混合 5/10/20%，使用分类 CE，保证各预算/profile 有训练覆盖。不要按 router 预测概率采样，避免初期偏好只训练某一档；同图政策变体的视图调度尽量对齐以检查真正政策响应。按各预算独立验证，兼顾旧 5% 保持和更宽预算质量，避免全参数恢复的遗忘；具体学习率/epoch 为待定配置，不把旧三轮直接当作最优参数。

共享 Guard 固定后才生成最终 teacher 并训练 gate/router。预算/Guard 适配改变后，旧 teacher 只可作背景，不能当作当前 $B/G$ 的最终标签。每预算分别训练 Guard 会混入 checkpoint/参数收益，不适合作为主自适应系统；可以作为明确标注的上界或诊断。

## 6. 平均预算与速度约束

2026-10-10 用户已明确：不以 5% 为核心，先逐样本选择，暂不考虑 batch。当前不设置平均 5% 硬约束；以下平均预算计算保留为旧方案的成本说明。具体请求上限和候选网格在实际实验配置时确定，不能将这里的 20% 示例当成已验证档位。

若最低 5%、部分样本升至 20%，平均预算必然上升。忽略取整、按样本名义比例均值，20% 样本升级时为

$$
0.8\times5\%+0.2\times20\%=8\%.
$$

这不是已得到的预算分布或质量收益。若严格保持平均 5%，则需给部分简单样本低于 5% 的分支，例如 2.5%；这增加了超低预算的漏报风险及适配工作，先作为独立配置。没有“所有样本至少 5%、部分升级、平均仍 5%”的可行方案。

同时记录样本平均保留率、全数据 $\sum_iK_i/\sum_iN_i$ 和平均实际时延；三者不能互相替代。可以调 $\lambda_t$ 使 dev 平均时延达到目标，或用 $\lambda_K$ 的实际 Token 成本控制平均预算，但有限验证集上的达标不保证新分布也达标。若引入硬请求预算上限/队列控制，单独报告其质量影响。

## 7. 最小实验顺序与停止条件

| 阶段 | 内容 | 固定或比较边界 | 决策依据 |
|---|---|---|---|
| P0 | 5/10/20 Global100；原 C5 单框在几档预算重放 | 初期同一恢复 Guard，小型内部验证；不扩框 | 高清是否实际救回及静态质量—时延曲线 |
| P1 | 若必要，混合预算 Guard 恢复 | 相同训练数据/政策和共同 checkpoint | 各预算支持，避免旧 5% 遗忘 |
| P2 | 当前 5% 路线 vs 20% 全局升级门 | 冻结共同 Guard/C5；训练集离线 teacher | 实际救回、误升级/漏升级、净时延收益 |
| P3 | 5/10/20 共享预算条件 router | 同一 Guard、box 库、任务代价 | 对预算/比例/框共同选择的增量 |

保留 P0 中静态 10%/20% 全局作为强基线：若某档单图已经占优，优先使用实测更好的工作点，不为自适应形式牺牲效果。主实验还需随机升级但匹配升级比例/实际成本、无政策预算门、同平均 Token 的固定预算与同平均 E2E 的固定配置；保留不可部署的 oracle 只作上界。

质量指标：宏召回、accuracy、Unsafe recall、benign FPR、PER/配对两侧均正确率、类别/政策最差组、压缩诱发漏报；风险代价不能代替这些独立指标。效率：总 E2E 均值/P50/P95、各预算/profile 占比、实际 Token、preview/gate/渲染/Guard 分项、显存。样本配对统计按基础图像聚类；不把同图多政策和反复计时当成独立样本。

先用 train 内图像隔离的 pilot，dev 校准工作点，最终 test 仅确认。观察到高预算全失败、静态高清工作点完全占优、gate 的 regret 接近随机或额外成本超过收益时，停止相应复杂化；保留负结果。这里未指定 GPU-hour 或启动训练，执行成本须先据实际可用缓存/动作数审计。

## 8. 解释性与投稿边界

预算门可以解释为“当前政策下，预期高清减少多少安全任务代价、需要多少计算”，并在同图政策变更/错政策控制下检验它是否读政策。原条款干预与像素监督可以后续接入，不能把 CNN 的困难度、模型置信度或高预算选择自动叫作证据充分性。

动态预算、分辨率升级和效用 router 已有先例。当前候选贡献需要由政策条件的实际高清救回、单次部署、风险代价和同成本质量改进支持。更宽预算带来的平均质量提升本身不足以证明自适应分配更好；必须优于匹配平均计算的固定配置。仍是研究假设，未证明安全非劣、统计保证或跨数据泛化。

关联：[[LLM-Wiki/research/visual-token-pruning/overview.md]]；[[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md|固定预算与几何/政策监督设计]]。
