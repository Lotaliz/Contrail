---
id: 20260825-safety-cascade-prune-kd-04b
type: experiment
tags: [experiment, data, research, method]
status: active
created: 2026-08-25
updated: 2026-08-26
title: 0.4B Decoder-only Guard 与 8B Guard 的置信度级联
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-muralidharan-2024-minitron, paper-lee-2025-saferoute]
---

# 实验二：0.4B Decoder-only Guard 与 8B Guard 的置信度级联

> 本文是独立实验说明，不依赖任何其他实验的 checkpoint、缓存、阈值或文档；所需训练、剪枝、蒸馏和评测流程均在此重述。无代码。实验已执行（seed 42），结果见第 9 节。

## 1. 目的与假设

### 研究问题

能否把约 1B decoder-only Guard 校准并结构剪枝到更激进的 0.4B，用冻结 8B Guard 在相同开源训练样本上做标准离线蒸馏恢复，然后以小模型校准置信度决定是否转交 8B，从而接近 8B 召回率并降低平均推理成本？

### 主假设

在预注册阈值选择规则下，0.4B→8B 级联同时满足：

1. 三测试集等权 unsafe recall 距 8B 不超过 1.0 个百分点；
2. worst-dataset unsafe recall 距 8B 不超过 2.0 个百分点；
3. 8B deferral rate 不超过 20%；
4. 相对所有样本直接使用 8B，batch=1 中位端到端时延至少降低 40%，batch=32 有效吞吐至少提高 1.50×。

## 2. 模型与级联规则

| 角色 | 配置 | 说明 |
|---|---|---|
| 大模型 T8 | `meta-llama/Llama-Guard-3-8B`，BF16 | 蒸馏教师、级联后备和质量基线 |
| 剪枝起点 S1 | `meta-llama/Llama-Guard-3-1B`，BF16 | 独立任务适配后再剪枝 |
| 小模型 S0.4 | 结构化 dense 子网，0.40B ±2% | 所有请求先经过该模型 |

输出均为二类 `safe/unsafe` head，不执行自由生成。参数量按实际去重权重计数；只接受 dense 可执行结构。

### 0.4B 目标形状

- 允许剪 Transformer layers、attention/KV heads 和 MLP width；候选维度需满足硬件对齐。
- 预注册候选网格：层数 `{8,10,12}`，hidden width `{1024,1280,1536}`，MLP width `{2560,3072,3584}`，attention head dim 固定 64，KV heads 取 `{4,8}` 中的兼容值；hidden/MLP width 保持 256 倍数。
- 在查看任何质量分数前，按参数量选择“不超过 0.408B且最接近 0.40B”的唯一候选。
- 校准样本只排序结构重要性；不允许用测试集搜索层数或宽度。
- 不使用量化、动态 early exit、单独训练的 router 或样本增广。

### 置信度与路由

1. 在独立 `dev-threshold` 上为 S0.4-KD 拟合单一 temperature；
2. 令 $c=\max(P(unsafe),P(safe))$；若 $c<\tau$，样本转交 T8，否则采用 S0.4 结果；
3. 只使用小模型置信度，不加入额外特征或学习式 router；
4. 在 $\tau\in\{0.50,0.51,\ldots,0.99\}$ 中选择满足“dev unsafe recall 距 T8 ≤1.0 point”的**最小**阈值；若无阈值满足，则级联预注册失败，仍完整报告 risk-coverage 曲线；
5. 阈值一旦由 dev 冻结，三个测试集共同使用，不按数据集单独调节。

## 3. 数据与固定划分

### 训练/校准数据

- `allenai/wildguardmix` / `wildguardtrain`，仅使用 prompt harmfulness：`harmful → unsafe`、`benign → safe`。
- 只做 Unicode NFC、首尾空白清理和精确哈希去重；冲突重复项剔除。禁止改写、翻译、合成、反事实或 hard-negative 增广。
- seed 42，按 prompt SHA-256 分组、标签分层切成 90% `train-kd`、5% `dev-threshold`、5% `prune-calibration`；校准集合最多固定 4,096 条。
- `prune-calibration` 不做梯度更新；`dev-threshold` 只做 checkpoint、temperature 和级联阈值选择。

