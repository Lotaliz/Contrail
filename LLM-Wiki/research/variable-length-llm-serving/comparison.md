---
id: variable-length-llm-serving-comparison
type: synthesis
title: 变长自回归 LLM Serving 机制比较
tags: [research, model-serving, continuous-batching]
project_id: variable-length-llm-serving
sources: [paper-yu-2022-orca, paper-kwon-2023-vllm, paper-agrawal-2024-sarathi-serve, paper-zhong-2024-distserve, paper-zhu-2025-nanoflow]
status: active
created: 2026-08-27
updated: 2026-08-27
---

# 机制比较

| 层次 | 代表工作 | 解决的长度异构 | 核心机制 | 对 PP 的意义 | 仍有代价 |
|---|---|---|---|---|---|
| 请求调度 | Orca | 输出步数不同 | 每 token 迭代重新组成 batch | 不再让已完成请求占住后续迭代 | 调度本身不保证每个微批等计算量 |
| KV 内存 | vLLM | prompt/output 总长度不同 | PagedAttention、按块分配与释放 KV | 支持更大、更动态的在途 batch | attention 间接寻址、容量与抢占仍需管理 |
| 单轮工作量 | Sarathi-Serve | 长 prefill 与短 decode 混合 | chunked prefill、decode-first、固定 token budget | 近似均匀微批，直接减少 pipeline bubble | chunk 重算/调度开销；预算依赖 workload 与 SLO |
| 阶段资源 | DistServe | prefill/decode 算力特性不同 | 两阶段分离部署与独立并行配置 | 避免同一流水线上的阶段干扰 | KV 跨实例传输、带宽与放置复杂度 |
| 设备内执行 | NanoFlow | 算子资源需求异构 | nano-batch 与 compute/memory/network 重叠 | 补充请求级调度，提升设备利用率 | 搜索与实现复杂，主要优化吞吐而非自动保证尾延迟 |

## 综合判断

这些方法形成互补栈，而非单一“完美 batching 算法”：Orca 解除请求生命周期耦合，vLLM 解除 KV 内存预留耦合，Sarathi 约束每轮计算量，DistServe 解除 prefill/decode 资源耦合，NanoFlow 再优化设备内资源空洞。因此常规变长生成已能高效服务，但严格 SLO 和复杂集群中的最优配置仍是在线系统问题。
