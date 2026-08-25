---
id: 20260825-safety-decoder-prune-kd-05b
type: experiment
tags: [experiment, data, research, method]
status: draft
created: 2026-08-25
updated: 2026-08-25
title: 0.5B Decoder-only Guard 的校准、结构剪枝与蒸馏恢复
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-muralidharan-2024-minitron]
---

# 实验一：0.5B Decoder-only Guard 的标准校准、剪枝与蒸馏恢复

> 本文是独立、可执行的预注册实验说明，不依赖另外两个实验文档，不包含代码，也没有运行结果。执行前必须冻结模型、数据、软件和硬件的不可变版本。

## 1. 目的与假设

### 研究问题

在不生成或增广任何训练样本的条件下，能否从一个约 1B 的成熟 decoder-only Guard 出发，经任务数据校准和一次性结构剪枝得到约 0.5B 学生，再用冻结的 8B Guard 在同一开源训练集上做离线蒸馏恢复，同时保持安全分类召回并改善单样本和 batch 推理效率？

### 主假设

相对未剪枝的约 1B 任务适配模型，蒸馏恢复后的 0.5B 学生：

1. 三个测试集等权 macro recall 下降不超过 2.0 个百分点；
2. unsafe recall 下降不超过 3.0 个百分点；
3. 相对“剪枝后仅用 hard label 恢复”的同规模基线，macro recall 至少提高 1.0 个百分点；
4. 在同一块 GPU、BF16、相同输入集合上，batch=1 中位模型推理时延至少降低 25%，batch=32 吞吐率至少提高 1.30×。

本实验为确认性设计。若任何指标未达到，不追加数据、不更换测试集、不进行样本增广，只报告负结果。

## 2. 模型配置

| 角色 | 冻结选择 | 用途 |
|---|---|---|
| 教师 T8 | `meta-llama/Llama-Guard-3-8B`，BF16 | 8B 质量基线；为训练集产生两类 soft targets |
| 剪枝起点 S1 | `meta-llama/Llama-Guard-3-1B`，BF16 | 先做统一任务适配，再校准和剪枝 |
| 目标学生 S0.5 | S1 的结构化 dense 子网，0.50B ±2% 参数 | 主实验模型 |

参数量必须按实际可训练/推理权重张量去重计数，并明确 input embedding 与输出头是否共享。只接受能由普通 dense kernel 执行的结构化形状，不把非结构稀疏率当作“0.5B”。

### 目标形状确定规则

- 允许剪枝轴：Transformer 层、attention heads/KV heads、MLP intermediate width；输出仅保留安全分类所需的两类 head，不保留完整生成词表 head。
- 预注册候选网格：层数 `{8,10,12,14}`，hidden width `{1280,1536,1792}`，MLP width `{3072,3584,4096,4608}`，attention head dim 固定 64，KV heads 取 `{4,8}` 中与形状兼容者；hidden/MLP width 均保持 dense-kernel 友好的 256 倍数。
- 候选 hidden/MLP/head 数必须为目标实现的硬件友好倍数；在读取任何 dev/test 质量前，仅按“参数量最接近 0.50B且不超过 0.51B”选定唯一形状。
- 校准数据只决定保留哪些层、head 和 MLP channels，不决定目标参数量。
- 不做量化、LoRA、非结构稀疏或动态 early exit，避免混淆剪枝收益。

## 3. 数据与固定划分

三个实验均使用相同的原始样本、标签映射、哈希划分、最大长度和测试清单；本文件完整重述，不要求读取其他实验。

### 训练与校准

- 数据：`allenai/wildguardmix` 的 `wildguardtrain` 配置，使用 prompt harmfulness 标签；数据为 ODC-BY，并需接受 Ai2 Responsible Use Guidelines。
- 任务：仅做英文 prompt-level 二分类，`harmful → unsafe`，`benign → safe`。不使用 response refusal 或 response harmfulness 标签，避免混合不同任务定义。
- 清理：只做 Unicode NFC、首尾空白清理和精确文本哈希去重；标签冲突的重复 prompt 全部剔除。不进行改写、翻译、合成、反事实生成或困难样本增广。
- 划分：按 prompt SHA-256 分组并以 seed 42 做 label-stratified 90%/5%/5% 划分：`train-kd`、`dev-threshold`、`prune-calibration`。同一 prompt 只能进入一个集合。
- `prune-calibration` 只收集激活与剪枝重要性，不参与梯度更新；若该 5% 超过 4,096 条，则分层固定抽取 4,096 条。
- `dev-threshold` 只用于 checkpoint 选择、temperature scaling 和二分类阈值，不用于剪枝排序。

