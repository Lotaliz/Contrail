---
id: note-2026-foundation-me-vlm
type: paper-note
title: "ME-VLM: A Unified VLM for Embodied Cognition and Agent Coordination"
authors: [Foundation Model, Li Auto Inc]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-24526
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: medium
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
status: active
created: 2026-09-24
updated: 2026-09-24
---

# ME-VLM：具身 VLM 的端侧视觉 Token 压缩

## 书目信息与阅读边界

来源：[arXiv 2609.24526v2](https://arxiv.org/abs/2609.24526)，v1 首次提交于 2026-09-21，v2 更新于 2026-09-22；许可为 arXiv non-exclusive distribution license。精读 30 页 PDF，重点核对 §5 的压缩与 M100 部署，同时阅读统一训练、主表 1–4、案例与结论。本地原件：[[LLM-Wiki/raw/papers/2609.24526v2.pdf]]。未运行模型、代码或硬件测量；数字均为作者报告。

本文主体是具身/agent 基础模型，视觉 token 压缩是端侧部署子模块，故与项目关系为 adjacent。用户从近期索引选中后，复用 `paper-arxiv-2609-24526` 完成精读。

## 整体模型与训练

ME-VLM 有 4B 与 35B-A3B 两个版本，基于 Qwen3.5 系列原生多模态 agent。训练先以 embodied foundation SFT 建立物理状态、空间关系、affordance 与动作约束，再以 embodied reasoning SFT 学习观察—决策—结果验证。随后从不同初始化训练 multimodal-agent expert 与 embodied expert，最后用 multi-teacher on-policy distillation 在学生访问到的状态上合并两类能力。

评测横跨 26 个具身 benchmark、agent benchmark、自动驾驶和导航。35B-A3B 在具身主表平均 70.9，4B 为 63.4；agent 主表平均 72.5/63.1。对比模型的工具、提示和评测来源并不完全一致，部分星号结果由作者重评，适合说明覆盖广度，不宜当成视觉压缩机制的独立证据。

## 训练免费视觉 Token 压缩

压缩位于 visual projector 之后、LLM 之前；视觉塔、projector 与 LLM 参数保持不变。给定 $N$ 个 projector token 与外部预算 $K$，算法只选择原 token，不合并或修改特征，最后恢复原序列顺序。多视图/多视频流分别按相同比例选择，以避免一个 stream 占满预算。

选择目标是最大化保留集合的最小两两余弦距离：

$$
S^*=\arg\max_{S\subset X,\ |S|=K}\min_{x_i,x_j\in S,i\ne j}d(x_i,x_j).
$$

精确求解昂贵，实际采用 greedy Max–Min：以 $\ell_2$ 范数最大的 token 为种子，每次加入与当前集合“最大相似度最小”的候选，直到选满 $K$。这是纯视觉多样性覆盖，不使用用户问题、政策或动作目标，因此只能期望减少冗余，不能保证保留当前任务的因果证据。

## M100 部署证据

4B 模型部署在 Li Auto M100 SoC，结合视觉 token 压缩、W4A8 量化、编译器图优化和运行时调度。实际 operating point 把 token 从 4,096 减到 3,328，即保留约 81.25%；选择该点既考虑任务精度，也考虑 NPU 并行利用率。作者报告 prefill 从 400 ms 降到 188 ms，约 53% 降低/2.13× speedup；4B 和 35B 模型在所评任务上分别保留未压缩分数的 96.7% 和 98.2%。

这个 53% 是联合优化路径结果，论文没有把 token 压缩、W4A8 与硬件—软件调度的独立时延贡献逐项拆开。图 5 的“75% token retained”是示意/案例，与正文 3,328/4,096 的部署预算不同；不能把两者混成同一实验。量化消融只概述“低于 1%”退化，压缩后的具体任务、逐项分数和不同保留率曲线也未完整给出。

## 局限与项目关系

- 压缩目标不含文本条件，难以响应当前项目的 policy-conditioned 视觉证据选择。
- 完整视觉塔和 projector 已执行，收益主要在 LLM prefill 及其后续计算；它不是 pre-ViT/early-ViT 剪枝。
- 联合部署结果无法独立归因给压缩器，且 M100 是专用平台，不能直接外推 GPU/通用 NPU。
- 只报告一个实际 token budget 和聚合 retention，没有细粒度文字、小目标、安全漏报或极端预算分析。
- 论文没有单独 limitations 小节，也没有给出 Max–Min 选择复杂度和 selector-inclusive 分项计时。

对项目可用作纯视觉 diversity baseline 与“硬件利用率决定最佳 token 点”的系统反例：token 越少不一定越快，过度压缩可能降低 NPU 并行度。若用于政策 Guard，应至少增加 query/policy 条件、危险证据尾部召回和全链路组件消融。

## 证据定位与待验证项

- 能力框架与训练：§1、§3–4，图 2–4。
- Max–Min 压缩、stream 处理与执行位置：§5.1，图 5，式 (5)。
- M100、W4A8、token budget 与时延：§5.2–5.2.2，图 6。
- benchmark 与任务迁移：§6，表 1–4；应用案例：§7。
- TODO：代码版本与选择器复杂度；压缩/量化/编译独立消融；不同预算的 task-wise 结果；通用 GPU 和安全 Guard 复现。本轮均未执行。
