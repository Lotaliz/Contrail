---
id: 20260825-safety-encoder-prune-kd-03b
type: experiment
tags: [experiment, data, research, method]
status: active
created: 2026-08-25
updated: 2026-08-26
title: 0.3B Encoder-only Guard 的校准、深度剪枝与蒸馏恢复
project_id: safety-classifier-compression
sources: [paper-lee-2025-harmaug, paper-palo-2024-pgkd, paper-muralidharan-2024-minitron]
---

# 实验三：0.3B Encoder-only Guard 的标准校准、剪枝与蒸馏恢复

> 本文是独立实验说明，不使用其他实验的模型或结果。它完整定义自己的数据、教师缓存、校准、剪枝、蒸馏和评测，不包含代码。实验已执行（seed 42），结果见第 10 节。

## 1. 目的与假设

### 研究问题

在相同开源 prompt-safety 数据、训练超参数和 8B 教师下，把目标架构改为成熟的 encoder-only 分类器，能否从 DeBERTa-v3-large 经任务适配、校准和结构化深度剪枝得到约 0.3B 模型，再通过离线 Logit KD 恢复分类召回，并获得更低时延与更高 batch 吞吐？

### 主假设

相对未剪枝的 DeBERTa-v3-large 任务适配基线，0.3B-KD：

1. 三测试集等权 macro recall 下降不超过 2.0 个百分点；
2. unsafe recall 下降不超过 3.0 个百分点；
3. 相对同规模 hard-only 恢复基线，macro recall 至少提高 1.0 个百分点；
4. 相对 8B decoder-only 教师，batch=1 中位模型时延至少降低 60%，batch=32 吞吐率至少提高 2.0×。

## 2. 模型配置

| 角色 | 冻结选择 | 用途 |
|---|---|---|
| 教师 T8 | `meta-llama/Llama-Guard-3-8B`，BF16 | 两类 soft targets 与质量/时延参照 |
| Encoder 起点 E0.435 | `microsoft/deberta-v3-large` + 二类分类头 | 约 435M 总参数；24 层、hidden 1024 |
| 目标 E0.3 | 校准后保留 14/24 Transformer 层的 dense encoder | 目标约 0.30B，允许 0.28–0.32B |

DeBERTa-v3-large 官方说明 backbone 约 304M，128K embedding 约 131M。保留 14/24 层时，静态估算约为 $131M+304M\times14/24\approx308M$；执行前必须用实际 checkpoint 去重计数确认，若超出 0.32B 则保持 14 层并对 MLP channels 做最小幅度硬件对齐结构剪枝，不能通过删除词表 token 改变输入覆盖。

本实验只用结构化层/必要的 MLP width 剪枝；不使用非结构稀疏、量化、LoRA 或动态 early exit。

## 3. 数据与固定划分

### 训练与校准

- `allenai/wildguardmix` 的 `wildguardtrain`，仅用 prompt harmfulness；`harmful → unsafe`，`benign → safe`。
- 英文 prompt-level 二分类。只做 Unicode NFC、首尾空白清理与精确 prompt 哈希去重；标签冲突的重复项全部剔除。
- 禁止教师生成、样本改写、翻译、合成、反事实或 hard-negative 增广。
- seed 42，按 prompt SHA-256 分组并标签分层划分 90% `train-kd`、5% `dev-threshold`、5% `prune-calibration`；校准集最多 4,096 条。
- `prune-calibration` 只采集激活；`dev-threshold` 只做 checkpoint、temperature 和阈值选择。

### 测试集

| 数据集 | 标签 | 用途 |
|---|---|---|
| WildGuardMix `wildguardtest` | prompt harmfulness | 同来源测试 |
| ToxicChat 官方 test | toxicity | 真实分布外测试 |
| XSTest 450 prompts | `contrast_*` 为 unsafe | 近边界/过度拒绝测试 |

三个测试集单独报告，等权汇总；测试标签从不用于训练、剪枝或阈值拟合。许可证分别为 ODC-BY、CC-BY-NC-4.0、CC-BY-4.0。

## 4. 输入与跨架构蒸馏

- 统一语义模板：`User content: {prompt}\nTask: classify the user content as safe or unsafe.`
- Encoder 使用自身 tokenizer，最大 512 tokens、右截断，以首位置 pooled representation 接二类线性 head。
- T8 使用官方 chat template处理同一语义输入；教师 soft target 是首个判定位置的二类 `safe/unsafe` 归一化概率。
- 只蒸馏二类概率，不对齐 hidden states、attention、token logits 或 tokenizer，因此不要求 encoder 与 decoder 词表相同。
- 教师在固定 `train-kd` 上离线前向一次；不生成任何新输入或自然语言标签。