### 独立测试集

| 数据集 | 固定 split/标签 | 作用 |
|---|---|---|
| WildGuardMix `wildguardtest` | prompt harmfulness | 同来源测试与对抗/普通 prompt 覆盖 |
| `lmsys/toxic-chat` 官方 test | `toxicity` 二值标签 | 真实对话分布外测试；CC-BY-NC-4.0 |
| XSTest 官方 450 prompts | `contrast_* → unsafe`，其余 → safe | 过度拒绝与近边界安全 prompt；CC-BY-4.0 |

三个测试集分别报告，不把不同标签语义直接池化；综合分数是三个测试集 macro recall 的等权平均。训练、校准和阈值选择均不得查看测试标签。

## 4. 统一输入与输出

- 原始语义模板固定为：`User content: {prompt}\nTask: classify the user content as safe or unsafe.`
- Decoder 使用官方 chat template 包装同一语义文本；最大序列长度 512，右截断，记录截断率。
- 预测分数是二类 head 的 softmax `P(unsafe)`；不调用自由生成，以避免输出长度污染分类时延。
- 教师 soft target 是 Llama Guard 3-8B 在同一输入上首个判定位置的 `safe/unsafe` 概率，经二类归一化后离线缓存。教师不得生成新 prompt 或新标签文本。

## 5. 实验流程

### Phase A：版本冻结与功能检查

记录教师/起点 checkpoint revision、权重哈希、tokenizer/chat template、数据 revision 与文件哈希、Transformers/PyTorch/CUDA/cuDNN、GPU/driver、编译设置和随机种子。先用 32 条不进入正式统计的训练样本检查标签映射、两类概率和计时同步。

### Phase B：1B 起点任务适配

在 `train-kd` 上仅用 hard-label cross-entropy 训练 S1。保存每个 seed 的 best-dev checkpoint；T8 全程冻结。

### Phase C：校准与一次性结构剪枝

1. 在 `prune-calibration` 上运行已适配 S1；
2. 层以 block 输入/输出差异衡量冗余，head 与 MLP channel 以平均绝对激活乘对应权重范数排序；
3. 依目标形状一次性删除最低重要性结构；
4. 剪枝后立即评测 dev，记为 `S0.5-pruned-zero-recovery`，但不据此改变形状。

只允许一次结构选择。若出现维度不合法或模型无法前向，记录为设计失败，不用测试集反复搜索结构。

### Phase D：恢复对照

从同一个剪枝后 checkpoint 分出：

- `S0.5-hard`：仅 hard-label CE 恢复；
- `S0.5-KD`：相同训练步数，使用 CE + 二类 Logit KD。

两者使用完全相同样本顺序、batch、优化器、seed 和 checkpoint 选择规则。这样 KD 收益不会与额外训练步数混淆。

### Phase E：温度与阈值校准

对 T8、S1、S0.5-hard、S0.5-KD 分别在 `dev-threshold` 上拟合单一 temperature。主结果使用使 dev balanced accuracy 最大的阈值；同时报告固定阈值 0.5，防止校准掩盖排序能力下降。

## 6. 训练超参数

以下值在三个实验中保持一致；encoder 与 decoder 不因结果而单独调参。

| 项目 | 固定值 |
|---|---|
| Seeds | 13、42、2026 |
| 精度 | BF16；不量化 |
| 最大序列长度 | 512 |
| 优化器 | AdamW，betas=(0.9, 0.95)，eps=1e-8 |
| 学习率 | 2e-5 |
| Weight decay | 0.1；bias/norm 不衰减 |
| Scheduler | cosine decay，warmup ratio 0.05 |
| Global batch | 128 sequences；用 gradient accumulation 保持不变 |
| Epochs | 起点任务适配 3；剪枝恢复 3 |
| Gradient clipping | global norm 1.0 |
| KD loss | $0.5\,CE(y,p_S)+0.5\,T^2 KL(p_T^T\|p_S^T)$ |
| KD temperature | T=2.0 |
| Checkpoint 选择 | dev macro recall 最大；并列取 dev NLL 更小者 |

