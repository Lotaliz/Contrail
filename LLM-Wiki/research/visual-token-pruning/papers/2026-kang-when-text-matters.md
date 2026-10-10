---
id: note-2026-kang-when-text-matters
type: paper-note
title: "When Text Matters: Design Principles for Visual Token Pruning in Vision-Language Model"
authors: [Minchan Kang, Kyeonghye Park, Seoyoung Cho, Daeshik Kim, Yucheol Cho]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-34861
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, training-free, vision-language-model, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# When Text Matters：保留候选、延迟文字重选

## 原件与阅读范围

用户在候选索引选中本文。原文为 [arXiv 2609.34861v1](https://arxiv.org/abs/2609.34861v1)，arXiv non-exclusive distribution license；完整 HTML 原件见 [[LLM-Wiki/raw/papers/2609.34861v1.html]]。核对 §3–5、图 2–8、表 1–7 和附录 A–D 的选择、预算、kernel 和计时口径。未运行代码或模型，全部实验数值为作者报告。

PDF 原件另见 [[LLM-Wiki/raw/papers/2609.34861v1.pdf]]（23 页）；完整文件已解析，关键图表与 HTML 数字交叉核查，SHA256 登记在同一 source_id 的 local_artifacts。

## 文字何时有效的诊断

§3.1 在 TextVQA、ChartQA、InfoVQA、AI2D 各采样 300 张有两问的图，将视觉网格分成八区，Dense 模型逐区 mask 后测正确答案平均 NLL 增量，作为**离线诊断**的 region importance。比较 matched/swap 两问的 attention 与各自 importance 的 Spearman；早期 decoder 的一致性弱，中间层更强，matching-question 相对 swapped-question gain 为正。

正确答案仅用于诊断，不用于部署选择。mask 影响是针对该模型与区域划分的反事实敏感度，不是自然目标框标签；也不能推广为所有文字条件、所有任务都要延迟。表 1 在相同 visual-token processing budget 下比较 9/18/22/27-block 边界，18-block midpoint 的三模型均值 92.806，高于诊断峰值 22-block 的 91.833，说明最强语义信号不必是最优成本点。

## 两阶段算法与真实工作量

§3.2：在完整视觉编码后，用 head-averaged encoder attention 排序；有 CLS 取 CLS→patch，无 CLS 汇总视觉 queries 对各 visual key 的 attention。最终目标 $K\approx(1-p)N$，先保留候选

$$M=\min\{N,K+\lceil\alpha(N-K)\rceil\},\qquad\alpha=0.2,$$

至 decoder 中点 $L=D/2$。此时仅用输入 prompt 的 native query/key 重算 text→visual attention，沿 heads 平均、文本位置求和，在候选内取最终 top-$K$。不依赖答案或新生成 token，参数不训练；候选外已删的 token 不会恢复。缺少 kernel 暴露的概率时，需另从 Q/K 计算分数。

附录 A.1 用 $B_{vis}=LM+(D-L)K\approx DK+\alpha L(N-K)$ 匹配深度与 progressive baselines。比如 $p=0.8,\alpha=0.2$ 时，前半深度约 0.36N、后半 0.20N，平均约 0.28N；“最终剪 80%”不等于全主干只处理 20%。同最终比例的 pre-LLM 方法与本文工作量不同；SparseVLM 及附录 C 的 PyramidDrop/FlowCut 另外按 token–block workload 匹配，但它仍不是精确 quadratic attention 或 wall time 等价。

## 数据、结果与消融

§4：Qwen3-VL-4B/8B、LLaVA-OneVision-1.5-8B；八个完整测试集为 TextVQA、MMMU、AI2D、MMStar、ChartQA、NoCaps、TextCaps、InfoVQA。指标分别含 VQA credit、accuracy、relaxed correctness、CIDEr 和 ANLS。Avg. Rel. 是每任务相对 Dense 的等权平均，不是原始平均准确率，亦可超过 100%。

- 表 2–4：80%/90% 档 Avg. Rel. 为 Qwen4B 90.86/82.91、Qwen8B 94.79/90.65、LLaVA-OV 92.77/86.47。最显著收益集中 OCR/chart/infographic；不保证各子任务每个预算均最好。
- 图 5：A 立即保留 vision top-$K$，B 先保留较大池但最后仍取同一个 vision top-$K$，C 保持与 B 同 token 轨迹但由 midpoint text 重选。B→C 支持重选价值，A→C 还混有额外早期计算。
- 附录 B 表 6：约 39–45% 最终 token 来自原 vision top-$K$ 以外的 reserve；相同轨迹的收益在 InfoVQA/ChartQA 较大，Qwen8B MMStar 仅 +0.11 个百分点，效果不均匀。
- 附录 C 表 7 在同 per-input token–block 预算下，Qwen8B 的 FlowCut/PyramidDrop 为 85.28/75.53 与 81.18/62.83，低于本文 94.79/90.65；这些比原始最终 token 数更可比，但仍需实现级核验。

## 计时与 KV 限制

§4.4 表 5：一张 RTX A6000、100 个按大小/宽高比分层的固定 InfoVQA 输入、三次 timed repetitions；prefill 包含 selection overhead。80% 档 Dense/本文 LLM prefill 为 226.66/121.20 ms；标为 End-to-end 的 364.13/282.35 ms 实际是**GPU-ready input 到第一个输出 token**，排除 CPU preprocessing/transfer，不是完整生成结束时延。90% 档为 prefill 108.37、该 TTFT 口径 268.50 ms。

附录 A 明确所有方法 task evaluation 禁用 KV cache；Qwen 多数用 FlashAttention-2，RESTORE 为 SDPA，LLaVA-OV 全部 SDPA。正文没有提供真实 cache-enabled decode 服务的对等性能，也不能直接据此回答在线 KV compaction、batch 动态策略或长答案的成本。图 8 analytical FLOPs 又排除视觉前端和选择开销，须与 measured first-token 指标分开。

## 与近邻和 C5 的关系

与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-trevs.md|TReVS]] 不是简单冲突：TReVS 早阶段使用 projected visual/text embedding 相似度，本篇否定的是被测试早 decoder 原生 attention 的选取效果。与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 同样付出部分主干计算换语义信号，但这里保留视觉候选后用 attention top-$K$，没有双边集合覆盖。关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]。

**本项目判断：** paired matching/swapped text 和正确答案 NLL 的区域干预适合审计政策条件信号；保留可重选候选也能作为“过早不可逆选择”的对照。但 C5 为 pre-ViT/单局部框路线，不能付出半个 LLM 后宣称同样早期加速，更不能把通用 query 的成功等同于 policy flip/Unsafe recall 保证。TODO：同成本低清政策 selector、保留候选与位置控制、cache-enabled decode 和端到端计时。本轮不创建 concept 或修改正式研究动机。
