---
id: on-policy-distillation
type: concept
category: method
tags: [method, research]
title: On-policy 蒸馏
aliases: [在线策略蒸馏, Student-rollout Distillation, On-policy Knowledge Distillation]
status: active
related: [safety-classifier-compression]
sources: [paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety]
created: 2026-08-25
updated: 2026-08-25
---

# On-policy 蒸馏

## 定义

On-policy 蒸馏（OPD）让**当前学生策略先生成序列**，再让教师在学生实际访问的每个前缀状态上给出 token 分布或其他密集监督。典型目标为：

$$
\mathcal{L}_{\mathrm{OPD}}=
\mathbb{E}_{x\sim\mathcal D,\,y\sim\pi_S(\cdot|x)}
\left[\sum_t D\!\left(p_T(\cdot|x,y_{<t})\,\|\,p_S(\cdot|x,y_{<t})\right)\right].
$$

这里的关键不是“教师是否在线”，而是**监督状态是否来自当前学生的 rollout 分布**。采样出的离散序列通常停止梯度；学生更新后重新采样，访问分布也随之变化。

```mermaid
flowchart LR
    X[任务 prompt] --> S[当前学生生成 rollout]
    S --> P[学生访问的前缀状态]
    P --> T[教师在同一前缀给分布/奖励]
    T --> L[逐 token 蒸馏损失]
    L --> U[更新学生]
    U --> S
```

## 与相邻范式的边界

| 范式 | 训练序列/状态来自哪里 | 教师监督 | 是否严格 on-policy |
|---|---|---|---|
| SFT | 人工/固定答案 | hard label | 否 |
| Sequence-level KD | 教师预先生成的固定答案 | teacher sequence | 否 |
| 静态 token KD | 数据集或教师序列前缀 | teacher logits | 否 |
| 学生历史样本回放 | 旧学生 rollout | teacher logits/分数 | 近似 off-policy |
| GKD 混合目标 | 固定序列 + 当前学生 rollout | teacher distribution | 部分；由混合系数控制 |
| 严格 OPD | 当前学生 rollout | 同前缀上的 teacher distribution | 是 |
| 强化学习 | 当前策略 rollout | 标量/过程奖励 | 通常是，但目标不一定是模仿教师分布 |

**判别器边界：**普通 encoder 安全分类器每个样本只有一次前向决策，不产生自回归状态分布。按学生高置信错误、边界样本或困难样本主动采样，属于“student-error-driven 数据蒸馏”，与 OPD 精神相近，但不宜称为严格的 on-policy 蒸馏。严格 OPD 最直接适用于会生成 verdict、类别序列、解释或归因的自回归 Guard。

## 为什么需要它

静态蒸馏只在参考答案或教师答案的前缀上训练，推理时学生一旦生成不同 token，就会进入训练未覆盖的状态。OPD 把教师监督带到学生自己的错误轨迹上，因而可：

1. 缩小训练前缀与推理前缀的分布错配；
2. 把教师预算集中到学生实际会犯的错误；
3. 在学生改善后自动改变课程；
4. 允许用不同散度控制“覆盖教师多样性”和“追求少数高概率模式”的取舍。

它并非无条件更好：弱学生早期 rollout 可能低质且狭窄；稀有危险模式若从未被学生探索到，也不会自动得到监督。

## 主流研究方向

### 1. Rollout 分布混合与课程

- **GKD：**用系数 $\lambda$ 混合固定数据与当前学生 rollout；SFT/静态 KD 和纯 OPD 成为同一目标的特例。
- **自适应回放：**DistiLLM 复用并按需刷新学生生成样本，降低每步都重新 rollout 的开销。
- **教师混合采样：**MiniLLM 在采样时混入教师，缓解学生利用奖励漏洞或早期轨迹过差。

### 2. 散度与目标分布设计

- **Forward KL：**倾向覆盖教师分布，但教师偏好 token 在学生概率极低时可能产生不稳定的大梯度。
- **Reverse KL：**更偏向高概率模式，适合学生采样分布，但可能牺牲多样性并发生 mode collapse；MiniLLM 以此为核心。
- **JSD / skew KL：**GKD、DistiLLM 用混合或偏斜分布平衡两端的病态行为。
- **目标重构：**Veto 在 logit 空间构造几何目标，以连续参数调节抑制与多样性。

### 3. 长轨迹成本压缩

完整 OPD 同时支付学生生成和教师前向成本。Prefix OPD 只蒸馏推理前缀；其 2026 年实验在长推理任务中报告与完整 OPD 相近的效果，同时减少约 2–40 倍训练 FLOPs。该结果说明监督价值可能集中于早期决策 token，但尚不能直接外推到短安全标签或所有任务。

### 4. 正负序列与数据配对

DistiLLM-2 不把教师和学生序列视为同质数据，而是提高教师答案似然、降低学生错误答案似然，并配合数据筛选和课程。该方向把 OPD 从“同前缀拟合分布”扩展为“对比学生失败与教师成功”。