教师 logits 对每条 `train-kd` 样本只计算一次并冻结缓存；三个 seeds 共用同一缓存，避免教师随机性和重复成本。

## 7. 对照组

| ID | 模型 | 作用 |
|---|---|---|
| B0 | T8 | 8B 教师质量与时延上界 |
| B1 | S1-adapted | 剪枝前约 1B 基线 |
| B2 | S0.5-pruned-zero-recovery | 量化纯剪枝损伤 |
| B3 | S0.5-hard | 控制相同恢复训练但无 KD |
| M1 | S0.5-KD | 主方法 |

## 8. 指标与统计

### 分类指标

- 主指标：unsafe recall $TP/(TP+FN)$；macro recall = unsafe recall 与 safe recall 的算术平均。
- 辅助：safe recall、FPR、precision、F1、AUPRC、ECE 和每数据集 confusion matrix。
- 报告三个 seeds 的均值、标准差和逐 seed 数值；固定样本 paired bootstrap 2,000 次给出 M1 相对 B1/B3 的 95% CI。

### 单样本推理时延

- 硬件：单张 NVIDIA A100 80GB，模型独占 GPU，BF16，无 CPU/disk offload。
- 固定 1,024 条 WildGuardTest timing subset，按标签和长度四分位分层；所有模型使用相同样本顺序。
- batch=1，预热 50 次，正式 5 轮；每次 CUDA synchronize。主报 model-forward P50/P95，另报包含 tokenizer 与 H2D 的端到端 P50/P95。

### Batch 时延与吞吐

- batch=32，按长度 bucket 后动态 padding；预热 20 batches，正式至少 100 batches。
- 报告 batch latency P50/P95、samples/s、有效 input tokens/s、峰值显存。
- 吞吐率定义为正式样本总数除以同步 wall-clock；不把 padding token 当有效 token。

## 9. 成功标准与停止条件

只有同时达到第 1 节四项标准才记为“成功”。达到质量但未达到真实时延/吞吐标准，结论写为“参数压缩成功、系统加速未兑现”。

- 总预算上限：72 A100-GPU-hours；最多三个预注册 seeds，不追加第四 seed。
- 任一阶段 NaN：降低动态 loss scale 后允许重试一次，不改学习率；再次失败则记录并停止该 seed。
- OOM：只允许降低 per-device batch 并增加 gradient accumulation，global batch 仍为 128；再次 OOM 停止。
- 三个 seeds 完成或预算耗尽即停止；不基于测试结果换数据、阈值规则、结构或超参数。

## 10. 原始结果与证据状态

尚未执行。未来每个 seed 必须保存不可覆盖的实际配置、模型参数统计、校准排序、教师缓存清单、逐样本预测、计时原始值、训练日志和失败记录。当前所有数字均为预注册阈值，不是实验结果。

## 11. 限制

- 只验证英文 prompt harmfulness，不覆盖 response safety、多标签 taxonomy 或多模态输入。
- 不包含样本增广，因此不能回答长尾合成数据是否改善安全性。
- 0.5B 形状由 1B 架构约束；参数量接近不保证 kernel 高效，必须以真实时延验收。
- Llama Guard 权重受 Llama 许可证约束；数据虽公开，WildGuardMix 仍需接受负责任使用条款，ToxicChat 为非商业许可证。

## 12. 关联实体与一次来源

- [[LLM-Wiki/research/safety-classifier-compression/overview.md]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2024-fedorov-llama-guard-int4.md]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2024-muralidharan-minitron.md]]
- 模型：[Llama Guard 3-8B](https://huggingface.co/meta-llama/Llama-Guard-3-8B)、[Llama Guard 3-1B](https://huggingface.co/meta-llama/Llama-Guard-3-1B)
- 数据：[WildGuardMix](https://huggingface.co/datasets/allenai/wildguardmix)、[ToxicChat](https://huggingface.co/datasets/lmsys/toxic-chat)、[XSTest](https://github.com/paul-rottger/xstest)
