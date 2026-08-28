---
id: visual-token-pruning-comparison
type: synthesis
title: 视觉 Token 剪枝统一比较
tags: [research, method]
project_id: visual-token-pruning
sources: [paper-dong-2023-heatvit, paper-bolya-2023-tome, paper-chang-2023-stvit, paper-liu-2023-adaptive-sparse-vit, paper-chen-2023-diffrate, paper-wang-2024-zero-tprune, paper-jie-2024-tocom, paper-zhan-2024-token-pruning-vssm, paper-wang-2025-tca, paper-yao-2026-v-pruner, paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem, paper-ji-2026-vispco, paper-chen-2025-safewatch, paper-lee-2025-saferoute, paper-yu-2022-orca, paper-cui-2023-brainstorm, paper-liu-2023-dejavu, paper-agrawal-2024-sarathi-serve, paper-dai-2024-apparate, paper-song-2024-powerinfer, paper-khare-2025-superserve, paper-wee-2025-pudding, paper-zhu-2025-nanoflow, paper-yu-2026-prism, paper-cai-2020-once-for-all, paper-devvrit-2024-matformer, paper-raposo-2024-mixture-of-depths]
status: active
created: 2026-08-24
updated: 2026-08-27
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

## “自适应模型规模”是否在推理阶段裁剪模型

这里必须把“裁剪”拆成参数结构生成、权重驻留和执行路径选择。现有论文并不共享同一种实现。

| 方法 | 决策时机/粒度 | 权重驻留或加载 | 请求执行阶段发生什么 | 对题述判断 |
|---|---|---|---|---|
| Once-for-All | 部署前；设备/预算级 | 可导出并只部署专用子网 | 固定小模型正常前向 | 支持“不现场剪枝”，但不是按请求选择 |
| MatFormer | 部署前或运行时；层级 FFN 宽度、query/token | 可抽取独立子模型，也可让 universal model 常驻后切片 | 嵌套权重前缀组成不同粒度子模型 | 部分支持；不要求模块加载 |
| SuperServe | 每请求；accuracy/latency/SLO profile | 权重共享超网就地驻留；SubNetAct避免额外加载 | 控制流选择 LayerSelect/WeightSlice 等路径 | 直接反驳“通常需要加载子网” |
| PuDDing | 每 prompt 一次；Transformer omission set | 低内存设定下从存储加载被选 blocks | 执行预定义深度子网；不现场搜索剪枝 | 最直接支持题述实现 |
| Deja Vu | 每层/输入；head 与 MLP | 依赖异步硬件感知执行；不是请求级完整子网 | 在线预测 contextual sparsity并跳过计算 | 运行时条件剪枝反例 |
| Mixture-of-Depths | 每层每 token | 完整权重结构存在；固定 k 保持静态 tensor size | Top-k token 进入 block，其余绕过 | 运行时动态计算、非模块加载 |
| PowerInfer | 离线放置 + 在线每层 neuron 预测 | 热 neuron GPU 常驻，冷 neuron CPU 常驻 | 两端直接计算预测活跃 neuron并合并 | 是分层驻留，不是临时组成子网 |
| SafeRoute | 每请求；独立小/大 Guard | 两个独立模型，可能同时驻留或由 serving 层管理 | router选择一个模型 | 是模型路由，不是权重共享剪枝 |

### 对多模态安全 Guard 的判断

- **适用的部分：** 不在请求关键路径执行 BlockPruner 式逐模块重要性测量、张量删除和模型重构。离线建立少量安全校准过的可执行 profile，在线只路由、切片或跳过。
- **需要修正的部分：** 路由依据不应只是“任务”。同一安全判别任务内部，OCR、小目标、图文冲突、隐式危害和高风险低置信样本需要不同计算量；应使用风险、证据充分性、校准置信度、deadline slack 与队列状态。
- **推荐数据中心实现：** 权重共享或嵌套超网常驻 GPU，预编译少量 `(token budget, backbone profile)`，请求按 execution signature 组批；风险不满足时升级 profile 或回退完整 Guard。不要在关键路径从 CPU/SSD 装配任意子网。
- **推荐边缘实现：** 显存/内存放不下完整 Guard 时，PuDDing式 block loading才有必要；必须计入路由、存储读取、模块重用和 prompt 切换成本。
- **论文新颖性边界：** “训练大网—选子网—按置信度路由”已有 OFA、MatFormer、SuperServe、PuDDing 和 SafeRoute。可成立的贡献应是多模态安全证据与主干预算耦合、fixed-FPR/worst-risk 约束、二维异构组批以及可验证回退，而不是自适应子网本身。


## LLM Serving 三层系统对照

| 论文 | 优化层级 | 核心场景 | 主要机制 | 首要评价目标 | 不适用/薄弱场景 |
|---|---|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2024-agrawal-sarathi-serve.md|Sarathi-Serve]] | 请求/迭代/微批 | 单模型在线生成，长 prefill 干扰 decode；跨节点 PP batch 不均 | chunked prefill、decode-first token budget、stall-free hybrid batch | P99 TBT SLO 下的最大可持续 QPS | 短输出分类器、缺少长 decode 的 Guard；未定量比较 P/D disaggregation |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhu-nanoflow.md|NanoFlow]] | 单 GPU 内算子/资源 | 高并发、大 batch、aggregate compute-bound，但 compute/memory/network 串行 | nano-batch、干扰 profile、两阶段 MILP pipeline search | total tokens/s/GPU 与理论 compute roofline 的差距 | 低 load、memory-bound/小模型长 decode、非 NVIDIA runtime 可移植性未证 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-yu-prism.md|Prism]] | 模型 residency/跨 GPU 内存/集群 | 大量长尾模型保持可用，活跃模型组持续变化且请求 burst 交错 | CUDA VMM ballooning、eTensor、KVPR placement、slack-aware arbitration | TTFT/TPOT attainment 与达到目标所需 GPU 数 | 弱互联加载、未知 trace shift、局部调度的最优性依赖可估 prefill |

### 组合关系

三篇工作可串成一个层级化 serving stack：Prism 决定模型驻留位置和跨模型物理显存份额；Sarathi-Serve 决定某模型实例每轮接纳哪些 prefill/decode token；NanoFlow 再把该轮算子拆成 nano-operations，在设备内重叠异构资源。它们处理的瓶颈不同，因此把三者的 speedup 相乘是不成立的；真正的组合实验应重新测端到端 SLO goodput，并检查上层弹性是否破坏下层稳定大批假设。