### 5. 特权条件与自蒸馏

OPSA 让学生在普通输入上生成，再让冻结的教师副本在额外安全上下文条件下评估相同轨迹，以密集 KL 将潜在安全能力迁回学生。它是当前安全场景最直接的 OPD 证据，但截至本概念更新时间仍是 2026 年预印本，且研究对象是安全对齐的推理模型，不是独立 Guard 分类器。

### 6. 推理、智能体与多模态扩展

研究正在从短答案扩展到长推理、工具调用、智能体和视觉语言模型。共同问题是轨迹更长、环境/图像状态更复杂、教师查询更贵，以及错误前缀可能造成后续监督污染。此方向属于快速发展中的扩展证据，不应据此声称多模态安全 Guard 已得到充分验证。

## 安全判别压缩中的用法

### 自回归 Guard（严格 OPD）

1. 从真实流量、红队样本和策略切片中采样 prompt/图像；
2. 当前小 Guard 生成 `verdict → category → rationale/evidence`；
3. 大 Guard 在**相同学生前缀**上给 token 分布，必要时附加安全政策、证据框或审核上下文；
4. 对判定 token、类别 token 和证据 token 分别加权蒸馏；
5. 高风险或不确定轨迹回收到下一轮，并对不安全输出执行隔离、访问控制和审计。

安全任务不应只优化平均序列 KL。早期 `safe/unsafe` 决策、罕见类别与证据引用的错误成本不同，应结合 risk-conditioned sampling、类别最低配额和固定 FPR 下的召回约束。

### Encoder Guard（类比方案）

使用学生错误驱动的主动蒸馏：在新流量上运行学生，优先把高置信错误、边界/OOD 样本、长尾类别交给教师标注，再更新学生。它解决“教师预算应花在哪里”，但没有学生生成的前缀轨迹，因此应与 OPD 分开命名和实验报告。

## 风险与失败条件

- **稀有危害欠探索：**学生不访问的攻击族不会因 on-policy 自动出现；必须混入红队/固定长尾数据。
- **早期学生过弱：**低质量 rollout 会浪费教师预算；通常从 SFT 学生开始并逐步提高 on-policy 比例。
- **散度病态：**forward KL 可出现大梯度，reverse KL 可坍缩；需要梯度监控、温度/截断和散度消融。
- **教师偏差被放大：**教师在学生异常前缀上的判断可能更不可靠，且自蒸馏无法创造教师本身没有的安全能力。
- **白盒要求：**逐 token KL 通常需要教师 logits、兼容 tokenizer/vocabulary 与较高显存；仅有闭源 API 时更适合序列级偏好或标签蒸馏。
- **训练成本：**学生采样、教师前向和长序列保存可能抵消模型压缩收益。
- **数据治理：**安全 rollout 可能包含有害内容或隐私，必须记录来源、过滤、保留期限与访问权限。
- **校准漂移：**更像教师的生成分布不等于固定 FPR 下更安全，必须独立校准判定阈值。

## 最低评测协议

- **质量：**macro/micro F1、AUPRC、固定 FPR recall、每危害类别与 worst-group recall、ECE；生成式 Guard 另测判定一致性、解释正确性和证据忠实度。
- **鲁棒性：**时间外样本、jailbreak/混淆、稀有危害、OCR/小目标/跨模态组合与学生未见前缀。
- **训练效率：**学生 rollout tokens、教师前向 tokens/调用数、总 GPU 时、峰值显存、缓存复用率和 wall-clock。
- **部署效率：**time-to-verdict、完整解释 P50/P95、吞吐、峰值内存；与静态 KD、困难样本蒸馏和直接 SFT 等预算基线比较。
- **消融：**固定/学生数据比例，forward/reverse/JSD/skew KL，完整/前缀 rollout，教师条件，类别配额与 rollout 刷新周期。

## 证据边界

- GKD、MiniLLM 与 DistiLLM 系列主要验证通用生成、指令与推理任务；它们支持机制，不直接证明安全 Guard 收益。
- OPSA 提供直接安全对齐证据，但为单篇预印本，且使用生成式推理模型与自动安全评估器；不能据此宣称独立安全分类器或多模态 Guard 已有成熟结论。
- 当前可提出“在可生成归因的 Guard 上验证风险条件 OPD”为候选研究方向；在取得直接基线前，不升级为确定性 Motivation。

## 关系与继续阅读

- 项目综合：[[LLM-Wiki/research/safety-classifier-compression/overview.md]]
- 技术路线：[[LLM-Wiki/research/safety-classifier-compression/landscape.md]]
- 候选缺口：[[LLM-Wiki/research/safety-classifier-compression/gaps.md]]
- 待验证假设：[[LLM-Wiki/research/safety-classifier-compression/hypotheses.md]]

