---
id: 20260825-vispco-qwen25vl-small
type: experiment
tags: [experiment, data, research]
status: draft
created: 2026-08-25
updated: 2026-08-25
title: Qwen2.5-VL-3B 上的 VisPCO 小规模配置优化测试
project_id: visual-token-pruning
sources: [paper-ji-2026-vispco, paper-chen-2024-fastv]
---

# Qwen2.5-VL-3B 上的 VisPCO 小规模配置优化测试

> 本文件只定义实验，不包含实验代码，也没有运行结果。执行前必须补全模型、数据和官方仓库的不可变版本标识。

## 目的与假设

### 研究问题

在 Qwen2.5-VL-3B-Instruct 与 FastV importance rule 固定的条件下，VisPCO 学到的 layer-wise retention schedule 能否在相同 50% FLOPs budget 下，比 FastV 默认单点配置、简单 progressive schedule 和小规模随机搜索取得更好的质量—效率折中？

### 主假设 H1

VisPCO 在 A-OKVQA、MMBench、TextVQA 三任务 macro average 上，相对相同预算的 FastV 默认配置提高至少 3 个百分点，同时预算误差不超过 ±2%，TTFT 不比 FastV 恶化超过 5%。

### 次假设 H2

面积平衡的 calibration/training subset 比朴素随机抽样更能保持 TextVQA 与高分辨率样本的性能；收益应主要体现在 OCR/high-resolution slice，而不是所有任务等幅提升。

### 实验性质

探索性 pilot，不用于声称复现论文 Table 1–5，也不用于提升正式 motivation。只有完成三 seed 确认实验后，才能判断结果是否稳定。

## 设计总览

### Phase 0：版本与可运行性冻结

执行前记录：

- Qwen2.5-VL-3B-Instruct checkpoint revision 与文件哈希；
- VisPCO 官方仓库 commit/hash；
- FastV 实现来源与 pruning layer/score 定义；
- Transformers、PyTorch、CUDA、VLMEvalKit 版本；
- 三个 benchmark 的 split、下载校验值、prompt template 与 evaluator；
- GPU 型号、驱动、功耗模式和可用显存。

若无法锁定以上版本，实验保持 `draft`，不产生可比较结果。

### Phase 1：最小功能验证

- 20 个样本：A-OKVQA、MMBench 各 5，TextVQA 10；覆盖低/中/高视觉 token 数。
- 只比较 Full、FastV-50%、一个手工 50% progressive schedule。
- 检查输出可解析、视觉 token 数单调不增、实际 FLOPs 接近预算、无 NaN/OOM、同一输入重复推理结果一致。
- Phase 1 不作性能结论；失败则先记录错误，不扩大数据和算力。

### Phase 2：小规模主测试

#### 模型

- `Qwen2.5-VL-3B-Instruct`，BF16，模型权重冻结。
- FastV 作为唯一 token importance rule；不在本 pilot 同时比较 SparseVLM/FitPrune，以隔离配置效应。
- VisPCO 只训练 ratio predictor；full-token teacher 冻结。

#### Predictor 数据

- 从 LLaVA-Instruct-150K 选择 2,000 个单图样本作为训练/校准集，另留 200 个验证样本。
- 生成两个互斥版本：
  1. `random-2k`：固定 seed 的随机抽样；
  2. `area-balanced-2k`：按处理前图像面积的 log-area 分位数分 8 箱，每箱等量抽样。
- 默认不改变像素内容、不将图片人为 resize 到均匀面积，以避免把“数据分布平衡”和“图像内容重采样”混为一体。若要复核官方 preprocessing script，单列为后续消融。
- 训练与测试图片按原始文件哈希去重；LLaVA-Instruct 样本不得与三个评测集共享同一图像。

#### 评测集

与论文 Table 3 对齐，每个 benchmark 固定 100 个样本，共 300 个：

| Benchmark | 抽样方式 | 作用 |
|---|---|---|
| A-OKVQA | 从指定 validation split 分层抽 100 | 常识与视觉问答 |
| MMBench | 从指定 dev split 按能力类别分层抽 100 | 感知/推理/知识 |
| TextVQA | 从指定 validation split 按图像面积三分位分层抽 100 | OCR 与动态分辨率 |

同一索引清单供所有方法共享，不允许按模型输出重抽样。

#### 对照方法

| ID | 方法 | 目标预算 | 目的 |
|---|---|---:|---|
| B0 | Full Qwen2.5-VL-3B | 100% | 质量与系统上限 |
| B1 | FastV 默认单层配置 | 50% FLOPs | 论文主基线 |
| B2 | Linear progressive schedule | 50% FLOPs | 简单多层配置基线 |
| B3 | Random-8 best-on-validation | 50% FLOPs | 同等小搜索预算基线；测试集只评最终选中配置 |
| V1 | VisPCO + random-2k | 50% FLOPs | 检验配置学习本身 |
| V2 | VisPCO + area-balanced-2k | 50% FLOPs | 检验面积分布平衡 |

只要实际 FLOPs 偏离目标超过 ±2%，该配置不进入主质量比较，先调整 retention schedule。

#### 可选 Phase 3