## 5. 实验流程

### Phase A：Encoder 任务适配

为 E0.435 添加二类 head，在 `train-kd` 上用 hard-label CE 训练 3 epochs，保存 best-dev checkpoint。

### Phase B：校准与深度剪枝

1. 在 `prune-calibration` 上记录每层输入/输出 representation；
2. 以 block 输入—输出余弦距离的均值衡量层冗余，距离越小越优先删除；
3. 一次性删除 10 个最低重要性层，但不得删除首层和末层，最终保持原有层顺序；
4. 若实际参数量仍超过 0.32B，仅按 activation×weight-norm 删除达到目标所需的最少 MLP channels；
5. 不恢复即评测 dev，记录 `E0.3-pruned-zero-recovery`，不据此重选层。

### Phase C：恢复对照

- `E0.3-hard`：从剪枝 checkpoint 用 hard CE 恢复；
- `E0.3-KD`：相同步数和样本顺序，采用 $0.5CE+0.5T^2KL$。

### Phase D：概率校准

对 T8、E0.435、E0.3-hard、E0.3-KD 分别在 `dev-threshold` 上拟合单 temperature；主阈值取 dev balanced accuracy 最大点，同时报告固定 0.5 阈值。

## 6. 训练超参数

| 项目 | 固定值 |
|---|---|
| Seeds | 13、42、2026 |
| 精度 | BF16 |
| 最大长度 | 512 |
| Optimizer | AdamW，betas=(0.9,0.95)，eps=1e-8 |
| Learning rate | 2e-5 |
| Weight decay | 0.1，bias/norm 除外 |
| Scheduler | cosine，warmup ratio 0.05 |
| Global batch | 128 sequences |
| Epochs | E0.435 适配 3；E0.3 恢复 3 |
| Gradient clipping | 1.0 |
| KD loss | CE:KL=0.5:0.5，T=2.0 |
| Checkpoint | dev macro recall 最大；并列取 NLL 更低者 |

这些设置与 decoder 实验采用同一主协议，不为 encoder 额外搜索更高学习率或更长训练，以防训练预算差异混入架构比较。

## 7. 对照组

| ID | 模型 | 作用 |
|---|---|---|
| B0 | T8 | 8B decoder-only 教师参照 |
| B1 | E0.435-adapted | encoder 剪枝前基线 |
| B2 | E0.3-pruned-zero-recovery | 纯剪枝损伤 |
| B3 | E0.3-hard | 同训练量无 KD 基线 |
| M1 | E0.3-KD | 主模型 |

## 8. 指标与系统评测

### 分类

- unsafe recall、safe recall、macro recall；辅报 FPR、precision、F1、AUPRC、ECE 和 confusion matrix。
- 每测试集单报，再做三数据集等权汇总。
- 三 seeds 均值/标准差；paired bootstrap 2,000 次报告 M1 相对 B1/B3 的 95% CI。

### 单样本时延

- 单张 NVIDIA A100 80GB、BF16、模型独占、无 offload。
- 固定 1,024 条 WildGuardTest timing subset，按标签和长度四分位分层；batch=1。
- 预热 50 次，正式 5 轮，CUDA synchronize；报告 model-forward 与包含 tokenizer/H2D 的 E2E P50/P95。

### Batch 时延与吞吐

- batch=32，长度 bucket + dynamic padding；预热 20 batches，正式至少 100 batches。
- 报告 batch latency P50/P95、samples/s、有效 tokens/s、峰值显存。
- 对 T8 也只计算二类判定位置，不生成解释，以使任务输出一致；仍分别注明 tokenizer 和架构差异。

## 9. 成功标准、预算和停止条件

仅当第 1 节四项同时满足才记为成功。若 encoder 质量更好但未达到参数目标或时延目标，不宣称压缩成功。

- 预算上限：72 A100-GPU-hours；最多三个 seeds。
- OOM 仅调整 per-device batch 与 accumulation，global batch 固定 128；一次重试后停止。
- NaN 仅允许调整动态 loss scale 后重试一次；不改学习率。
- 不用测试集重选 14 层结构、训练轮数或阈值；不追加样本和超参搜索。

## 10. 原始结果与限制

### 执行环境

- 种子：42（预注册 13、42、2026，实际仅执行 seed 42）
- GPU：NVIDIA H20-3e（144 GB），非预注册 A100 80GB
- 软件：transformers 4.57.6、PyTorch 2.10.0+cu128、CUDA 12.8、BF16
- 代码位置：`/home/ljm534318/safety-exp/`（Contrail 目录外）
- 结果文件：`results/exp3_seed42.json`

### 剪枝信息

