---
id: safety-classifier-compression-comparison
type: synthesis
title: 安全判别剪枝与蒸馏统一比较
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-muralidharan-2024-minitron, paper-sun-2024-wanda, paper-xia-2024-sheared-llama, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-wu-2023-tinyclip, paper-yang-2024-clip-kd, paper-vasu-2024-mobileclip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-ma-2023-llm-pruner, paper-an-2024-flap, paper-zhong-2025-blockpruner, paper-men-2025-shortgpt, paper-shi-2023-upop, paper-sanh-2020-movement-pruning, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety, paper-shen-2025-numerical-pruning]
status: active
created: 2026-08-24
updated: 2026-08-28
---

# 统一比较

> 数字均为作者在各自设置下报告。硬件、batch、序列长度、任务与计时口径不同，不可直接横向排名。

| 方法 | 任务/输入 | 选择信号与层位置 | 预算/目标形状 | 训练需求 | 代表质量—效率证据 | 主要局限 |
|---|---|---|---|---|---|---|
| Llama Guard 3-1B-INT4 | prompt/response 安全；文本 | 结构压缩 + 8B teacher Logit；层/神经元；INT4 QAT | 约 440 MB | 安全 SFT + KD + QAT | 相对 1B BF16 约 7× 更小；Android CPU ≥30 token/s，TTFT ≤2.5s；多数语言 F1 接近 1B | 官方预印本；内部数据；仍是自回归输出 |
| HarmAug | prompt 与 prompt-response 危害二分类 | 教师标签；生成困难有害指令；DeBERTa 全模型 | 71M–435M 学生 | 生成 100k 有害指令并微调 | 435M 平均 F1 0.7357/AUPRC 0.8362；相对 LG3 时延/token 25%、显存 12%、成本 26% | 教师和生成器成本；二分类 taxonomy；攻击演化 |
| SafeRoute | 文本安全级联 | 二分类 router 预测小 Guard 是否会失败 | 大 Guard 使用率阈值 | 训练 router；保留两套 Guard | oracle 在 WildGuardMix 仅 5.09% 走 8B，F1 0.8101，高于单用 1B/8B | 实际路由非 oracle；分布漂移会误路由 |
| MULTIGUARD | 多语言、图像、音频有害 prompt | LLM/MLLM 中间层共有表征 + 轻量分类器 | 选择层/表征 | 训练小分类器 | 作者报告跨语言 +11.57%、图像 +20.44%；复用生成表征时约 120× 更快 | 依赖底座已执行；不等于独立前置 Guard 延迟 |
| PGKD | 工业多类文本分类 | 验证报告 + hard negatives 驱动教师造数 | 1000 初始标注，迭代停止 | 多轮教师生成 + BERT 微调 | GPU 批量 64：0.46s，对 Llama 3 8B 58.05s；最高约 130× | 蒸馏生成昂贵；prompt/教师敏感 |
| P-pruning | GLUE/SQuAD 文本任务 | 任务输入上的 head/neuron 输出聚类与中心选择 | 相对 FLOPs 0.9–0.2 | 先剪后微调 | MNLI 60% FLOPs 约束下 fine-tuning 1.8×；FLOPs 降 40% | BERT/GPT-2 规模；任务特异性强 |
| Minitron | 通用语言模型 | 激活统计排序层、head、neuron、embedding | 15B→8B/4B | 轻量恢复 KD，少量校准 | 派生单个尺寸最高少 40× tokens；模型家族训练成本 1.8×；MMLU 对从头训练最高 +16% | 非安全专测；教师 forward 增加恢复成本 |
| Wanda | 通用 LLM | weight × activation；权重层 | 50% 非结构或 N:M | 免训练 | 低剪枝计算成本，保持困惑度/下游性能 | 无稀疏 kernel 时难转化为时延 |
| Sheared LLaMA | 通用 LLM | 可学习结构 mask；层/head/hidden/FFN | 7B→1.3B/2.7B | 结构搜索 + 动态数据加载恢复 | 作者报告只需从头训练同尺寸约 3% compute | 非安全专测；仍需大规模继续训练 |
| TinyCLIP | 图文零样本分类/检索 | affinity mimic + weight inheritance；双塔宽/深 | 50% 到极限小模型 | 多阶段蒸馏 | 50% ViT-B/32 参数仍接近零样本性能；训练 1.4–7.8×；8.9% 参数模型超过原 CLIP 3.5 点 | 权重继承受架构兼容性影响 |
| CLIP-KD | 图文分类/检索 | feature/logit/relation/gradient/contrastive 对照 | 多种学生架构 | 在 CC3M+12M 训练 | 简单 feature MSE 最稳；ViT-B/16 零样本 ImageNet 达 57.5% | 训练数据和 teacher 差异大，不能只归因 KD |
| MobileCLIP | 图文零样本分类/检索 | 离线 teacher embedding + 合成 captions；移动架构 | S0/S1/S2/B | 一次数据强化，多模型复用 | S2 比此前 ViT-B/16 方案 2.3× 快且更准；学习效率 10–1000×；iPhone batch=1 | 数据强化存储与一次生成成本需摊销 |
| MoPE-CLIP | CLIP 零样本与下游任务 | 跨模态任务性能下降；head/FFN/layer | 先宽后深；pretrain/fine-tune 两阶段 | 剪枝后跨/单模态蒸馏 | 比单模态幅值指标更稳，兼顾预训练与任务压缩 | importance profiling 依赖任务和校准集 |
| SmartTrim | VQA、检索等 VLM 任务 | 每实例 Token 与 head gate；多层 | 动态预算 | gate 训练 + full-path 自蒸馏 | 作者报告 2–3× 加速且性能下降小 | 动态形状、gate 开销与部署 kernel |
| VisionZip | 图像/视频 VLM 理解 | dominant/contextual visual token；输入侧 | 训练自由可调 token 数 | 免训练 | prefill 最多 8×；13B 可快于未压缩 7B | 主要不是安全分类；可能漏 OCR/局部风险 |
| SafeWatch | 视频安全；多标签判定 + 自然语言解释 | 每条 policy 对视频 token 的 cross-attention；LLM 前更新 KV | 最高测试 99% pruning | 多阶段 SFT + 剪枝适应训练 + DPO | 最高剪 90% 时平均性能下降 <1%；SFT 4.6 s→完整系统 3.9 s；PR-95% 时准确率/解释评分明显下降 | 视频专测；平均指标；无归因忠实度与 P95；系统组件耦合 |
| GKD / MiniLLM | 通用自回归生成 | 当前学生 rollout 前缀上的教师 logits；混合 KL 或 reverse KL | 固定/学生数据比例、采样长度 | 学生采样 + 白盒教师前向 | 多任务支持学生状态上的 KD；MiniLLM 加入混合采样与低方差优化 | 非安全专测；教师/学生词表与 logits 访问；弱学生轨迹不稳 |
| DistiLLM / DistiLLM-2 | 指令、代码、偏好、VLM | skew-KL；学生负序列与教师正序列对比 | rollout 刷新与数据课程 | 学生生成、教师监督，可复用历史输出 | DistiLLM 报告相对近期 KD 约 2.5–4.3× 训练提速 | 设置不可跨论文直比；部分历史数据是 off-policy；无 Guard 专测 |
| Prefix OPD | 长推理 | 学生推理前缀上的 reverse-KL 信号 | 截断 prefix 长度 | 部分 rollout + 教师前向 | 作者在 Qwen3 数学/OOD 推理上报告约 2–40× FLOPs 降低且接近完整 OPD | 只证明长推理；短安全标签未必受益 |
| OPSA | 生成式模型安全对齐 | 学生 rollout；特权安全上下文条件下的冻结教师逐 token KL | rollout/安全上下文 | 在线自蒸馏 | 两个模型家族、五个规模；作者报告部分小模型安全—推理权衡提升 | 2026 预印本；非 Guard 分类；依赖潜在安全能力和自动评估器 |

