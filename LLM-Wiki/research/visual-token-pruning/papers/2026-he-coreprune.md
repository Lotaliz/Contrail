---
id: note-2026-he-coreprune
type: paper-note
title: "From Token Importance to Conditional Removability: Rethinking Visual Token Pruning in Multimodal Large Language Models"
authors: ["Shengli He", "Yongchao Liang", "Roumeng He", "Junjie Zeng", "Jiyuan He", "Xin Fang", "Can Wu", "Li Zheng"]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-26484
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, efficient-inference, training-free]
status: active
created: 2026-09-25
updated: 2026-09-25
---

# CoRePrune：深度与删除集合条件下的视觉 token 可移除性

## 来源与阅读边界

来源：[arXiv 2609.26484v1](https://arxiv.org/abs/2609.26484)，2026-09-22 首次提交；本地原件 [[LLM-Wiki/raw/papers/2609.26484v1.pdf]]，24 页。已核对正文 §I–VIII、表 I–VII 与附录 A、C–E 的配置、消融及反事实诊断。未运行代码、模型或时延实验；数值均为作者报告。与作者早前 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 的比较须按本论文各表注明的同一设置读取。

## 研究问题与可移除性定义

论文区分“某 token 的重要度”和“删除它的后果”。在固定层的一个注意力头中，删除集合 $S$ 后，剩余 token 的注意力被共同重归一化；注意力输出扰动同时受被删注意力质量、被删 value 与原输出的差异、以及被删 value 之间的方向相互作用影响。作者以问题 token 接收位置 $Q$ 上的均方扰动定义 $D_\ell(S;Q)$，单个 token 的删除代价为 $d_\ell(i;Q)$，当前删除集合中的**救回边际**为 $\Delta_i(S)=D(S)-D(S\setminus\{i\})$。$\Delta_i$ 会随层深 $\ell$ 与其余删除项 $S$ 变化；这是局部注意力输出代理，不等同于最终答案正确性。证据：§III、式 (1)–(7)。

作者先做两组受控诊断。深度诊断在完整模型的深层挑定相同 Bottom-25% token ID，分别于 pre-LLM、decoder L0/L2/L4/L8 删除，保持位置 ID；L8 相对 pre-LLM 在四个模型–数据组合上的 final-hidden 相对误差均值降低 31.4%，幸存 token 排名位移降低 37.2%，teacher-forced 答案 token KL 降低 57.7%。趋势是两端对比，**相邻层不严格单调**；更晚删除也缩短扰动传播路径，不能把全部差异归因于表示成熟。附录 E 在视觉塔早晚端点和持续低显著性的同 ID 集合上复核了早删扰动较大，但后者实际交集远小于名义 Bottom-50%。证据：§IV-A、图 2、附录 E 表 S16–S19。

集合诊断固定层、表示和同一组候选，仅把虚拟删除背景从 $S_{25}$ 扩至 $S_{75}$。全局救回排名仍较相关（LLaVA Spearman 0.872、Qwen3.5 0.936），但最高四分之一救回边界分别替换 30.8% 和 19.6%。因此固定单 token 排名可在最终选择边界失效；这些数值是 MME 上的局部代理诊断，尚非任务准确率的因果提升。证据：§IV-B、图 3、附录 D 表 S12。

## 两阶段推理流程

**Stage 1：视觉编码器内的渐进筛选。**原始 $N_0$ 个架构对齐的视觉候选（标准 patch 或原生合并后的候选单元）在固定的七个视觉层按线性日程减至中间预算 $K_V$。每到一个剪枝层，用当前表示重新计算 singleton 注意力输出扰动，删掉最小的一批，保持剩余原始时空顺序。它只用视觉接收位置，没有用户问题/政策条件；最早剪枝层为 LLaVA-1.5 的视觉层 8、Qwen3.5 的视觉层 9，前面的视觉层不会被节省。证据：§V-A/B、式 (16)–(20)、附录 A 表 S1。

**Stage 2：decoder 中段的集合条件细化。**Stage 1 的 $K_V$ 候选先在 zero-based decoder layer 7 完成一次正常 prefill，随后用该层同一次运行的注意力/value 张量做虚拟删除：初始把整个候选集视为 $S=C$，反复重新计算 $\Delta_i(S)$，每轮救回最多 $B=4$ 个 token，直到保留 $K_L$ 个；再物理缩短序列供 layer 8 以后使用。没有额外模型前向或参数更新，但须支付前 8 个 decoder 层、问题接收位置与反复评分成本；$B=4$ 是批量 reverse-greedy 启发式，没有次模最优保证。理论评分复杂度为 $O(H|Q|d_hK_V\lceil K_L/B\rceil)$。证据：§V-C、图 4、式 (21)–(23)。

各 backbone 的预算固定而非逐数据集调参，例如 LLaVA-1.5 为 $576\to128\to\{128,64,32\}$，Qwen3.5 为 $1024\to256\to\{256,196,128,64\}$。有些视觉候选对应原生 2×2 patch 合并单元，结构 token 不计在报告的预算里；不同模型的 token 数不能直接当作相同图像信息量。证据：§V-A、附录 A 表 S1。

## 实验、消融与速度

- 五个主要 backbone 覆盖 LLaVA-1.5/1.6、Qwen3.5-9B、InternVL3.5-8B、LLaVA-Video；GLM-4.6V-Flash 另用于日程消融。图像任务含 VQAv2、GQA、TextVQA、POPE、MME、MMBench、ChartQA/OCRBench 等；视频任务含 MVBench、LongVideoBench、Video-MME。Avg. Rel. 是相对 dense 模型的**按任务等权平均百分比**，不是统一准确率。LLaVA 主结果用 10 项，方法消融仅用 7 项，不能跨表直接比较同名平均值。参数冻结、无需校准数据；硬件为一张 RTX 5880 Ada 48 GB。证据：§VI-A、附录 A/C。
- 表 I：LLaVA-1.5 于 $K_L=128/64/32$ 的 Avg. Rel. 为 98.3/97.5/94.7，低于同表 QCPruner 的 99.3/98.2/96.1；因此“CoRePrune 全面优于 QCPruner”不成立。表 II：Qwen3.5 同模型在 $K_L=256/128/64$ 为 93.4/90.3/83.1，高于 QCPruner 的 92.8/86.5/80.4。表 III 在另外三种模型九个预算点中，相对最佳**效率导向**基线有七点领先、两点略落后；视频 FastVID 的全局预算分配与逐帧法仅匹配总 nominal budget。证据：§VI-B、表 I–III。
- 在完全相同的 Stage 1 候选和最终预算下，集合重评比静态 Top-K 提高 LLaVA 0.5–1.8 个 Avg. Rel. 点、Qwen3.5 0.7–1.2 点；七任务消融与主表口径不同。Stage 1 渐进日程比最早层一次删完高 0.4–5.2 点，但 Qwen3.5 的晚层一次删完 91.0 仍超过渐进 90.3。完整扰动式仅比 attention-only 的 Qwen3.5-128 结果高 0.5 点；$B=1,2,4,8$ 的平均值仅波动 0.1 点。证据：§VI-C–F、表 IV–VI、附录 C 表 S7–S11。
- 单张 RTX 5880 Ada 上以 1,500 条 TextVQA、每条 16 个 decoding steps、三次重复计时，Qwen3.5、$K_L=128$ 的总 prefill 为 dense $323.4\pm2.5$ 秒、CoRePrune $158.3\pm1.8$ 秒（降低 51.0%）、QCPruner $194.2\pm0.4$ 秒、DivPrune $140.2\pm0.3$ 秒。CoRePrune 的 decode 为 24.3 秒，与 dense 23.8 秒相近；峰值显存仅从 18318.0 降至 18214.4 MB。prefill 已计入选择器；Set-Greedy 相对静态 Top-K 的 selector-only 开销为 6.91 ms/样本。此处不是完整服务端到端 latency，也不能把 51.0% 归因于集合重评单一组件。证据：§VI-G、表 VII、附录 C 表 S10。

## 边界与对当前项目的意义

作者的深度/集合诊断支持“删除后果是条件量”，但 $D(S)$ 只是当前层、当前接收位置的注意力输出扰动；表 IV 给出匹配条件下的真实任务增益，幅度一般为 0.5–1.8 点。论文也承认表示成熟度与扰动传播长度未完全解耦，未来需固定传播长度对照。紧预算需要足够大的 $K_V$，扩大候选池又升高 prefill 成本；相对 DivPrune 仍慢，显存收益很小。证据：§VI-E–VII、表 IV–VII。

**项目判断：**这篇论文直接挑战以单一固定排序定义“安全可删 token”的方法，也使政策翻转场景中按政策重评保留集合成为值得实验的假设。但 Stage 1 无政策条件且最早在视觉层 8 开始，Stage 2 又在 decoder L7 后，不能作为“ViT 前、短政策驱动且端到端最快”的现成实现。应分别对照 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 的双 cue coverage、[[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-std.md|STD]] 的分阶段视觉塔规则，测同图政策翻转、unsafe recall/FPR、关键区域丢失与 selector-inclusive 计时。该实验方案是本项目推论；论文没有安全 Guard 或政策数据的验证。

## 证据定位与待验证

- 局部扰动、单 token 与集合救回定义：§III、式 (1)–(7)；深度/集合诊断：§IV、图 2–3、附录 D/E。
- 预算、视觉塔七层日程、decoder L7 后细化：§V、图 4、附录 A 表 S1。
- 跨模型任务表、受控选择器和日程消融、实际时延：§VI、表 I–VII、附录 B/C。
- TODO：审查公开实现是否与原文索引、结构候选及计时边界一致；在当前 Guard 上分别固定预算、层位和 $K_V$ 比较 singleton 与 set-conditioned 选择。本轮未执行。