| 参数 | 值 |
|---|---|
| 原始层数 | 24 |
| 保留层数 | 14 |
| 删除层 | [6, 7, 8, 9, 10, 14, 15, 18, 19, 21] |
| 原始参数量 | 435.1M |
| 剪枝后参数量 | 309.1M |
| MLP 剪枝 | 否（14 层已在目标范围内） |

### 分类结果（seed 42，修复后）

| 模型 | WildGuardTest macro | ToxicChat macro | XSTest macro | 等权 macro |
|---|---|---|---|---|
| B0 (T8) | 0.8070 | 0.7363 | 0.8990 | 0.8141 |
| B1 (E0435-adapted) | 0.8713 | 0.8591 | 0.8915 | 0.8740 |
| B2 (pruned-zero) | 0.5000 | 0.5000 | 0.5000 | 0.5000 |
| B3 (hard) | 0.8317 | 0.8278 | 0.7240 | 0.7945 |
| M1 (KD) | 0.8219 | 0.8242 | 0.7530 | 0.7997 |

Encoder 适配后 B1 表现优秀（macro=0.8740），与修复后的 decoder B1（0.9000）相当，均高于 T8（0.8141）。剪枝后未恢复即坍缩为全 unsafe（B2=0.5000）。Hard 恢复后质量大幅回升（B3=0.7945），KD 恢复略优于 hard（M1=0.7997），但仍未达到预注册的 +1.0 pp KD 增益（实际 +0.5 pp）。XSTest 是主要弱点：B1 unsafe_recall=0.815，M1 降至 0.570，下降 24.5 pp。

> 本实验教师缓存与 T8 评测直接受益于实验一/二修复后的 Llama Guard 输入构造与判定位置逻辑；原始运行中 T8 被错误实现为 token 级分类器，导致教师信号失真。

### 时延与吞吐（seed 42，修复后）

| 模型 | batch=1 P50 (ms) | batch=32 P50 (ms) | samples/s | 峰值显存 (GB) |
|---|---|---|---|---|
| B0 (T8) | 37.0 | 1,859.5 | 17.6 | 32.7 |
| M1 (KD) | 13.2 | 59.9 | 547.7 | 32.7 |

### 成功标准评估（修复后）

| 标准 | 阈值 | 实际 | 结果 |
|---|---|---|---|
| macro recall 下降 | ≤2.0 pp | -7.4 pp（B1=0.8740→M1=0.7997） | 失败 |
| unsafe recall 下降 | ≤3.0 pp | XSTest -24.5 pp（0.815→0.570） | 失败 |
| KD vs hard macro | ≥+1.0 pp | +0.5 pp（M1=0.7997 vs B3=0.7945） | 失败 |
| batch=1 时延降低 | ≥60% | 64.4% | 达标 |
| batch=32 吞吐提升 | ≥2.0× | 31.2× | 达标 |

### 结论（修复后）

部分结果。修复 T8 实现错误后，encoder 学生仍保持高质量：B1=0.8740，M1=0.7997，相对同规模 decoder M1（0.6106）优势明显，说明 encoder 架构对深度剪枝更鲁棒。时延目标全部达标（batch=1 降低 64.4%，batch=32 提升 31.2×）。但深度剪枝后质量下降仍超过预注册阈值（macro -7.4 pp），KD 相对 hard 仅 +0.5 pp、未达 +1.0 pp 目标，且 XSTest unsafe_recall 下降 24.5 pp。质量未达标，不能宣称压缩成功。

### 偏差

- 仅执行 seed 42，未完成预注册的 13 和 2026 seeds。
- GPU 为 H20-3e（144 GB），非预注册 A100 80GB；时延数值不可直接与 A100 结果比较。
- 未执行 paired bootstrap CI（需多 seed）。

### 限制

只做 prompt 二分类；跨架构 KD 只迁移两类决策分布而非内部表征；DeBERTa 的大词表 embedding 限制进一步压缩；ToxicChat 非商业许可证；模型时延仍依赖 tokenizer、长度分布和具体 kernel。

## 11. 关联实体与一次来源

- [[LLM-Wiki/research/safety-classifier-compression/overview.md]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2025-lee-harmaug.md]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2024-palo-pgkd.md]]
- 模型：[Llama Guard 3-8B](https://huggingface.co/meta-llama/Llama-Guard-3-8B)、[DeBERTa-v3-large](https://huggingface.co/microsoft/deberta-v3-large)
- 数据：[WildGuardMix](https://huggingface.co/datasets/allenai/wildguardmix)、[ToxicChat](https://huggingface.co/datasets/lmsys/toxic-chat)、[XSTest](https://github.com/paul-rottger/xstest)

