---
id: safety-classifier-compression-motivation
type: synthesis
title: 面向高吞吐与低总成本的安全判别研究动机
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-vasu-2024-mobileclip, paper-chen-2025-safewatch]
status: active
created: 2026-08-24
updated: 2026-08-24
---

# 研究动机

## M1：以困难样本风险而不是平均指标约束压缩

HarmAug 表明，朴素蒸馏失败的重要原因是有害指令多样性不足，补充困难分布后 435M 学生可达到或超过 7B–8B Guard 的部分指标；SafeRoute 独立显示，大部分请求可由 1B Guard 处理，但少量样本由 8B 正确而 1B 错误。因此，有证据支持的研究方向是：以困难样本识别、类别召回和校准为压缩约束，联合训练学生与回退路由，而不是只优化总体 F1 或 FLOPs。

## M2：联合优化在线成本和更新周期内的离线成本

PGKD 明确指出循环教师生成会增加蒸馏成本；HarmAug 同样需要生成、响应和教师标注；P-pruning 证明先剪后调可以降低每个任务的微调成本；MobileCLIP 说明教师信号离线缓存后可在多个模型间复用。由此可见，面向经常变化的安全政策，应优化“教师调用 + 数据生成 + 剪枝/恢复训练 + 部署推理”的周期总成本，而非只报单次推理价格。

## M3：以目标硬件真实时延决定剪枝结构

Llama Guard 3-1B-INT4 给出 Android CPU 的吞吐与 TTFT，P-pruning 给出实际 fine-tuning speedup；它们共同说明，结构化目标形状和运行时实现才是效率结论的落点。研究应在固定安全风险上限下搜索 layer/head/FFN/embedding 预算，并直接测量目标 CPU/GPU/NPU 的 P50/P95、能耗和显存。

## M4：在固定漏报风险和归因忠实度下优化多模态证据预算

SafeWatch 提供了安全任务直接基线：policy-aware visual-token pruning 可与自回归多标签判定和自然语言解释共存，并带来有限但真实的端到端时延收益；VisionZip/SparseVLM 及独立复核则说明视觉 token 冗余普遍存在，但注意力重要性、空间定位和真实时延并不稳定。结合“安全 Guard 必须控制漏报且归因要可审计”的场景约束，研究应优化 policy-aware relevance、时空 coverage、风险自适应预算和可逆回退，而不是最大化平均 token 删除率。

## 建议研究问题

能否训练一个 100M–500M 的安全判别学生，通过“教师标签/Logit + 主动有害样本生成 + 任务感知结构剪枝 + 校准路由”，在公开文本安全基准上保持或提高 per-category recall 与 AUPRC，同时相对 8B Guard 将 batch=1 P95、峰值显存和更新周期总成本分别降低至少一个数量级？

## 最小验证闭环

1. 教师与学生：Llama-Guard-3-8B；DeBERTa-base/large 或同规模 encoder；可选 1B 生成式学生。
2. 数据：WildGuardMix、HarmBench、ToxicChat、OAI Moderation；按 taxonomy、语言、攻击族和时间切分。
3. 方法：直接微调、普通教师标签、HarmAug、PGKD 式 hard-negative；结构剪枝前/后；无回退与 SafeRoute 式回退。
4. 指标：macro/micro F1、AUPRC、固定 FPR 下召回、per-category recall、ECE、risk-coverage；P50/P95、throughput、peak memory、energy。
5. 成本：教师 tokens/API 或 GPU 时、合成数据生成、剪枝搜索、恢复训练、每次政策更新和线上回退比例。
6. 设备：服务器 GPU、CPU 与一类边缘 NPU；batch=1 为主，batch=8/64 作为吞吐对照。

## 暂不进入正式动机的方向

SafeWatch 已使“多模态安全 Guard 能否使用视觉 Token 剪枝”越过纯候选阶段；仍暂不进入正式动机的是“任意通用 training-free selector 可安全迁移”以及“自然语言解释质量等价于忠实视觉归因”。