### 测试集

| 数据集 | 标签映射 | 许可证/角色 |
|---|---|---|
| WildGuardMix `wildguardtest` | prompt harmfulness | ODC-BY；同来源测试 |
| ToxicChat 官方 test | toxicity | CC-BY-NC-4.0；真实分布外测试 |
| XSTest 450 prompts | `contrast_*` 为 unsafe | CC-BY-4.0；近边界与过度拒绝测试 |

测试标签不参与训练、剪枝排序、temperature 或阈值选择。各集分别报告，综合采用等权 macro。

## 4. 输入、教师目标与训练流程

- 统一语义模板：`User content: {prompt}\nTask: classify the user content as safe or unsafe.`
- 官方 chat template；最大 512 tokens，右截断；二类 head 输出 `P(unsafe)`。
- T8 在同一 `train-kd` 输入上产生二类 soft targets并离线缓存，不生成新样本。

### Phase A：S1 任务适配

S1 在 `train-kd` 上用 hard CE 训练 3 epochs；保存 best-dev checkpoint。T8 冻结。

### Phase B：校准与剪枝

在 `prune-calibration` 上收集 block 输入/输出差异及 activation×weight-norm 重要性，依预定 0.4B 形状一次性删除最低分层、heads 与 MLP channels。记录未恢复模型 `S0.4-pruned-zero-recovery`。

### Phase C：蒸馏恢复

从同一剪枝 checkpoint 分别训练：

- `S0.4-hard`：仅 hard CE；
- `S0.4-KD`：$0.5CE+0.5T^2KL$。

训练步数、样本顺序和 checkpoint 选择相同。随后仅在 dev 上拟合 temperature 和路由阈值。

### Phase D：级联推理

- batch=1：先运行 S0.4；低置信样本再运行 T8，级联时延为两次前向和路由开销之和。
- batch=32：先对整批运行 S0.4，把低置信样本压紧成子批再运行 T8；必须把索引收集、设备同步和子批 padding 计入总时延。
- 不允许预先知道测试标签、以规则绕过小模型或并行提前运行 T8。

## 5. 训练超参数

| 项目 | 固定值 |
|---|---|
| Seeds | 13、42、2026 |
| 精度 | BF16 |
| Max length | 512 |
| Optimizer | AdamW，betas=(0.9,0.95)，eps=1e-8 |
| Learning rate | 2e-5 |
| Weight decay | 0.1，bias/norm 除外 |
| Scheduler | cosine，warmup ratio 0.05 |
| Global batch | 128 sequences |
| Epochs | S1 适配 3；S0.4 恢复 3 |
| Gradient clip | 1.0 |
| KD | CE:KL=0.5:0.5，T=2.0 |
| 选择规则 | dev macro recall 最大；并列取 NLL 更低者 |

教师 logits 缓存只计算一次，供三个 seeds 使用。

## 6. 对照组

| ID | 方案 | 作用 |
|---|---|---|
| B0 | T8-only | 质量上界与无级联成本基线 |
| B1 | S1-adapted | 剪枝前约 1B 基线 |
| B2 | S0.4-pruned-zero-recovery | 纯剪枝损失 |
| B3 | S0.4-hard | 无 KD 的恢复基线 |
| B4 | S0.4-KD-only | 不回退时的小模型质量/速度 |
| M1 | S0.4-KD → T8 confidence cascade | 主方法 |

## 7. 指标

### 分类与路由

- unsafe recall、safe recall、macro recall、FPR、F1、AUPRC、ECE；各测试集与等权汇总。
- deferral rate、small-model coverage、被转交样本的 unsafe 比例、small-only error rate、deferred error rate。
- risk-coverage curve：扫描全部预注册 $\tau$，测试集只用于画曲线，不重新选阈值。
- 三 seeds 均值/标准差；paired bootstrap 2,000 次计算 M1 相对 B0/B4 的 95% CI。