## 选型结论

- 最低在线成本：任务专用 encoder 学生（HarmAug/PGKD 思路）。
- 最低派生模型训练成本：从成熟大模型做结构剪枝并以 KD 恢复（Minitron/Sheared 思路）。
- 最稳定的通用硬件加速：层、宽度、head 等结构化 dense 剪枝。
- 最低压缩准备成本：Wanda 类免训练稀疏，但必须先确认目标硬件的稀疏吞吐。
- 多模态分类：TinyCLIP/CLIP-KD 做关系或特征蒸馏，MoPE-CLIP 做跨模态结构剪枝。
- 归因生成 Guard：以 SafeWatch 的 policy-aware selector 为直接基线，但必须增加 coverage 保护、归因忠实度和 time-to-verdict/P95 评测。
- 自回归 Guard 蒸馏：先以 GKD 的固定/学生 rollout 混合为可控基线，再比较 KL 方向、前缀截断和风险条件采样；encoder Guard 的错误驱动造数应单列，不标为严格 OPD。
- 流量长尾：用 SafeRoute 式小/大 Guard 级联，不以平均 F1 代替困难样本安全。

## 多模态安全判别的任务对齐剪枝重要性

### 推荐结论

不把 BlockPruner 的 PPL 简单替换为 accuracy drop。保留其“真实 mask + 迭代重估”，但采用 `前向代理预筛 → safety-loss Taylor/Fisher 排序 → 少量真实任务消融复核`。最终按安全损失与目标硬件实测时延形成 Pareto 前沿。

