---
id: note-2026-feng-visionweave
type: paper-note
title: "VisionWeave: Weaving Elastic Visual Representations as a Native Capability of MLLMs"
authors: [Yuan Feng, Qize Yang, Ruizhe Chen, Sibo Song, Haolin He, Muzhi Zhu, Zihan Liu, Yunfei Chu, Xize Cheng, Yuxuan Wang, Jin Xu, Xike Xie]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-07987
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference, knowledge-distillation]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# VisionWeave：全覆盖的粗细粒度路由与实际服务整合

## 原件与阅读范围

[arXiv 2610.07987v1](https://arxiv.org/abs/2610.07987v1)，CC BY 4.0；完整原件见 [[LLM-Wiki/raw/papers/2610.07987v1.html]]。精读 §1–4、式 1–12、算法 1、表 1–8、附录 A/E。用户明确选择本文；其主要贡献是新的视觉表示/路由和服务适配，采用 **off-policy** 蒸馏，符合当前排除“仅以在线策略蒸馏为主要贡献”而保留新视觉机制的边界。未运行训练或服务测试。

## 表示、选择器和位置

§2.2：完整 ViT 后，每个 $4\times4$ patch block 可表示为四个 native token 或一个 coarse token。Gated Spatial Pooler 在 $2\times2$ patch 内做归一化、内容/通道 gate 和 residual value refinement，再经过同一 native merger。末层 gate/value 零初始化，起点是归一化 feature 的均值池化。

Granularity Router 在 ViT 深度 0、L//2、L 各用 local→global cross-attention 更新每块 query，共六层；27B 的 tap 为 [0,13,27]。它只读取视觉特征，**算法中的路由不显式读取问题/政策**。coarse probability 超过默认 0.5 则取一个粗 token，否则保留四个细 token；所有空间 block 仍被表示。coarse MRoPE 用块中心的半整数坐标，保留 raster 顺序。它是 post-encoder 粒度分配，不降低完整 ViT 成本。

## 三阶段训练

§2.3–2.4 表 1–3：teacher/student 共享 teacher rollout，top-512 词表重归一化的 forward KL，温度 1。第一阶段仅训练 pooler、全部 coarse（25% token）；第二阶段仅训练 router，把 coarse 广播到四个 fine 位置做方向/幅值分开的 soft mixing，仍有 100% 序列，附加 0.02 balance loss，目标 coarse-block 比例 0.8；第三阶段冻结 ViT/native merger/router，训练 pooler 和 **LLM**，使用实际 hard-routed 序列。离线 scalar bias 在训练子集以 50% 节省率校准，部署不做在线更新。

27B 三阶段共享约 777K 图像/视频/GUI 样本（LLaVA-OneVision 246K、LLaVA-Video 281K、UGround 250K）；图像预算 4096，视频每帧 512、最多64帧。主文报告超过30K A100 GPU-hours，不能视为轻量 selector 微调。附录 E.2 仅对4B第三阶段比较 on/off-policy，各赢四项、均值相近，故选 off-policy；不能从该消融推广到全部规模。

## 质量与机制证据

表 4：八任务覆盖 RealWorldQA、DocVQA、InfoVQA、ScreenSpotV2、HallusionBench、VideoOCR、Video-MME、LongVideoBench，按图/帧512 native token 评测。27B 平均分77.65→76.73，平均节省43.0%；文档任务节省16.5%/27.3%，视频约49.6–54.2%。4B 为73.25→72.59，节省35.8%。FastV† 为编码后改造版，并非原始 LLM 内 FastV。

附录 E.3 表 8 对齐**每数据集**平均节省率后，4B 平均72.59对72.20/71.90，27B为76.73对70.10/70.33。27B的大差距集中于ScreenSpot；排除此项后为74.63对73.86/73.85。匹配数据集平均率不等于逐样本匹配，也未隔离LLM后训练与路由本身的全部作用。

表 6 将每输入的 routing score 空间打乱、保留 coarse 数量，平均下降2.31/5.36分；这是**固定样本预算的位置控制**，强于只展示热图。表 7 第三阶段平均73.15→76.73，但 GUI 占主要增益，RealWorldQA反降1.18；阈值变化可提供不同成本点，不能称所有任务无损。

## 服务效率与部署条件

§2.5、附录 E.4：SGLang 将坐标乘2、rotary frequency除2以支持半整数块中心；编码分离阶段附带 layout，入调度前完成 embedding slicing/位置布局，从而保留动态 batch、KV管理和CUDA-graph decode。减少输入序列能够实际进入服务调度，这比单报FLOPs更完整。

§3.4 表 5：27B、2×A100-80GB、BF16、LLM TP2、encoder DP2，LongVideoBench、2FPS、最多256帧、每帧1024 token；客户端并发4、服务器上限8。throughput 0.90→2.07 req/min（2.30×），mean TTFT169.90→77.54s，mean TPOT355.64→140.29ms。附录给出147456 context、4096 prefill chunks、FCFS/overlap和decode graph；这是长视频并发工作负载，包含排队/调度效应，不能当 batch=1 短图 Guard 的延迟倍数。

## 项目判断与边界

关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-jiang-vcola.md|V-CoLA]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-han-foveated-compression.md|Foveated Compression]]。本文全覆盖、两粒度、多块选择并更新LLM；Cx是逐样本全局/至多单局部预算、显式政策收益，二者不可直接等同。

**本项目判断：** 值得复用的是“固定 token 数打乱位置”的机制审计、粗细表示的坐标一致性、调度前固定序列布局。附录A明确训练成本限制架构探索、仅两粒度；本文未评测政策翻转/FPR/unsafe recall。TODO：匹配后训练与逐样本预算的对照、轻量政策条件selector、前端完整成本和小图条件下收益。暂不新建concept，不据单篇泛用结果修改motivation。
