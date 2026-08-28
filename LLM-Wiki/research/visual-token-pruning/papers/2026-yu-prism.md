---
id: paper-note-yu-2026-prism
type: paper-note
title: "Prism: Cost-Efficient Multi-LLM Serving via GPU Memory Ballooning"
authors: ["Shan Yu", "Yifan Qiao", "Mingyuan Ma", "Yangmin Li", "Shuo Yang", "Xinyuan Tong", "Yang Wang", "Zhiqiang Xie", "Yuwei An", "Shiyi Cao", "Ke Bao", "Deepak Vij", "Xiaoning Ding", "Yichen Wang", "Qingda Lu", "Zhong Wang", "Gao Gao", "Harry Xu", "Junyi Shu", "Jiarong Xing", "Ying Sheng"]
year: 2026
venue: "OSDI 2026"
source_id: paper-yu-2026-prism
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, model-serving, slo-aware-serving, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-27
updated: 2026-08-27
---

# Prism

## 一句话结论

Prism 的核心不是“更快换模型”，而是从四份生产 trace 中抽象出 **shifting bursty groups + request-level volatility**：纯 space sharing 会把内存锁给长时间 idle 的模型，纯 time sharing 又在多模型交错 burst 时反复换入换出。它把权重与 KV cache 都降到 GPU virtual-memory 层统一管理，通过 memory ballooning 连续地在两种共享模式之间切换，再以全局 placement 和 GPU-local deadline arbitration 协调 SLO。

## 问题场景

### 多模型服务的特有约束

- 推理提供商必须保持大量热门、长尾、微调模型可用；为保证即时响应，常为每个模型预留 model-parallel GPU group，但生产 GPU duty cycle 常低于 30%（§1，pp. 75–76）。
- 关键 SLO 是 TTFT 与 TPOT；显存主要由静态模型权重和随并发/序列增长的 KV cache 占据（§2，pp. 76–77）。
- PagedAttention 只解决单模型内部 KV block fragmentation；每个 serving engine 仍预分配自己的大 KV tensor pool，不能把空闲物理内存跨模型回收（§2、§5.1，pp. 76–80）。

### 生产 trace 揭示的研究问题

- 四份 trace 来自 Hyperbolic、Novita AI 和 Chatbot Arena，覆盖 16–129 个模型、11 天至 16 个月；论文的详细 characterization 发现平均同时活跃模型仅占 23%–50%，active set 每小时变化 54–66 次，Novita 模型平均 idle 超过 70%（Table 1、§3.1，pp. 76–78）。
- **模型层 shifting bursty groups**：某一时刻只有不断变化的一组模型真正需要资源，静态空间切分让 idle 模型的权重/KV reservation 阻止活跃模型扩张（Fig. 1、§3.1）。
- **请求层 volatility**：多个模型的 burst 突然交错，纯时间共享会不断 swap，产生 model thrashing；不同模型还具有持续热门、短促辅助调用等异构 activation pattern（§3.1–3.2，pp. 77–78）。
- 因此场景的核心不是平均负载低，而是 **工作集跨模型迁移速度快于静态配置，局部到达又快到不适合频繁完整换模**。

## 工作量与创新点

### 1. 工作负载发现：为 hybrid sharing 建立实证动机

- 论文不是从机制反推场景，而是先比较生产 workload 的模型层/请求层行为，再通过 MuxServe 与 QLM 类策略的 trace replay 展示 space-only 的 fragmentation 和 time-only 的 thrashing（§3.1–3.4，pp. 77–79）。
- 这构成系统论文的重要创新：把“空间共享 vs. 时间共享”从静态二选一改写为随 bursty group 动态变化的连续资源问题。

### 2. kvcached：GPU memory ballooning 机制

- 作为 inference engine 与 GPU memory 之间的 shim，为每个 engine 保留大 virtual address space，但仅按需分配/映射 physical pages；统一管理 weights、KV pools 和 intermediate buffers（§5.2、Fig. 4，pp. 80–81）。
- 提供 elastic tensor（eTensor）PyTorch extension，使 SGLang/PagedAttention/attention kernel 与 CUDA graph 无需改写；跨模型以 2 MB page 粒度回收物理内存（§5.2）。
- 为异构模型设计 token-block → virtual/physical page 自动映射，并把不同模型 token 隔离在不同 page；通过跨层连续 virtual layout、异步 page pre-allocation 和优先填部分 page，降低 2L 次分配和碎片（D1–D4，§5.2）。