accuracy 与任务一致但在小校准集上离散、阈值敏感，并会被 safe/unsafe 不平衡和长尾类别掩盖。模块消融的主目标应是连续风险函数，例如 cost-sensitive CE/focal/Brier 加 worst-group CVaR 与校准损失；fixed-FPR recall、worst-category recall、AUPRC、ECE 用于最终验收。

| 指标 | 代表证据 | 适用角色 | 主要边界 |
|---|---|---|---|
| 真实任务损失 `ΔJ` | MoPE-CLIP；BlockPruner 框架改造 | 最终校正 | 每个候选需前向；小集噪声；需迭代重估 |
| accuracy/F1 drop | MoPE 的离散变体 | 报告与 sanity check | 不连续，不宜单独搜索 |
| 输入—输出余弦差异 | ShortGPT BI | 整层/残差块预筛 | 不直接对齐安全边界 |
| 激活/输出范数 | Minitron | head、neuron、channel 预筛 | 大激活不等于有利于正确类别 |
| `weight × activation` | Wanda | neuron/channel 廉价代理 | 原生权重级；跨层尺度不可比 |
| activation fluctuation × weight | FLAP | 前向可恢复性代理 | 局部重构仍不等于任务风险 |
| raw gradient | — | 不推荐单用 | 参数化敏感、正负抵消、驻点附近不可靠 |
| `|gradient × weight|` | LLM-Pruner | 第二阶段主排序 | 需要反向；依赖校准分布与损失 |
| Fisher/Taylor 二阶近似 | LLM-Pruner | 高风险候选补充 | 更高显存/计算；对角近似忽略交互 |
| learnable gate/mask | Movement Pruning、UPop | 有恢复训练预算时的强基线 | 正则、预算和初始化影响结果 |

对可执行剪枝组 `G`，建议先按样本计算再聚合，避免梯度抵消：`S_T(G)=mean_x |sum_(p in G) w_p·dL_safety(x)/dw_p|`；Fisher 型补充分数为该样本级组贡献的平方均值。不同大小的组同时报告 sum/mean，并以 `ΔJ/Δlatency` 比较，参数量和 FLOPs 只作代理。

