---
id: visual-token-pruning-comparison
type: synthesis
title: 视觉 Token 剪枝统一比较
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding]
status: active
created: 2026-08-24
updated: 2026-08-26
---

# 统一比较

> 数字均为作者在各自设置下报告，硬件、batch size、模型和计时口径不同，不可直接排名。“精度损失”通常为绝对百分点。

| 方法 | 任务/主干 | 选择与压缩 | 训练需求 | 质量—效率代表点 | 时延证据 | 主要局限 |
|---|---|---|---|---|---|---|
| HeatViT, HPCA'23 | ImageNet；DeiT/LV-ViT | 多头选择器；丢弃并聚合；硬件延迟约束 | 多阶段微调 + 8-bit 量化 | 相近精度下降低 28.4%–65.3% 计算；部分设置无精度下降可剪 16.1%–23.1% | ZCU102 上剪枝本身 1.82–2.58×，叠加量化总计 3.46–4.89× | 加速器专用；剪枝与量化贡献需分开看 |
| ToMe, ICLR'23 | 图像/视频/音频分类 | 二分匹配合并相似 token | 可免训练 | 高分辨率 ViT-L/H 约 2× throughput，精度降 0.2–0.3 | 报吞吐，合并核实现敏感 | 不是纯剪枝；均匀每层合并率可能次优 |
| STViT, CVPR'23 | ImageNet、视频、检测/分割 | 语义 token 聚类与恢复 | 需训练/改造 | DeiT 16 token 下约 60% FLOPs 降低且精度相当；推理速度提升超过 100% | 报 inference speed | 更像架构级凝聚；恢复模块削弱部分收益 |
| AS-ViT, IJCAI'23 | ImageNet；DeiT/LV-ViT | 多头加权 class attention + 可学习阈值 | 30 epoch 微调 | DeiT-S throughput +50%，Top-1 -0.2；30%–35% 计算下降时精度损失≤0.2 | 2080Ti；batch=64 吞吐、batch=1 平均时延 | 依赖 class token/attention；动态长度执行开销 |
| DiffRate, ICCV'23 | ImageNet；DeiT/MAE ViT | 可微层级剪枝率 + 合并率 | 可仅优化 rate，支持免全量微调 | MAE ViT-H FLOPs -40%，throughput 1.5×，Top-1 -0.16 | 报 GPU throughput | 搜索所得 budget 对硬件未必最优 |
| Zero-TPrune, CVPR'24 | ImageNet；多种 ViT | 注意力图 WPR 重要性 + 相似性剪枝 | 免训练 | DeiT-S FLOPs -34.7%，throughput +45.3%，Top-1 -0.4 | 报 throughput | PageRank/排序有固定开销；主要验证分类 |
| ToCom, ECCV'24 | 20+ 分类下游任务；DeiT | 为不同 compression degree 学补偿插件 | 一次快速参数高效自蒸馏 | CIFAR100/FGVC/VTAB 平均性能最高提升 2.3/1.5/2.0 点 | 复用 ToMe 吞吐曲线，不主张新增剪枝加速 | 解决精度补偿而非选择器；需保存插件 |
| ToP-ViM, NeurIPS'24 | ImageNet、COCO；ViM/PlainMamba | SSM 输出重要性 + 隐状态位置对齐 | 30 epoch 微调 | PlainMamba-L3 Top-1 81.7，FLOPs -41.6%；基线 82.3 | 论文称有实际加速，但主表以 FLOPs 为主 | 缺少统一详细 latency 表；架构专用 |
| TCA, ICCV'25 | CLIP/SigLIP 跨域分类 | 代表 token + 域锚点凝聚、logit correction | 免训练 | 跨数据集/腐化集最高提升 21.4%，GFLOPs -12.2% 至 -48.9% | 未形成跨硬件时延主证据 | 目标含适应增益，不能与 IID ImageNet 直接比 |
| V-Pruner, AAAI'26 | ImageNet；ViT-L/DeiT | Fisher 初始化 + PPO 全局逐层决策 | 约 1.3h（文中代表设置） | 多尺度模型上同时比较精度、GFLOPs、吞吐与 latency；DeiT-T/S 表中约 1.23–1.4× 级加速 | 报 img/s 与 ms | RL 搜索仍依赖校准与硬件；需独立复现 |