### 3. 快速 activation/migration

- reusable engine pool 解耦 engine 与 model 生命周期，保留 virtual address space/distributed context；新模型无需重新初始化整个 serving engine（§5.3，p. 81）。
- 权重切片后借同节点多 GPU 并行 CPU→GPU load，再经 NVLink 聚合到目标卡；每卡只需约 30 MB streaming buffer，以减少对在线 workload 干扰（§5.3）。
- migration 时保留源实例继续服务，目标 ready 后再切换；NVLink/RDMA 是加速路径，没有时退回 eviction+reactivation（§6.1，pp. 82–83）。

### 4. 两级 memory-centric control plane

- **全局 placement**：以 KV Pressure Ratio（KVPR）表示 SLO 加权 token/KV 增长压力与剩余 shared KV capacity 的比值，贪心地把高压力模型放到最低 KVPR GPU，并设 migration threshold 避免边际迁移（Algorithm 1、§6.1，pp. 82–83）。
- **GPU-local arbitration**：每 GPU 共享请求队列，按 TTFT deadline 排序，并用 Moore–Hodgson 移除执行时间最长且会造成 deadline miss 的请求；建立在 chunked-prefill 可估算 prefill completion time 的条件上（Algorithm 2、§6.2，pp. 83–84）。

### 5. 系统与部署工作量

- 原型约 **10,400 行 Python + 774 行 C++**；kvcached 基于 CUDA VMM API，集成 SGLang 只需 22 行修改；前端用 Redis，global scheduler 用 ZeroMQ（§7、p. 84）。
- balloon driver 已开源，并报告截至论文时在多个组织、10K+ GPU 上部署；生产评测使用 shadow replay 控制 workload 差异（Abstract、§7.6，pp. 75, 88）。

## 实验设计与每组实验的目的

### 总体设置

- **集群**：4 节点，每节点 8×H100-80G、600 GB/s NVLink，节点间 100 Gbps Ethernet，合计最多 32 GPU（§7.1，p. 84）。
- **基线**：static partition、MuxServe++、QLM、ServerlessLLM。作者将 MuxServe 移植到 SGLang，并以 kvcached 泛化异构模型，先验证其性能不弱于原实现（Table 2、§7.1）。
- **trace/模型**：端到端实验用 Hyperbolic 与 Arena-Chat，模型覆盖 1B–70B 共 58 个；通过乘请求数的 rate scale 增压但保持原始时序形状（Table 3、§7.1，pp. 84–85）。
- **SLO/指标**：每模型先独占 GPU 测 P95 TTFT/TPOT，得到 base SLO（TTFT 0.04–0.13 s、TPOT 5.2–50.9 ms），再乘 scale；主指标为 TTFT/TPOT attainment 和 throughput（§7.1）。

### E1：端到端 rate/SLO/GPU 三维扫描

- **变 rate**：2 GPU 服务 8 模型，逐步放大 trace；检验动态 load 下 99% attainment 的容量边界（Fig. 5 第一行、§7.2，p. 85）。Prism 在 Hyperbolic 上以 99% attainment 支持比 MuxServe++/static 多 2.3×/3.5× 请求，在 Arena-Chat 上比所有基线多 3×以上。
- **变 SLO scale**：检验收益是否只依赖宽松 deadline（Fig. 5 第二行）。Prism 很快达到 99% TTFT/TPOT，而 baseline 最大 TTFT attainment 仍明显较低。
- **变 GPU 数**：18 个 1B–8B 模型，检查相同 SLO 下的成本效率（Fig. 5 第三行）。Prism 在两个 trace 上仅用 4/5 GPU 达到 99% TTFT/TPOT，基线即使用 8 GPU 仍无法全部达到 99% TTFT。

### E2：cross-model ballooning microbenchmark