### 模块与模态映射

| 剪枝对象 | 前向/梯度代理 | 最终复核 |
|---|---|---|
| 整层、MHA/MLP 残差块 | BI + task Taylor | mask 后连续 `ΔJ`，每轮重估 |
| attention head | 经 `W_O` 的 head 输出或 head-gate Taylor | unsafe margin 与 fixed-FPR recall |
| MLP neuron/channel | activation × outgoing weight、FLAP、group Taylor | 按层成组删除后的 `ΔJ` |
| embedding/LayerNorm channel | 归一化激活 + 全模型耦合组 | 联动依赖矩阵消融 |
| 视觉编码器 | 安全图像上的 activation/Taylor | image-only、OCR、小目标切片 |
| projector/Q-Former/cross-attention | 跨模态 safety loss/Taylor | 图文冲突、组合危害、否定关系 |
| LLM 主干/verdict head | 标签或 verdict-token loss Taylor | label-only 与 explanation 分开验收 |
| visual token | policy relevance + coverage | deletion/insertion 与证据覆盖 |

attention probability、entropy 或激活本身只说明模块“被使用”，不能证明其对正确安全判定有益。多模态模型中视觉、文本、连接器和语言主干的分数应分别标准化，再按真实时延收益联合分配预算；UPop 与 MoPE-CLIP均反对跨模态统一幅值阈值，SafeWatch 进一步表明安全 token 选择需要 policy 条件。

### 校准集与实验矩阵

- 分层平衡 safe/unsafe 和危害类别，并覆盖 text-only、image-only、image+text、视频。
- 强制纳入 OCR、小目标、图文冲突、否定/反讽、跨帧组合、隐式危害、越狱改写和 dense 模型低-margin/历史误判样本。
- 使用只改文字、只改图像或只改局部风险证据的反事实对，检测单模态捷径。
- 至少 3 个 calibration split/seed，报告代理与真实单模块 `ΔJ` 的 Spearman/Kendall、top-k overlap、bootstrap 排名稳定性。
- 在相同参数/FLOPs和相同实测时延两种预算下，比较一次性与迭代重估；最终报告 fixed-FPR recall、worst-category recall、AUPRC、ECE、P50/P95、吞吐和峰值显存。

证据边界：通用 LLM 论文覆盖 BlockPruner、ShortGPT、LLM-Pruner、FLAP 与 Minitron；通用 VLP 论文覆盖 MoPE-CLIP 与 UPop；SafeWatch 提供多模态安全 token 剪枝直接证据。本轮没有发现系统比较全部指标在多模态安全 Guard 结构剪枝上的论文，因此三级方案是跨论文综合假设，需本地验证。

## Numerical Pruning：结构化重构路线

| 方法 | 选择信号 | 结构粒度 | 恢复机制 | 计算/数据需求 | 主要证据边界 |
|---|---|---|---|---|---|
| [[LLM-Wiki/research/safety-classifier-compression/papers/2025-shen-numerical-pruning.md|Numerical Pruning]] | `(WWᵀ)⊙(XᵀX)` 二次重构目标的 Newton 连续 mask | 全局 attention head + MLP intermediate channel | `W_O/W_down` 上的等式约束最小二乘闭式补偿 | 128 个校准样本；score `O(TD³)`，补偿 `O(D³)`；无 backward | LLaMA/LlamaGen 通用生成；无安全指标；Newton/罚项/全局预算实现细节和组件消融不足 |

与 FLAP 相比，它用跨通道二阶相关矩阵替代 activation fluctuation，并用完整 weight perturbation 替代均值 bias；与 LLM-Pruner 相比，它不需要任务 loss 的 backward/Fisher，但局部输出重构与 Guard 风险边界的对齐更弱。用于安全分类时应把它作为候选 mask 生成器，再以任务损失和 fixed-FPR/worst-group 指标复核。