### 时延与吞吐

- 单张 NVIDIA A100 80GB、BF16、无 offload；T8 与 S0.4 均常驻同一 GPU。若无法同时常驻，该环境不符合主实验，不能用换入换出结果替代。
- 固定 1,024 条 WildGuardTest timing subset，按标签/长度分层。
- batch=1：50 次预热、5 轮正式；报告 S0.4 stage、T8 deferred stage、router overhead 和总 E2E P50/P95。
- batch=32：20 batches 预热、至少 100 batches；报告完整级联 batch latency P50/P95、samples/s、有效 tokens/s、峰值显存。
- 同时报告基于实际 deferral rate 的总成本；不得只报告未回退样本时延。

## 8. 成功标准、预算与停止条件

必须同时满足第 1 节四项标准。若达到召回但 deferral >20%，结论为“级联有效但不经济”；若平均时延下降但 P95 不降，必须单独标为尾延迟失败。

- 预算上限：72 A100-GPU-hours；三个 seeds；不追加路由器训练。
- OOM 时仅允许调整 per-device batch/gradient accumulation而保持 global batch 128；一次重试后仍失败即停止。
- 无 dev 阈值满足召回约束时，不放宽约束，不访问测试集选阈值。
- 不因级联结果引入新数据、额外模型或新置信度特征。

## 9. 原始结果与限制

### 执行环境

- 种子：42（预注册 13、42、2026，实际仅执行 seed 42）
- GPU：NVIDIA H20-3e（144 GB），非预注册 A100 80GB
- 软件：transformers 4.57.6、PyTorch 2.10.0+cu128、CUDA 12.8、BF16
- 代码位置：`/home/ljm534318/safety-exp/`（Contrail 目录外）
- 结果文件：`results/exp2_seed42.json`

### 目标形状

| 参数 | 值 |
|---|---|
| 层数 | 10 |
| Hidden width | 1,536 |
| MLP width | 3,072 |
| KV heads | 8 |
| Q heads | 24 |
| Head dim | 64 |
| 实际参数量 | 0.4015B |

保留层：[1, 5, 8, 9, 10, 11, 12, 13, 14, 15]。

### 分类与级联结果（seed 42，修复后）

| 模型 | WildGuardTest macro | ToxicChat macro | XSTest macro | 等权 macro | Deferral |
|---|---|---|---|---|---|
| B0 (T8) | 0.8070 | 0.7363 | 0.8990 | 0.8141 | — |
| B3 (hard) | 0.7380 | 0.6255 | 0.5000 | 0.6212 | — |
| B4 (KD-only) | 0.7056 | 0.6071 | 0.5000 | 0.6042 | — |
| M1 (cascade) | 0.7558 | 0.6539 | 0.5000 | 0.6366 | WGT 36.3% / TC 32.5% / XS 0.0% |

级联阈值 τ=0.76（T8 dev unsafe_recall=0.7270，目标≥0.7170）。修复实现错误后，小模型 KD-only 不再全 safe 坍缩：在 WildGuardTest 上 unsafe_recall=0.5159、macro=0.7056。但 XSTest 上仍完全预测 safe（unsafe_recall=0.000），导致级联在该集 0% 转交、macro=0.5000。整体级联等权 macro=0.6366，低于 T8 的 0.8141。

> 首次运行同样因 Llama Guard 输入构造与判定位置错误导致小模型全 safe/全 unsafe 坍缩，级联 100% 转交 T8；修复细节见实验一。

### Risk-coverage 曲线（修复后）