- 从 Arena-Chat 取双模型 trace，对比 on-demand memory 与 per-model static partition，画 request rate、KV memory 和 aggregate throughput（Fig. 6、§7.3，pp. 85–86）。
- 目的：直接证明当 Model1 负载下降、Model2 burst 时，空闲 KV capacity 能跨边界转移，并且吞吐提升来自更多可用 KV，而非 placement 的混杂效应。

### E3：两级调度分解

- **global placement**：2 GPU/8 模型，开关 scheduler，比较 TTFT/TPOT attainment 与每请求可用 KV（Fig. 7、§7.3，p. 86）；目的为验证 KVPR 确实均衡 memory pressure，而不是仅频繁迁移。
- **local arbitration**：固定 Model1 SLO、改变 Model2 SLO，开关本地 scheduler（Fig. 8）；Model2 attainment 提升超过 40%。目的为验证 shared queue 会优先短且 deadline 紧的请求，防止宽松 SLO 大流量模型垄断内存。

### E4：大规模成本实验

- 使用全部 58 模型、最多 32 GPU，扫描 cluster size 与 SLO scale（Fig. 9、§7.4，p. 87）。
- 目的：把小规模 attainment 结果转换为实际 capacity provisioning；Prism 用 16 GPU 达到近 99% TTFT，而 MuxServe++ 需 32 GPU 才接近，部分 SLO 点的 GPU 成本降低约 2×。

### E5：机制开销与生产验证

- activation latency：1B–70B 模型，分解 naive loading、pre-initialized engine、parallel loading；小模型 <0.7 s、14B 约 1.3 s、>70B 约 1.5 s（Fig. 10、§7.5，p. 87）。
- worst-case constant load：双 Llama-3.2-3B/A100-40G 下，相对 static 的 TTFT overhead 约 3%–4%，TPOT overhead 约 7%–13%（§7.5）。
- 生产 shadow replay：Company A per-GPU throughput 平均提高 3.89×且无 SLO violation；Company B revenue/GPU 提高 2.86×（Fig. 11、§7.6，p. 88）。目的在于证明实验室 trace replay 的收益能迁移到真实运营指标。

## 局限与证据边界

- workload characterization 使用四份 trace，但主端到端评测使用其中两份并对请求数做比例缩放；rate scaling 保留时序形状，却未必复现新用户行为、模型更新和跨服务相关性。
- 快速 loading 的最好路径依赖节点内多 GPU 与 NVLink；论文给出 RDMA/普通重载 fallback，但主要 testbed 是高带宽 H100 节点，对弱互联环境的端到端收益证据较少。
- global eviction threshold 来自 idle interval 分布，是 workload-dependent heuristic；输出长度未知时 KVPR 依赖近期 token-rate 代理，而不是未来精确内存需求（§6.1）。
- local scheduler 的最优 TTFT attainment 结论依赖 chunked prefill 每 step 运行且 prefill cost 可估算；TPOT 主要被间接改善，并非同一算法的联合最优保证（§6.2）。
- MuxServe++ 借用了 Prism 的 kvcached 以支持异构模型，这增强了 baseline，但也意味着比较的是作者重构版而非原系统原样部署。

## 与其他两篇论文/当前课题的关系

- [[LLM-Wiki/research/visual-token-pruning/papers/2024-agrawal-sarathi-serve.md|Sarathi-Serve]]解决单模型副本内 prefill/decode 干扰；Prism 直接复用 chunked prefill 的可估时特性，但优化的是多模型之间的 weights/KV ownership。
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhu-nanoflow.md|NanoFlow]]追求稳定大 batch 上的单设备资源重叠；Prism 先解决模型是否驻留、每模型能拿多少 KV 和请求是否获准进入执行。
- 对多 Guard 场景的启示：当供应商同时维护文本、多模态、策略专用 Guard 时，长尾可用性和 bursty-group 可能比单一 Guard 参数量更决定成本；轻量化可以减少 residency pressure，但仍需跨模型 elasticity 与安全 SLO-aware arbitration。

## 来源

- 官方论文页面：https://www.usenix.org/conference/osdi26/presentation/yu-shan
- 本地原文：`LLM-Wiki/raw/papers/2026-yu-prism.pdf`
