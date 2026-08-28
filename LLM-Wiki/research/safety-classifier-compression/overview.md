---
id: safety-classifier-compression
type: research-overview
title: 安全判别系统的剪枝与蒸馏
aliases: [安全分类器压缩, Guard Model 压缩]
tags: [research, method]
status: active
related: [visual-token-pruning, on-policy-distillation]
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-chi-2024-llama-guard-vision, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-muralidharan-2024-minitron, paper-sun-2024-wanda, paper-xia-2024-sheared-llama, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-wu-2023-tinyclip, paper-yang-2024-clip-kd, paper-vasu-2024-mobileclip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-ma-2023-llm-pruner, paper-an-2024-flap, paper-zhong-2025-blockpruner, paper-men-2025-shortgpt, paper-shi-2023-upop, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety]
created: 2026-08-24
updated: 2026-08-27
---

# 安全判别系统的剪枝与蒸馏

## 一句话概述

近三年的直接证据表明，安全判别最成熟的降本路线是把 7B–8B 生成式 Guard 的决策知识迁移到 0.4B 级判别学生，再用结构剪枝、恢复蒸馏和低比特部署进一步压缩；为了守住困难样本上的精度，应把困难/有害样本生成、校准和小模型—大模型级联视为压缩方案的一部分。

## 研究问题

在 prompt、response 与图文内容安全判别中，如何同时提高吞吐率和安全检测质量，并降低部署内存、端到端时延、教师标注成本、微调成本和派生小模型的训练成本？

## 范围与时间截点

- 时间窗：2023-08-24 至 2026-08-24。
- 核心任务：文本或多模态输入的安全/危害判别、内容审核、prompt 与 response 分类。
- 扩展顺序：安全判别直接证据不足时，先扩展到工业文本分类，再扩展到 CLIP/VLM 的分类、检索与理解任务。
- 包含：权重/结构剪枝、Token/输入剪枝、教师标签/Logit/特征/关系蒸馏、离线数据强化、学生 rollout 上的 on-policy 蒸馏，以及直接建立在压缩学生之上的大小模型路由。
- 不包含：只有量化而没有剪枝或蒸馏的方法；只做生成质量的压缩；没有质量指标的纯 FLOPs 报告。
- 证据优先级：正式会议论文优先；安全领域的官方预印本用于补足稀缺直接证据，并明确标注。

## 核心结论

1. 安全任务中，任务专用 encoder 学生已经能显著优于“缩小后的生成式 Guard”在单位成本上的表现。HarmAug 的 435M DeBERTa 在四个公开安全基准上平均 F1 为 0.7357、平均 AUPRC 为 0.8362；相对 Llama-Guard-3，其每 token FLOPs、时延、峰值显存和云成本分别约为 0.6%、25%、12% 和 26%。
2. 结构剪枝与蒸馏是互补关系。Llama Guard 3-1B-INT4 通过结构压缩、以 8B Guard 为教师的 Logit 蒸馏和 INT4 QAT，将模型缩到约 440 MB，并在普通 Android CPU 上报告至少 30 token/s、TTFT 不超过 2.5 秒；Minitron、Sheared LLaMA 也表明剪枝后恢复训练远低于从头训练小模型的成本。
3. 蒸馏的瓶颈已从“复制教师输出”转向“覆盖学生的决策盲区”。HarmAug 用生成的多样有害指令补尾部，PGKD 用验证反馈和 hard-negative mining 让教师迭代生成数据；两者共同说明，数据选择通常比换一个复杂 KD loss 更关键。
4. 多模态蒸馏必须保留跨模态关系。TinyCLIP 的 affinity mimicking、CLIP-KD 的特征对齐、MoPE-CLIP 的跨模态敏感度指标与 SmartTrim 的自蒸馏均显示，单模态幅值指标不足以稳定保留图文对齐。
5. 真实吞吐依赖可执行结构。结构化宽度/深度/头剪枝可在通用 dense kernel 上兑现收益；Wanda 一类非结构化稀疏即使保持困惑度，也不能在缺少稀疏 kernel 与硬件支持时等价为端到端加速。
6. 小模型不应强行处理所有输入。SafeRoute 的 oracle 分析在 WildGuardMix 上仅让约 5.09% 样本使用 8B Guard，F1 从 1B 的 0.6702 和 8B 的 0.7054 提升到 0.8101；实际路由仍受训练分布与校准误差约束，但证明“压缩学生 + 困难样本升级”具有较高上限。
7. 多模态安全 Token 剪枝已经出现直接正例，但尚未广泛闭环。SafeWatch 在可生成多标签判定与逐政策解释的视频 Guard 中使用 policy-aware visual-token pruning：作者报告剪除最高 90% 视频 token 时平均性能下降小于 1%，同底座 SFT 平均时延由 4.6 s 降至完整系统的 3.9 s。该证据仍集中于视频与平均指标，尚未证明图像—文本组合危害、OCR、小目标、多轮和归因忠实度。
8. On-policy 蒸馏最适合会生成判定与归因的自回归 Guard：教师在学生实际生成的前缀上纠正错误，可缩小训练—推理状态错配；GKD、MiniLLM、DistiLLM 与 prefix OPD 已形成“rollout 混合—散度稳定—轨迹降本”的通用路线。当前直接安全证据主要是 OPSA 预印本中的生成式安全对齐，而非独立 Guard 分类或多模态安全判别，因此本项目只把它列为候选验证方向。
9. 面向安全判别的结构剪枝不应继续用 PPL 单独排序，也不宜只换成离散 accuracy drop。BlockPruner 的迭代真实消融、LLM-Pruner 的 `gradient × weight`、FLAP/Minitron 的前向激活代理与 MoPE-CLIP 的跨模态任务下降各自覆盖不同成本—保真区间；当前最稳妥的研究方案是三级筛选并在每轮剪枝后重估。