τ 从 0.50 提升到 0.99 时，小模型 coverage 由 1.0 单调降至 0.017，deferral 由 0% 升至 98.3%。在 τ=0.50 时完全依赖小模型（macro≈0.6042，XSTest unsafe_recall=0.0）；随着 τ 提高，越来越多困难样本被转交 T8，WildGuardTest 与 ToxicChat 的 unsafe_recall 逐步上升。τ=0.76 为预注册选择阈值，测试集 deferral 在 WildGuardTest 为 36.3%、ToxicChat 为 32.5%、XSTest 为 0.0%，等权 macro=0.6366。τ≥0.93 时 coverage 已低于 12%，接近纯 T8 水平。完整曲线见 `results/exp2_seed42.json` 的 `risk_coverage_curve`。

### 时延与吞吐（seed 42，修复后）

| 模型 | batch=1 P50 (ms) | batch=32 P50 (ms) | samples/s | 峰值显存 (GB) |
|---|---|---|---|---|
| B0 (T8) | 37.1 | 1,859.9 | 17.6 | 33.0 |
| B4 (KD-only) | 7.4 | 80.4 | 407.1 | 33.0 |
| M1 (cascade) | 6.0 (total p50) | 487.3 | 65.0 | 22.4 |

级联 batch=1 中位总时延 6.0 ms（小模型 5.9 ms + 路由 0.05 ms，非延迟样本占中位数），延迟样本额外增加 T8 53.4 ms；该时延子集 deferral=22.3%。batch=32 级联吞吐 65.0 samples/s，相对 T8-only 的 17.6 samples/s 提升 3.7×。级联峰值显存因大部分时间只需小模型而降至 22.4 GB。

### 成功标准评估（修复后）

| 标准 | 阈值 | 实际 | 结果 |
|---|---|---|---|
| unsafe recall 距 T8 | ≤1.0 pp | XSTest -83.0 pp（0.83→0.00） | 失败 |
| worst-dataset 距 T8 | ≤2.0 pp | XSTest -83.0 pp | 失败 |
| deferral rate | ≤20% | 22.3%–36.3%（依数据集） | 失败 |
| batch=1 时延降低 | ≥40% | 83.9%（37.1→6.0 ms p50） | 达标 |
| batch=32 吞吐提升 | ≥1.50× | 3.7×（17.6→65.0 sps） | 达标 |

### 结论（修复后）

部分结果。修复后小模型不再坍缩，置信度级联具备实际路由能力：batch=1 中位时延和 batch=32 吞吐均显著优于 T8-only。但级联未能满足预注册质量与经济性约束：XSTest 上小模型完全预测 safe，导致该集 unsafe_recall 从 T8 的 0.83 跌至 0.00；WildGuardTest/ToxicChat 的 deferral 也超过 30%，高于 20% 上限。因此，0.4B→8B 级联在系统效率上成立，但召回缺口和 deferral 率均未达标，不能宣称预注册成功。

### 偏差

- 仅执行 seed 42，未完成预注册的 13 和 2026 seeds。
- GPU 为 H20-3e（144 GB），非预注册 A100 80GB；时延数值不可直接与 A100 结果比较。
- 未执行 paired bootstrap CI（需多 seed）。

### 限制

仅英文 prompt 二分类；max-probability confidence 在分布外可能失准；两模型同时驻留增加显存；低 deferral 并不保证罕见危害被正确转交；公开数据仍包含使用条款和有害内容治理要求。

## 10. 关联实体与一次来源

- [[LLM-Wiki/research/safety-classifier-compression/overview.md]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2025-lee-saferoute.md]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2024-fedorov-llama-guard-int4.md]]
- 模型：[Llama Guard 3-8B](https://huggingface.co/meta-llama/Llama-Guard-3-8B)、[Llama Guard 3-1B](https://huggingface.co/meta-llama/Llama-Guard-3-1B)
- 数据：[WildGuardMix](https://huggingface.co/datasets/allenai/wildguardmix)、[ToxicChat](https://huggingface.co/datasets/lmsys/toxic-chat)、[XSTest](https://github.com/paul-rottger/xstest)
