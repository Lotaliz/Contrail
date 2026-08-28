---
id: variable-length-llm-serving
type: research-overview
title: 变长自回归 LLM 的批推理与流水线调度
aliases: [continuous batching, in-flight batching, iteration-level batching]
tags: [research, model-serving, continuous-batching, efficient-inference]
status: active
related: []
sources: [paper-yu-2022-orca, paper-kwon-2023-vllm, paper-agrawal-2024-sarathi-serve, paper-zhong-2024-distserve, paper-zhu-2025-nanoflow]
created: 2026-08-27
updated: 2026-08-27
---

# 变长自回归 LLM 的批推理与流水线调度

## 一句话结论

**核心难题已经得到较好解决，但没有被彻底消灭。** 对常规在线 LLM serving，系统已不再等待一个静态 batch 整体结束，而是在每个 token 迭代动态加入和移出请求；配合 paged KV cache、去 padding、chunked prefill 和 token-budget 调度，prompt 长度与输出长度不一致通常不再是基础可用性的瓶颈。流水线并行中的气泡也可通过近似等计算量的微批显著压低，但在极端长上下文、负载突发、严格尾延迟 SLO、KV 迁移及多节点异构网络下仍是持续优化问题。

## 研究问题

用户问题是：不同 prompt 长度与未知输出长度使 batch 难以“整存整取”，尤其在 pipeline parallel serving 中产生气泡；截至 2026-08-27，这是否已经得到较好解决？

## 范围

### 包含

- 在线自回归 decoder serving；变长 prompt 和变长生成。
- 请求级连续组批、KV-cache 内存管理、prefill/decode 干扰、pipeline bubble 与 SLO。
- 正式代表论文与主流开源/商业推理引擎的公开实现状态。

### 不包含

- 训练流水线和离线静态吞吐 benchmark。
- 仅靠 padding/bucketing 的传统方案。
- 纯模型压缩、纯 KV 压缩和与动态 batching 无关的 kernel 优化。

## 判断口径

“较好解决”指常规生产引擎已有成熟通用机制，使长度不齐不再要求 batch 级同步完成，并能在合理 SLO 下获得高吞吐；不表示所有硬件、并行方式和长上下文负载都达到理论最优。

## 核心机制

1. **Iteration-level / continuous batching**：每次 decode 迭代后移出完成请求、加入新请求，直接解除“最长输出决定整个 batch 生命周期”的约束（Orca）。
2. **Paged KV cache 与 packed tokens**：按块按需分配 KV cache，并移除 padding，使不同长度请求能共享显存而不为最大长度预留完整连续空间（vLLM；TensorRT-LLM）。
3. **Chunked prefill + token budget**：把长 prompt 切成有界 chunk，与 decode token 混批；每轮控制总 token 数，避免长 prefill 阻塞 decode，并使 PP 微批更均匀（Sarathi-Serve）。
4. **Prefill/decode 解耦**：严格 TTFT/TPOT SLO 下可让两阶段使用不同 GPU 与并行配置，避免互相干扰，但增加 KV 传输和集群调度成本（DistServe）。
5. **更细粒度执行重叠**：nano-batching 可在单设备内重叠 compute、memory 和 network，继续逼近吞吐上界；这说明剩余问题已从“能否动态组批”转为“如何更接近硬件与 SLO 最优”（NanoFlow）。

## 工程成熟度证据

- vLLM V1 的统一调度器以每请求 token budget 同时调度 prompt/output token，chunked prefill 在支持的模型上默认启用；官方仓库同时列出 continuous batching、pipeline parallelism 与 disaggregated prefill。
- TensorRT-LLM 官方文档把 in-flight batching、packed input、paged KV cache 与 chunked context 作为正式功能，并以 `max_num_tokens` 控制单轮 token 工作量。

上述实现状态说明这些机制不只停留在论文原型，但各引擎的模型覆盖、默认参数与最佳配置仍会变化。

## 保守结论

- 若问题是“长度不齐是否还迫使整个 batch 等最慢请求”：**基本不是**。
- 若问题是“pipeline bubble 是否已有通用有效缓解”：**是，已有强方案，Sarathi-Serve 是最直接代表**。
- 若问题是“是否对所有在线负载都彻底解决、无需调参”：**否**。token budget、batch size、PP/TP/PD-disaggregation 配置仍依赖模型、硬件、长度分布和 SLO；长上下文与突发流量仍会暴露尾延迟、KV 容量/迁移和跨节点负载不均。

## 相关材料

- [[LLM-Wiki/research/variable-length-llm-serving/reading-log.md|检索与阅读日志]]
- [[LLM-Wiki/research/variable-length-llm-serving/comparison.md|机制比较]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-agrawal-sarathi-serve.md|Sarathi-Serve 深读]]

## 官方实现页面

- vLLM V1 scheduler：https://docs.vllm.ai/en/latest/usage/v1_guide/
- TensorRT-LLM in-flight batching：https://nvidia.github.io/TensorRT-LLM/features/paged-attention-ifb-scheduler.html