## 可直接用于选型的判断

- 零训练、分类先行：Zero-TPrune；同时保留 ToMe 作为信息保真基线。
- 可微调且追求精度：AS-ViT 或 DiffRate；高压缩优先联合剪枝/合并。
- 多预算部署：ToCom 弥补不同推理预算下的精度损失，但仍需目标硬件重新找预算。
- FPGA/固定边缘设备：HeatViT 式 latency LUT 与算子共设计最有证据。
- 视觉 SSM：不可直接套用 ViT selector，优先 ToP-ViM 式位置对齐。
- 分布偏移分类：TCA 提示“压缩可兼作适应”，但要独立验证 IID 精度与真实 latency。

## 图文多模态比较入口

多模态方法还必须比较压缩位置（vision encoder/projector/LLM layer/cache）、是否使用文本、是否支持 multi-turn，以及 TTFT/decode/KV 指标。完整统一表见：

- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md#统一比较|图文多模态 Token 剪枝统一比较]]。

快速选型：encoder-style VLM 用 TRIPS/PuMer；decoder-only training-free 基线用 FastV；重 multi-turn/prefill 用 VisionZip；高压缩覆盖基线用 DivPrune；需要 prompt-aware progressive pruning 用 SparseVLM；任何复杂方法都必须同时对比 Random/Pooling，并单独搜索层预算。

## 双自适应 Guard Serving 的相邻系统比较

| 系统/方法 | 已解决的自适应维度 | 组批/执行机制 | 质量约束 | 当前课题必须新增什么 |
|---|---|---|---|---|
| Orca, OSDI'22 | 生成请求的迭代进度 | iteration-level scheduling；selective batching | 无 Guard 安全约束 | 同时容纳可变 token 与可变主干路径 |
| Brainstorm, OSDI'23 | sub-tensor 动态路由/子网 | Cell、Router、动态分布专门化 | 通用模型精度 | Guard execution signature、安全证据与风险约束 |
| Deja Vu, ICML'23 | 输入相关 head/MLP 稀疏 | 在线预测、异步硬件感知执行 | 通用 LM 质量 | 多模态 Guard 上的安全保持与高 batch 执行 |
| Sarathi-Serve, OSDI'24 | prefill/decode 工作量 | chunked-prefill、stall-free uniform batches | TTFT/TPOT SLO | 短输出 Guard 的 time-to-verdict 与二维异构组批 |
| Apparate, SOSP'24 | 请求级 early exit | 持续完整执行反馈、在线 ramp/threshold 调整 | accuracy drop budget | fixed-FPR/worst-risk 约束；不能总是后台跑完整 Guard |
| PowerInfer, SOSP'24 | 热/冷神经元激活 | CPU-GPU 放置、自适应预测、稀疏算子 | 通用 LM 质量 | 数据中心 Guard 的权重驻留与批执行设计 |
| SuperServe, NSDI'25 | 权重共享子网与请求 slack | SubNetAct + SlackFit | accuracy/latency target | Token×主干联合 profile 与安全回退 |
| PuDDing, ICML'25 | prompt/task-dependent depth | router 选择 omission set | 任务平均性能 | 风险/证据驱动路径以及 serving integration |
| SafeRoute, Findings ACL'25 | 小/大 Guard 路由 | router 选择独立模型 | Guard F1/计算 | 多模态、权重共享、batch/SLO 与细粒度安全约束 |
| SafeWatch, ICLR'25 | policy-aware 视频 token | policy attention + adaptive pruning | 平均 Guard 指标 | 主干弹性、在线服务、P99 与固定 FPR |

### 结论

当前方案的每个单模块都有强先例，但“Guard 安全约束下同时控制序列长度和主干路径，并保持高效批执行”尚未被上述论文完整覆盖。这一交集是可投稿空间，也是必须用系统机制而非模块堆砌证明的部分。
