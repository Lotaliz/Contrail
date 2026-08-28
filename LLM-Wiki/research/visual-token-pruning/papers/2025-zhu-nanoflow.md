---
id: paper-note-zhu-2025-nanoflow
type: paper-note
title: "NanoFlow: Towards Optimal Large Language Model Serving Throughput"
authors: ["Kan Zhu", "Yufei Gao", "Yilong Zhao", "Liangyu Zhao", "Gefei Zuo", "Yile Gu", "Dedong Xie", "Tian Tang", "Qinyu Xu", "Zihao Ye", "Keisuke Kamahori", "Chien-Yu Lin", "Ziren Wang", "Stephanie Wang", "Arvind Krishnamurthy", "Baris Kasikci"]
year: 2025
venue: "OSDI 2025"
source_id: paper-zhu-2025-nanoflow
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, model-serving, efficient-inference, efficiency-evaluation, hardware-aware-optimization]
status: active
related: [visual-token-pruning]
created: 2026-08-27
updated: 2026-08-27
---

# NanoFlow

## 一句话结论

NanoFlow 重新判定了 LLM serving 的瓶颈：单个 decode attention 可能 memory-bound，但在大 batch、GQA 和大模型条件下，端到端 workload 往往是 **总计算量主导，却因 compute/memory/network 算子串行而只获得低整体利用率**。它将一个 batch 拆为 nano-batches，在单 GPU 内跨算子流水重叠异构资源，并通过干扰感知的两阶段 MILP 搜索自动生成执行计划。

## 问题场景

- 面向高负载、吞吐优先的在线/离线 LLM 服务，关键指标是 per-GPU total token throughput（输入与输出 token 均计入），目标是降低大规模 GPU 服务成本（§1、§3.1，pp. 749–752）。
- 论文挑战了“LLM serving 总是 memory-bound”的常见叙事：batching 摊薄权重读取，GQA 减少 KV 读取，大模型的 GEMM 计算量相对 attention 更占主导；因此很多生产型 workload 的 aggregate bottleneck 是 compute（§1、§3.3–3.4，pp. 749–754）。
- 现有引擎让 GEMM、decode attention 和 collective communication 在 device 内顺序执行；单个算子可达到其瓶颈资源约 80% 利用率，但 LLaMA-2-70B 端到端 compute utilization 只有约 40%，异构资源之间存在 pipeline bubbles（§1、§3.6，pp. 750, 754–755）。

## 工作量与创新点

### 1. 成本模型与“最优吞吐”上界

- 从显存容量/带宽、峰值算力、互联带宽、模型参数/GQA、请求长度和最大 batch 推导 memory、compute、network 时间，并用三者最大值确定 workload bottleneck（Eq. 1–4，§3.1–3.4，pp. 752–754）。
- 在 compute-bound 假设下得到 `Throughput_optimal = Compute / (2 × P_model)`；LLaMA-2-70B、8×A100 上以 CUTLASS 实测峰值 280 TFLOPS 估算 1,857 token/s/GPU（Eq. 5，§3.5，p. 754）。
- 该上界把“比 vLLM 快多少”升级为“距硬件可达上界还有多远”的效率评价，但它是条件化 roofline 上界，不等同于所有 workload 上被证明可达的全局最优。

### 2. Nano-batching 与 intra-device parallelism

- 将每个原始算子复制为处理独立输入子区间的 nano-operations；不同 nano-batch 之间无数据依赖，于是 compute-bound GEMM、memory-bound attention 和 network-bound collective 可以并发（§3.7、Fig. 4，pp. 754–755）。
- 代价是重复加载权重、损失大 batch 的摊销；只有在 aggregate compute-bound 且重叠收益能隐藏额外 I/O 时才值得（§3.7）。

### 3. 干扰感知的两阶段自动搜索

- 先 profile 不同 batch/kernel 形状与 GEMM–GEMV、GEMM–network 的 pairwise interference，以 GEMM 性能作为 GPU 资源份额代理，建立 `resource utilization R → normalized performance P` 映射（§4.1.1、Fig. 5/Table 3，pp. 755–757）。
- Stage I 用 MILP 搜索 nano-operation 数量、大小和顺序，以消除 compute bubble；Stage II 固定结构，再根据实测 interference 分配资源/选择 kernel，最小化 pipeline time（§4.1.2–4.1.3，pp. 757–758）。
- 搜索并非求证最优：完整搜索可能耗时数小时/数天，系统以约 10 分钟找到 practical feasible pipeline（§4.1.2，p. 757）。

### 4. 端到端 runtime，而非纯 schedule 原型

- runtime 支持多 CUDA stream/event、异步 batch formation、固定 dense batch、chunked prefill、PagedAttention、未来显存预测与 OOM 时 CPU offload，以及多轮会话 KV 的 CPU/SSD 分级缓存（§4.2、§5，pp. 758–759）。
- 实现约 **10K 行 CUDA + 6K 行 Python**，表明主要工作量在自定义 kernel、profiling/search 与完整服务运行时协同，而不是单一算法模块（§5，p. 759）。

## 实验设计与每组实验的目的

### 总体设置

