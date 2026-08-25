---
id: safety-classifier-compression-comparison
type: synthesis
title: 安全判别剪枝与蒸馏统一比较
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-muralidharan-2024-minitron, paper-sun-2024-wanda, paper-xia-2024-sheared-llama, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-wu-2023-tinyclip, paper-yang-2024-clip-kd, paper-vasu-2024-mobileclip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety]
status: active
created: 2026-08-24
updated: 2026-08-25
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
