---
id: paper-note-agrawal-2024-sarathi-serve
type: paper-note
title: "Taming Throughput-Latency Tradeoff in LLM Inference with Sarathi-Serve"
authors: ["Amey Agrawal", "Nitin Kedia", "Ashish Panwar", "Jayashree Mohan", "Nipun Kwatra", "Bhargav Gulavani", "Alexey Tumanov", "Ramachandran Ramjee"]
year: 2024
venue: "OSDI 2024"
source_id: paper-agrawal-2024-sarathi-serve
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, model-serving, continuous-batching, slo-aware-serving, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-26
updated: 2026-08-27
---

# Sarathi-Serve

## 一句话结论

Sarathi-Serve 的贡献不是单独提出“切分 prefill”，而是把 **chunked prefill、decode-first 的 token-budget 调度和均匀微批**组成一套在线 serving 机制：限制每轮新增的 prefill 计算量，使正在 decode 的请求不再被长 prompt 阻塞，同时用混合批填补 decode 的算力空洞，并在流水线并行中减少 bubble。

## 问题场景

### 服务对象与目标

- 场景是多请求、在线、自回归 LLM inference；请求经历计算密集的 prefill 和逐 token、通常内存带宽受限的 decode（§1–§3.1，pp. 117–122）。
- 系统目标不是仅最大化离线 tokens/s，而是在给定 P99 time-between-tokens（TBT）SLO 下最大化单副本可持续请求率，即 serving capacity（§2.4、§5，pp. 120, 125–128）。
- 现有两类调度各有结构性缺陷：decode-prioritizing/request-level batching 会让批大小随早完成请求缩小，吞吐差；prefill-prioritizing/iteration-level batching 会让长 prefill 插入正在生成的批次，造成秒级 generation stall 和 P99 TBT 恶化（Fig. 1–2，pp. 117–119）。
- 跨节点大模型部署又引入第二个问题：TP 跨普通网络通信代价高，而 PP 的微批运行时间因 prefill/decode 长度异构而不均，形成 pipeline bubbles（§3.3，pp. 122–123）。

### 作者验证的关键观察

1. prefill 单请求已能接近饱和 GPU，继续 batching 收益小；decode batch 则随 batch size 增大显著提升吞吐（Fig. 3–4，§3.1，pp. 120–121）。
2. decode batch 的算术强度低、计算单元闲置，因此可把一部分 prefill 计算“搭载”进去；但完整长 prefill 会直接放大 TBT（Fig. 5–7，pp. 121–122）。
3. 论文因此把矛盾改写为：**每轮应允许多少 prefill token，既能填满 decode 的计算余量，又不突破 TBT SLO？**

## 工作量与创新点

### 1. Chunked-prefills：把不可控长作业变为有界计算单元

- 将一个 prompt 的 prefill 分多轮处理；chunk 仍足够大以保持较高 GPU 利用率，但单轮计算量受 token budget 限制（§4.1，pp. 123–124）。
- 分块不是免费的：后续 chunk 的 attention 要重读前序 KV，且小 chunk 增加 kernel launch/低算术强度开销；tile quantization 还会让不友好的尺寸（如 257 vs. 256）出现额外开销（§4.3，pp. 124–125）。

### 2. Stall-free batching：decode-first 的固定 token budget 调度

- 每轮先纳入所有正在运行的 decode token，再处理未完成 prefill，最后仅用剩余预算接纳新请求；若 prompt 超预算则只调度下一 chunk（Algorithm 3，§4.2，p. 124）。
- 这一顺序既不暂停已有 decode，也尽量不让新 prefill 饿死；相比无分块的混合批，Fig. 9 显示完整 prefill 可令 TBT 最高增加 28.3×，而分块给出更紧的延迟上界（pp. 123–124）。

### 3. 用均匀批次改善 pipeline parallelism

- 固定 token budget 让不同 micro-batch 的计算量更接近，减少 PP stage 等待；这使跨节点采用 TP4+PP2 而非 TP8 成为可行部署方案（§4.2、§5.3，pp. 124, 128）。

### 4. 系统实现工作量

- 基于 vLLM 扩展，加入 paged chunk prefill、FlashAttention v2/FlashInfer kernel、stall-free scheduler、PP 支持和 telemetry；TP/PP 通信使用 NCCL（§4.4，p. 125）。
- token budget 依赖模型—硬件—SLO 一次性 profiling，并借助 Vidur 选择容量最优点；论文实验仍主要使用固定预算 512/2048（§4.3、§5.1，pp. 125–127）。

### 创新性判断

单看“切 prefill”并不复杂；真正可发表的系统创新是把硬件观察、SLO 可控的调度不变量、混合批与 PP 均衡统一起来，并以 serving capacity 而非孤立 kernel speedup 证明端到端价值。

## 实验设计与每组实验的目的

### 总体设置