- **硬件**：8×A100 80GB SXM，NVLink；主要模型 LLaMA-2-70B，FP16；另覆盖 LLaMA-3-70B/8B、Qwen2-72B、DeepSeek-67B、Mixtral-8×7B（§6.1、§6.6，pp. 759, 761）。
- **基线**：vLLM、DeepSpeed-FastGen、TensorRT-LLM，记录具体版本/commit，并分别调 max batch/max tokens 与 Paged KV 等设置（§6.1，pp. 759–760）。
- **workload**：固定 512/512、1024/512、512/1024，以及 Splitwise production trace（约 20K 请求）、LMSYS-Chat-1M、ShareGPT；后两者各采样 50K 请求（Table 4、§6.1–6.2，p. 760）。

### E1：离线吞吐与理论上界——证明主要 claim

- 在固定长度和真实长度分布上测 total tokens/s/GPU，并与 1,857 token/s/GPU 上界对照（Fig. 7、§6.2，p. 760）。
- 目的：同时回答“超过成熟引擎多少”和“关闭了多少 optimality gap”。
- 结果：固定长度下相对 vLLM/DeepSpeed/TensorRT-LLM 平均 2.62×/2.78×/1.73×；真实 trace 下为 4.18×/3.45×/1.91×；最好达到理论上界的 68.5%。

### E2：在线 latency–rate 曲线——证明高吞吐并非完全牺牲 SLO

- arrival interval 服从指数分布，生成 5 分钟 trace；以 request E2E latency/output length 的平均值为 normalized latency，采用 200 ms/token SLO（Fig. 8、§6.3，pp. 760–761）。
- 目的：检验大 dense batch 对低负载延迟的负面影响，以及饱和前能支持的最大请求率。
- 结果：低 rate 下 NanoFlow 延迟相近但略高；在 LMSYS-Chat-1M 上，相同 SLO 内可比 TensorRT-LLM 支持 1.64× 更高 request rate；接近最大吞吐时 P99 约为平均延迟的 1.07×。

### E3：消融——区分切分开销与重叠收益

- 构造 sequential non-overlap、nanobatch-only、完整 NanoFlow、带 offload 的 NanoFlow（Fig. 9、§6.4，p. 761）。
- 目的：避免把收益误归因于切小 batch；事实上 nanobatching 单独使性能下降 13.2%，说明核心来自异构资源重叠。
- prefill-only 用来隔离 network+compute overlap，decode-heavy 用来加入 memory overlap；相对 non-overlap 分别提升 1.07×/1.17×。KV offload 因干扰降低 3.0% pipeline 性能，但多轮 LMSYS 场景可减少 3.02× 重计算。

### E4：资源时间线——验证机制确实提高并发资源利用

- 比较普通执行与 NanoFlow 在一层内的 compute/memory/network utilization timeline（Fig. 10、§6.5，p. 761）。
- 目的：提供因果链中间证据，而不只给端到端 speedup；完整系统平均 compute utilization 约 68.5%，剩余差距归因于 kernel interference。

### E5：跨模型泛化——验证自动搜索而非手调单一模型

- 在多种 dense/MoE 模型上统一使用 1024 input/512 output，除 8B 单卡外均为 8×A100（Fig. 11、§6.6，p. 761）。
- 目的：证明 search 能适配模型架构差异；结果为理论上界的约 50%–72%（图中最高 78.5%），均超过 vLLM。

## 局限与证据边界

- “最优吞吐”依赖最大可驻留 batch、aggregate compute-bound 和 CUTLASS 峰值假设；LLaMA-3-8B 的长 decode 已接近 memory/compute 分界，memory-bound、小 batch 或延迟优先 workload 不应直接套用 Eq. 5（§3.3–3.5）。
- 自动搜索 Stage I 只寻 practical solution；干扰模型主要基于 pairwise profile，并假定三类 kernel 同时重叠时映射仍成立（§4.1.1–4.1.3）。
- 实现和主实验集中在 NVIDIA A100；成本模型覆盖其他 accelerator，但 runtime portability 没有端到端验证。
- 低流量时大 dense batch 会令 latency 略差；因此 NanoFlow 的优势依赖足够高请求并发，不能视为普适低延迟方案（§6.3）。

## 与其他两篇论文/当前课题的关系

- [[LLM-Wiki/research/visual-token-pruning/papers/2024-agrawal-sarathi-serve.md|Sarathi-Serve]]在“每轮请求/token 如何组批”层面平衡 SLO；NanoFlow 在组好大批以后进一步调度“单卡内部哪些算子同时用哪些资源”。
- [[LLM-Wiki/research/visual-token-pruning/papers/2026-yu-prism.md|Prism]]解决多模型跨 GPU 的 residency 与 KV memory 共享；NanoFlow 假定一个模型实例已有足够稳定的大 batch。
- 对 Guard 轻量化系统的启示是：剪枝减少 FLOPs 后，瓶颈可能转向 memory/kernel launch/scheduling；只报告参数量或 FLOPs 不够，必须用类似 cost model 和 resource timeline 验证压缩后真正的瓶颈迁移。

## 来源

- 官方论文页面：https://www.usenix.org/conference/osdi25/presentation/zhu-kan
- 本地原文：`LLM-Wiki/raw/papers/2025-zhu-nanoflow.pdf`
