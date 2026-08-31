---
id: paper-note-alvar-2025-divprune
type: paper-note
title: "DivPrune: Diversity-based Visual Token Pruning for Large Multimodal Models"
authors: ["Saeed Ranjbar Alvar", "Gursimran Singh", "Mohammad Akbari", "Yong Zhang"]
year: 2025
venue: "CVPR 2025"
source_id: paper-alvar-2025-divprune
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, visual-token-pruning, vision-language-model, training-free]
status: active
related: [multimodal-token-pruning]
created: 2026-08-24
updated: 2026-08-31
---

# DivPrune: Diversity-based Visual Token Pruning for Large Multimodal Models

## 问题场景与系统边界

- **用户输入：** 图像或 8 帧视频加文本问题/指令，输出 caption、封闭/开放式 QA 或推理答案。
- **任务特点：** 高压缩时 attention importance 容易反复选择同一语义簇，虽然每个 token 单独得分高，整体却漏掉其他对象、区域或帧。论文关注 80% 以上的极端剪枝和低时延/受限资源部署（§1，pp. 9392–9393）。
- **系统特点：** CLIP 视觉塔与 projector 先生成视觉 token；DivPrune 默认在 LLM layer 0 前一次选子集，文本 token 不参与评分。它从第一层起节省 LLM/KV 成本、兼容 cache，但不减少视觉塔前向（§3.1–§3.3，pp. 9394–9395）。

## 核心问题与方法

论文认为高压缩下不应只追逐单 token importance，而应避免保留集合内部重复。DivPrune 把选择建模为 max-min diversity problem，在视觉 token 间最大化最小两两距离；在进入 LLM 的 layer 0 前一次执行，无需微调或校准集（§3）。

以 cosine distance 定义两 token 距离。算法先选“到其最近邻距离最大”的 token，之后迭代加入“到当前已选集合的最小距离最大”的候选，相当于 farthest-first 的精确贪心过程；预先用一次矩阵乘计算距离矩阵。未选 token 直接丢弃，不做合并或摘要（Equation 3–4、Algorithm 1，pp. 9394–9395）。

## 任务与结果

- 模型：LLaVA-1.5/1.6、LLaVA-NeXT-Video；覆盖开放/封闭 QA、推理、captioning 与视频 QA，共 16 个 image/video-language 数据集。
- 极端约 15% TFLOPs 配置下，DivPrune 在多个 captioning/QA 指标上显著优于 FastV/VTW；Table 1 还显示不同基础模型的高压缩敏感性很不一致。
- 视频设置从 6.539T 降到 0.937T（14.1%）；prefill 0.330→0.161s，端到端 4.37→3.39s（Table 2）。这表明 prefill 大降不会等比例转化为总生成时延。
- Table 4：random 平均分比 DivPrune 低 5.6%，Min-Max 冗余选择低约 15.8%，支持“多样性”比单纯高分更重要。
- 图像侧使用 LLaVA-1.5-7B/13B 与 LLaVA-1.6-7B，覆盖 COCO、Flickr30K、GQA、MMBench、MME、MMMU、NoCaps、OKVQA、POPE、ScienceQA、SEEDBench。LLaVA-1.5-7B 在约 15.6% TFLOPs 下，DivPrune 的 COCO CIDEr 0.96、GQA 56.85、MMBench 59.19、POPE 86.02；FastV 分别为 0.06、38.73、20.62、32.84（Table 1，p. 9397）。
- LLaVA-1.6-7B 在 10.79% TFLOPs 下，DivPrune 对 MMB/OKVQA/POPE/SQA 仅较原模型下降 3.5/2.3/3.4/1.6 点，并使 MMMU 36.44→37.11；这提示冗余 token 有时也可能是噪声，但属于作者设置内观察（Table 1，p. 9397）。
- Layer 0 的四项平均 62.34，延迟到 layer 1/2/3 分别为 60.44/56.99/38.60；这与 FastV“浅层先聚合再剪”的假设相反，说明 selector 的语义目标与最佳剪枝位置是耦合的（Table 3，p. 9399）。

## 局限

两两距离计算增加 prefill 开销；论文报告其 prefill 比部分简单基线慢 6%–7%，但由于只计算一次，端到端生成反而快 1%–7%（§4.5）。该结论与输出长度、解码实现和 batch 强相关。多样性是 task-agnostic 覆盖信号，不保证保留与具体问题最相关的细节。

未选 token 被彻底丢弃，因此 max-min 只能保证 embedding 空间覆盖，不能保证安全风险语义、空间邻域或短暂时序事件覆盖。对安全 Guard 应至少加入风险条件相关性或把多样性作为约束，而不是唯一目标。

## 关联

- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/multimodal-token-pruning.md|多模态调研]]