- **模型/硬件**：Mistral-7B/1×A100；Yi-34B/2×A100 TP2；LLaMA2-70B/8×A40 TP4-PP2；Falcon-180B/两节点共 8×A100 TP4-PP2，节点间 100 Gbps Ethernet（Table 1，§5，pp. 125–126）。
- **工作负载**：OpenChat ShareGPT4（median prompt 1,730/output 415）和 arXiv summarization（7,059/208），以 Poisson arrival 合成在线 trace；过滤总长度超过模型限制的异常请求（Table 2，§5，pp. 125–126）。
- **基线**：Orca 与 vLLM，分别代表 iteration-level batching 的不同实现/能力边界（§5，p. 126）。
- **指标**：P50 TTFT、P99 TBT、最大可持续 QPS；strict/relaxed TBT SLO 设为无 prefill 干扰 decode 延迟的 5×/25×，并要求 median scheduling delay 不超过 2 s（Table 3，§5.1，p. 126）。

### E1：容量对比——证明在 SLO 下的端到端收益

- 对四个模型、两个 trace、strict/relaxed SLO 测最大 capacity（Fig. 10–11，§5.1，pp. 126–127）。
- 目的：排除“只是单轮 kernel 更快”，证明机制在队列稳定和尾延迟约束下确实能承载更多流量。
- 结果：所有组合均优于 Orca/vLLM；代表性结果包括 Yi-34B strict SLO 下相对 vLLM 最高 3.7×，PP 大模型 LLaMA2-70B 相对 vLLM 最高 4.3×（正文 §5.1）。

### E2：扫描 TBT SLO——证明 tradeoff 可控而非偶然选点

- 改变 P99 TBT SLO，同时比较 vLLM 的 max batch size 32/64/128 与 Sarathi 的 token budget 512/2048（Fig. 12，§5.2，p. 128）。
- 目的：证明 vLLM 即使放大 batch 也会受 generation stall 限制，而 Sarathi 能通过 token budget 明确移动 latency–capacity 工作点。
- 结果：严格条件下代表性提升 3.5×；放宽条件下使用更大 token budget，代表性提升 1.65×（§5.2）。

### E3：跨节点 PP——证明“均匀批次”是独立系统贡献

- Falcon-180B 比较 TP8、vLLM TP4-PP2、Sarathi TP4-PP2（Fig. 13，§5.3，p. 128）。
- 目的：先证明跨节点 TP 的 decode TBT 更差，再检验 chunking 是否真的减少 PP bubbles。
- 结果：Sarathi 相对 vLLM hybrid PP 在 relaxed/strict SLO 下分别提高 1.48×/3.6× capacity；相对 TP-only strict 配置提高 4.3×（Fig. 13）。

### E4：开销与消融——验证两个机制缺一不可

- Fig. 14 测不同 prompt/chunk size 的纯 prefill 开销：chunk=512 时最高约 5%，chunk=2048 时近乎可忽略（§5.4.1，p. 129）。
- Table 4 分别启用 hybrid-batching-only、chunked-prefills-only 与组合：前者 TTFT 较好但 TBT 因长 prefill 恶化，后者 TBT 好但 TTFT 因分块变慢，组合同时改善二者（§5.4.2，p. 129）。
- 目的：把收益归因到“混合批填空洞 + 分块限制干扰”的协同，而不是任一组件单独成立。

## 局限与证据边界

- 作者明确未与 Splitwise/DistServe 等 prefill–decode disaggregation 做定量比较；后者可能有更优 TTFT，但需要 KV 迁移和专用资源，留作未来工作（§6，p. 129）。
- 最优 token budget 随 workload、硬件、并行配置和 SLO 变化；论文主要静态选值，动态调整尚未实现（§5.1，p. 127）。
- 消融只展示少量模型—硬件组合，作者称趋势一致，但公开表格不足以逐组合复核（§5.4，p. 129）。
- 论文优化的是有长 decode 阶段的生成服务；对只输出一个标签的 Guard，TBT/PP 收益可能明显减弱。可迁移的核心应是 **有界 prefill 干扰、time-to-verdict 和批次异构性**，不能直接照搬所有指标。

## 与当前课题的关系

- 对动态 Guard serving 的启示：token pruning 或可变主干会令每个请求的执行量更不均，系统需要类似 token budget 的可预测计算预算，而不能只把稀疏模型交给普通 continuous batching。
- 但 Guard 常为短输出分类器，因此应把 Sarathi 的 TTFT/TBT 改写为排队时延、time-to-verdict、P99 审查延迟和安全 goodput。
- 相关对照：[[LLM-Wiki/research/visual-token-pruning/papers/2025-zhu-nanoflow.md|NanoFlow]]将优化粒度下沉到单 GPU 内的算子重叠；[[LLM-Wiki/research/visual-token-pruning/papers/2026-yu-prism.md|Prism]]则上移到跨模型内存驻留与调度。

## 来源

- 官方论文页面：https://www.usenix.org/conference/osdi24/presentation/agrawal
- 本地原文：`LLM-Wiki/raw/papers/2024-agrawal-sarathi-serve.pdf`