## 推荐工程路线

- 文本首选：8B Guard 教师 → 100M–500M encoder 学生 → 困难/有害样本增广 → 结构化头/FFN/层剪枝 → 蒸馏恢复 → INT8/INT4 → 小/大 Guard 路由。
- 多模态首选：先训练/蒸馏小型双塔或轻量 VLM，蒸馏跨模态 embedding/affinity；再做跨模态敏感度驱动的结构剪枝。若使用可生成归因的自回归 Guard，采用 policy-aware、coverage-protected visual-token pruning，分开测 time-to-verdict 与完整解释时延，并单独验证小目标、OCR、短暂事件、隐式跨模态危害和归因忠实度。
- 统一验收：macro/micro F1、AUPRC、各危害类别召回、FPR、ECE、越狱/变体鲁棒性、P50/P95 时延、吞吐、峰值显存、能耗，以及教师生成/标注和恢复训练的总成本。

## 项目文档

- [[LLM-Wiki/research/safety-classifier-compression/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/safety-classifier-compression/landscape.md|技术路线图]]
- [[LLM-Wiki/research/safety-classifier-compression/comparison.md|统一维度比较]]
- [[LLM-Wiki/research/safety-classifier-compression/gaps.md|研究缺口]]
- [[LLM-Wiki/research/safety-classifier-compression/motivation.md|研究动机]]
- [[LLM-Wiki/research/safety-classifier-compression/hypotheses.md|待验证假设]]
- [[LLM-Wiki/concepts/methods/on-policy-distillation.md|On-policy 蒸馏概念]]
- [[LLM-Wiki/research/safety-classifier-compression/autoregressive-multimodal-guard-token-pruning.md|可生成归因的多模态自回归 Guard Token 剪枝]]
- [[LLM-Wiki/research/safety-classifier-compression/comparison.md|统一维度比较：含任务对齐剪枝重要性指标]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|邻接项目：视觉 Token 剪枝]]

## 预注册实验设计（未执行）

- [[LLM-Wiki/experiments/20260825-safety-decoder-prune-kd-05b/README.md|实验一：0.5B Decoder-only Guard 校准、结构剪枝与蒸馏恢复]]
- [[LLM-Wiki/experiments/20260825-safety-cascade-prune-kd-04b/README.md|实验二：0.4B Decoder-only Guard 与 8B 置信度级联]]
- [[LLM-Wiki/experiments/20260825-safety-encoder-prune-kd-03b/README.md|实验三：0.3B Encoder-only Guard 校准、深度剪枝与蒸馏恢复]]

三项实验各自完整定义数据、训练、校准、对照、指标和停止条件，彼此不共享必须依赖的 checkpoint 或说明文档；为保证可比性，它们预注册同一训练/测试数据、split seed、最大长度、优化器、学习率、batch、epoch、KD loss、三个随机种子和 A100 测速协议。当前没有实验结果，不能用于更新核心结论或 Motivation。

- [[LLM-Wiki/research/ai-safety-systems-security-venues/overview.md|邻接调研：安全四大顶会中的 AI 安全系统工作]]
