---
id: variable-length-llm-serving-reading-log
type: synthesis
title: 变长自回归 LLM Serving 检索与阅读日志
tags: [research, model-serving, continuous-batching]
project_id: variable-length-llm-serving
sources: [paper-yu-2022-orca, paper-kwon-2023-vllm, paper-agrawal-2024-sarathi-serve, paper-zhong-2024-distserve, paper-zhu-2025-nanoflow]
status: active
created: 2026-08-27
updated: 2026-08-27
---

# 检索与阅读日志

## 检索设置

- 检索日期与时间截点：2026-08-27。
- 来源：USENIX 正式论文页、SOSP/arXiv 论文原文、vLLM 与 TensorRT-LLM 官方文档。
- 关键词族：`LLM continuous batching`, `iteration-level scheduling`, `in-flight batching`, `chunked prefill`, `pipeline parallel serving bubble`, `prefill decode disaggregation`。
- 纳入：直接处理变长自回归请求、动态 batch、KV-cache 批容量、prefill/decode 干扰或流水线气泡的代表系统；以及可验证主流引擎是否已落地的官方文档。
- 排除：训练 pipeline、仅静态离线 batching、只做模型/权重压缩、无正式来源的二手总结。

## 代表工作

| 工作 | 年份 | 阅读层级 | 本轮角色 | 关键证据 |
|---|---:|---|---|---|
| Orca | 2022 | skimmed | 调度基础 | iteration-level scheduling 允许每轮加入/移出请求，解除静态 batch 生命周期绑定 |
| vLLM / PagedAttention | 2023 | skimmed | 内存基础 | block-based KV 管理降低碎片和预留浪费，扩大可持续动态 batch |
| Sarathi-Serve | 2024 | deep-read | PP 核心证据 | chunked prefill、decode-first token budget 与均匀微批降低 stall 和 pipeline bubble |
| DistServe | 2024 | skimmed | 严格 SLO 替代路线 | 分离 prefill/decode GPU 与并行配置，消除阶段共置干扰 |
| NanoFlow | 2025 | deep-read | 后续优化证据 | 在已动态组批基础上继续用 nano-batch 重叠设备资源，说明问题焦点转向逼近最优 |

## 官方实现核对

- vLLM V1 官方指南：统一 scheduler 对 prompt 与 output token 使用每请求固定 token budget；chunked prefill 已是功能项并在适用模型上默认启用。
- TensorRT-LLM 官方指南：支持 continuous/in-flight/iteration-level batching、packed tensors、paged KV cache 和 chunked context；明确要求按 workload/SLO 调节 `max_num_tokens`。

## 覆盖限制

- 这是针对“问题是否基本解决”的聚焦调研，不是所有 2022—2026 serving 论文的穷举综述。
- Orca、vLLM、DistServe 为摘要、方法关键段和主要结果级 `skimmed/source-checked`；本轮不创建重复 paper-note。
- Sarathi-Serve 与 NanoFlow 复用 Wiki 已有 deep-read 笔记；没有本地复现实验。
- 工程功能会随版本演化，官方文档状态仅代表检索日。
