---
id: safety-autoregressive-multimodal-guard-token-pruning
type: synthesis
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-chen-2025-safewatch, paper-chi-2024-llama-guard-vision, paper-yang-2025-visionzip, paper-zhang-2025-sparsevlm, paper-wen-2025-token-pruning-right-problem]
status: active
created: 2026-08-24
updated: 2026-08-24
title: 可生成归因的多模态自回归 Guard：Token 剪枝可行性与设计边界
synthesis_kind: literature-review
---

# 可生成归因的多模态自回归 Guard：Token 剪枝可行性与设计边界

## 结论

**可以加速，而且已有安全领域直接正例，但应把结论限定为“有条件可行”。** ICLR 2025 SafeWatch 已在会生成多标签判定和逐政策自然语言解释的视频 Guard 中使用 policy-aware visual-token pruning。它报告剪掉最高 90% 视频 token 时平均性能下降小于 1%，同底座 SFT 的平均时延从 4.6 s 降到完整系统的 3.9 s。这个结果建立了可行性，但约 15% 的端到端时延改善也说明：对自回归 Guard，视觉 token 剪枝并不会消除顺序解码归因文本的成本。

## 为什么特别适合安全 Guard

1. **政策可作为 query：** 普通 VLM 根据用户问题选择 patch；安全 Guard 可进一步用每条安全政策作为显式查询，保留与暴力、色情、欺诈等政策相关的证据。
2. **视频冗余很高：** 相邻帧与背景 patch 大量重复，视觉前缀、prefill attention 和 KV cache 都可压缩。
3. **输出结构固定：** 判定、类别和短解释的 schema 相对稳定，便于用任务专门训练让模型适应固定预算。
4. **可以做风险自适应预算：** 明确安全/无害样本可激进剪枝；不确定、跨模态组合危害和需要细粒度归因的样本可保留更多 token 或回退完整 Guard。

## 为什么归因生成比普通分类更难

### 1. 决策证据不等于解释证据

一个 patch 足以改变 safe/unsafe 标签，不代表它足以支持“发生了什么、违反哪条政策、证据位于哪里”的解释。归因输出需要更高的空间、时间和对象关系覆盖。

### 2. 自回归成本分成两段

- **可被视觉剪枝显著影响：** 视觉前缀长度、prefill、后续层 attention、视觉 KV cache。
- **难被视觉剪枝消除：** 逐 token 生成描述、类别和理由的顺序 decode，以及由输出长度引起的尾延迟。

因此必须分别报告 time-to-verdict、time-to-first-rationale-token、完整解释 E2E、decode tokens/s，而不是只报 FLOPs 或视觉 token ratio。

### 3. 注意力不是可靠的安全证据证明

通用 MLLM 复核已发现 attention selector 受位置偏置影响，复杂方法在普通 benchmark 上可能输给 random/pooling，并在 RefCOCO 类定位任务上严重退化。安全场景中的 OCR、小目标、短暂视频事件、否定关系和“单模态安全、组合后有害”更容易被误删。

### 4. 自然语言解释可能流畅但不忠实

SafeWatch 评估了解释质量，但没有建立“保留 token → 引用证据 → 解释文本”的因果链。被删证据可能由语言先验补写，造成合理化而非忠实归因。

## 推荐设计

### A. Policy-aware、coverage-preserving selector

以 policy—visual cross-attention 作为相关性信号，同时加入：

- 每帧/每事件最低 token 配额；
- OCR、人物、武器、裸露、小目标等安全敏感区域保护；
- 空间多样性和时间覆盖约束；
- 少量全局 context tokens，防止只保留局部违规对象而失去语境。

### B. 判定预算与归因预算分离

先用紧凑 token 集快速生成结构化 label/category；只有 unsafe、低置信或需要审计时，再用更高预算生成解释。若产品要求每条请求都生成归因，则仍应限制解释长度并把 decode 成本单独优化。

### C. 可逆回退而非一次性硬删除

缓存低分辨率摘要或原始视觉 embedding；当生成类别与 selector 不一致、置信度低或解释需要新证据时，重新引入相关帧/patch。对多轮审核，不应只保留上一轮 policy/query 相关 token。

### D. 用剪枝适应训练恢复

SafeWatch 明确发现直接启用 PAP 会引入分布变化，因此增加 adaptive-pruning training。安全 Guard 的默认路线应是 full-token teacher → 多预算 student，并蒸馏 label、类别、解释与证据对齐，而非只在部署时套 training-free Top-k。

## 最小实验闭环

| 维度 | 最低要求 |
|---|---|
| 模型 | 一个生成式多模态 Guard；full-token 与相同权重 pruning 对照 |
| 基线 | Random、uniform spatial/temporal pooling、attention Top-k、policy-aware Top-k、coverage-protected Top-k |
| 预算 | 至少 0%、50%、75%、90%、95% 视觉 token 剪枝 |
| 安全质量 | macro F1/AUPRC、fixed-FPR recall、per-policy/worst-group recall、ECE |
| 归因质量 | policy correctness、证据覆盖、frame/region grounding、sufficiency/comprehensiveness、人工审计 |
| 脆弱切片 | OCR、小目标、短暂事件、隐式图文组合、否定/反讽、多政策冲突 |
| 系统指标 | vision encode、prefill、time-to-verdict、完整归因 E2E P50/P95、KV/peak memory、输出长度 |

## 当前证据边界

- **已证实：** safety-specific、policy-aware visual-token pruning 能与自回归解释输出共存，并取得有限但真实的延迟收益。
- **尚未证实：** 该结论能稳定迁移到图像—文本对话 Guard、所有危害类别和多轮审核；自然语言归因是否忠实于保留视觉证据；training-free 通用 selector 是否足够安全。
- **研究判断：** 最有价值的问题不是“能否剪”，而是“在固定漏报风险和归因忠实度约束下，如何动态分配视觉证据预算，并把 time-to-verdict 与完整解释时延一起最小化”。

## 相关页面

- [[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md|SafeWatch 论文笔记]]
- [[LLM-Wiki/research/safety-classifier-compression/overview.md|安全判别系统的剪枝与蒸馏]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|图文多模态 Token 剪枝专题]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝概念]]