仅当 V2 达到主成功标准时，再在 30% budget 比较 B1/B2/V2 与 multi-step VisPCO，用于检验论文“低预算下 multi-step 更优”的结论。未经新授权不扩展到八 benchmark、视频或 7B 模型。

## 训练配置（预注册）

- Pilot seed：42；确认阶段 seeds：42、43、44。
- 全局 batch size：16；单卡 batch 由显存决定，用 gradient accumulation 保持全局 batch 不变。
- 优化器：AdamW；首选按 Appendix Table 6 的 Qwen + FastV 设置：lr $10^{-4}$、$\lambda=100$、$\alpha=5$、$\epsilon=0.005$、$\beta=0.5$、$\sigma=10$、$T=0.1$。
- 因论文 §4.1、Table 6 与当前公开脚本不一致，禁止静默换参；任何变更写入实际配置并标注依据。
- 收敛：预算约束连续 3 次验证满足阈值，或达到预设最大 epoch/6 GPU-hours，先到者停止。
- 不允许更新 Qwen 底座、vision encoder 或 LM head；训练参数检查必须确认只有 ratio predictor 可训练。

## 推理与系统测量

- 评测 batch=1，greedy decoding，temperature=0；每个任务固定相同 `max_new_tokens` 和 prompt template。
- 质量评测与时延评测分离：质量使用完整 300 样本；时延从三任务各固定 20 个样本，共 60 个。
- 预热 10 次；每样本重复 5 次。记录 vision encode、prefill/TTFT、decode、E2E、峰值显存与实际输出长度。
- 同一 GPU 串行测试，方法顺序使用固定轮换顺序，避免温度或缓存顺序偏置。
- TTFT 计时必须包含 selector 和 token reindex/filter 开销，不包含数据下载；另报包含图片解码与 processor 的端到端时延。

## 指标与统计分析

### 质量指标

- A-OKVQA：锁定 VLMEvalKit 对应版本的官方 accuracy/answer normalization。
- MMBench：multiple-choice accuracy，并报告 perception/reasoning/knowledge 三类切片。
- TextVQA：锁定 evaluator 后报告官方 score，并按图像面积低/中/高三分位切片。
- 汇总：三任务等权 macro average、relative performance retention，以及相对 B1 的逐任务差值。
- 风险指标：worst-task drop；不能只用 macro average 掩盖 OCR 退化。

### 预算与系统指标

- 解析 FLOPs、实际逐层 retention ratios、视觉 token-area-under-curve；
- TTFT、prefill、decode、E2E 的 median/P95；throughput tokens/s；peak VRAM；selector overhead；
- FLOPs budget error：$|F(r)-0.5F_{full}|/(0.5F_{full})$。

### 统计

- 对固定样本做 paired bootstrap 2,000 次，报告 V1/V2 相对 B1 的 macro 与逐任务 95% CI。
- 系统时延报告样本级 median、P95 与 bootstrap CI；不把同一样本的 5 次重复当作独立任务样本。
- predictor 确认阶段报告三 seed 均值、标准差和每个 seed 的实际预算误差。

## 成功标准

V2 同时满足：

1. 50% FLOPs budget error ≤2%；
2. 三任务 macro average 相对 B1 ≥+3.0 points；
3. 至少 2/3 benchmark 优于 B1，且任一任务不低于 B1 超过 2.0 points；
4. TTFT median 不比 B1 慢超过 5%，selector overhead 已计入；
5. 三 seed 中至少 2 个满足 1–4，且方向一致。

若只满足平均提升但 TextVQA high-resolution slice 明显下降，结论记为“配置优化有效但存在分辨率风险”，不记为成功复现。

## 预算与停止条件

- Pilot 计算上限：6 GPU-hours；模型/数据下载不在本任务执行。
- 单次 OOM：记录配置，只允许一次通过降低 per-device batch、保持 global batch 的重试；仍 OOM 则停止。
- 连续两次出现输出无法解析、FLOPs 偏差 >5% 或 predictor 不收敛，停止并审计实现。
- Phase 2 未达主标准，不进入 Phase 3，不扩大到完整八 benchmark。

## 原始结果

尚未执行。未来运行必须将原始日志、配置、样本索引、逐样本输出和计时结果保存在本实验目录的独立子目录中，不覆盖失败运行。

## 异常、限制与待决策

- **硬件待定：** 论文使用 8×H20 96GB；pilot 的目标 GPU 尚未指定。teacher + student 同驻显存可能要求 ≥48GB 或多卡，不能使用会污染时延的 CPU offload 来做硬件结论。
- **版本待定：** 当前官方仓库有占位路径，并与论文在 30K/10K、面积平衡方式和超参数上存在差异。
- **指标待定：** 必须在执行前锁定 VLMEvalKit commit 和三项 evaluator；否则分数不可与论文直接比较。
- **小样本限制：** 每任务 100 个样本只适合筛选方向，不能证明完整 benchmark 上达到论文结果。

## 关联实体与来源

- [[LLM-Wiki/research/visual-token-pruning/papers/2026-ji-vispco.md|VisPCO 精读笔记]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|视觉模型 Token 剪枝项目]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-chen-fastv.md|FastV]]
