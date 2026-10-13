---
id: note-2026-zhang-stepprune
type: paper-note
title: "StepPrune: Adaptive Sequential Visual Token Selection across Multimodal Large Language Models"
authors: [Hansen Zhang, Landi He, Mingde Yao, Lijian Xu]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-13804
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, adaptive-budget, sequential-selection, efficient-inference]
status: active
created: 2026-09-20
updated: 2026-10-13
---

# StepPrune：顺序视觉 Token 选择与自适应 STOP

## 书目信息与阅读边界

来源：[arXiv 2609.13804v1](https://arxiv.org/abs/2609.13804)，首次提交于 2026-09-12，许可为 CC BY-NC-ND 4.0。精读 17 页 PDF 的方法、算法 1、四个 backbone 主表、效率/消融/敏感性与限制。阅读原件：[PDF 原文](https://arxiv.org/pdf/2609.13804v1)。未运行代码或模型；结果均为作者报告。

## 问题与方法定位

固定 top-$K$ 方法独立打分每个 token，既不会在选中一个 token 后重新估计其余 token 的边际价值，也把同一预算用于所有样本。StepPrune 把保留集构造为顺序决策：每一步在剩余视觉 token 与一个 STOP 动作之间选择，并以已选历史和文本为条件重新计算分布。

它运行在完整视觉编码器之后、multimodal projector 和 LLM prefill 之前；因此缩短 LLM 视觉前缀，但不节省视觉塔计算。这一点与当前项目希望在视觉塔浅层减少计算的位置不同。

## 模型与训练

### 条件指针策略

两个 ViT block 组成 cross-modal input encoder：文本 embedding 投影到视觉维度，与视觉 token 联合 self-attention；随后只保留视觉位置作为候选表示。pointer decoder 对已选历史做 causal self-attention，并对候选 memory 做 cross-attention；STOP embedding 与视觉 token 处于同一动作空间。已选 token 被 mask，首个 STOP 决定样本级保留数 $K$（§3.2，PDF 第 4 页）。

### 可微代理与推理路径

硬选择不可直接以 LM loss 训练。作者按存活概率 $A_t$、pointer 概率与几何衰减 $\beta^t$ 聚合每个 token 的轨迹分数，再用可微 top-$k$ 极化成 $\alpha_i$。训练时采用方差保持噪声门：

$$
\widetilde{x}_i=\sqrt{\alpha_i}x_i+\sqrt{1-\alpha_i}\epsilon_i,
$$

并用一个仅允许对角 self-attention 的 denoiser，避免强噪声 token 从邻居恢复信息。训练把全长噪声门序列送入冻结 MLLM；推理移除噪声门与 denoiser，物理 gather 原视觉 token 并恢复原空间顺序。只有 selector encoder、pointer decoder、denoiser、文本投影与 START/STOP embedding 更新；视觉塔、projector 和 LLM 冻结。

目标为冻结模型的 LM loss 加保留长度正则 $\lambda K/N$。不同总体压缩档位通过不同长度压力分别训练 selector；一个 checkpoint 并不能覆盖全部 operating points。

### 高分辨率分组

逐 token pointer 的轮数随 $K$ 增长。对 Qwen2.5-VL、LLaVA-NeXT 和 InternVL3 的长前缀，作者每轮选择 5 个 token；STOP 若得分最高则结束，否则取前 5 个未选 token。轮数约从 $K+1$ 降为 $\lceil K/5\rceil+1$，但历史只在组之间更新，牺牲组内细粒度条件化（§3.5、算法 1，PDF 第 5–6 页）。

## 实验设置与主要结果

模型覆盖 LLaVA-1.5-7B（576 token）、Qwen2.5-VL-7B（动态分辨率）、LLaVA-NeXT-7B（评测设置 2880 token）和 InternVL3-8B（multi-tile）。八个基准含 GQA、VQAv2、ScienceQA-IMG、MMBench/MMBench-CN、MME、TextVQA、POPE。Avg 是各任务相对 full-prefix 得分的平均百分比，不是平均准确率。selector 在单张 RTX PRO 6000 Blackwell 上训练。

### 质量

LLaVA-1.5 表 1（PDF 第 8 页）中，StepPrune 在平均 192/128/64 token 时保留 97.9%/96.7%/94.6% 的归一化性能。64-token 档优于 VisionZip 的 92.0%，但并非逐任务全面领先；例如 POPE 低于 ApET，而 MME 也低于 ApET。

Qwen2.5-VL 在 66.7%/77.8%/88.9% 剪枝率下为 97.8%/95.0%/90.9%，作者比较的 HoloV 为 94.3%/90.8%/87.0%。LLaVA-NeXT 在 77.8%/88.9%/94.4% 剪枝率下为 98.7%/95.8%/90.2%；极紧预算的 TextVQA 明显下降，论文正文将细粒度文字证据列为失败边界。InternVL3 在 80%/90% 剪枝率下为 95.4%/90.8%。

### 自适应预算证据

TextVQA 与 ScienceQA-IMG 的平均保留数为 109.6 与 100.9，MME/GQA/POPE 约 89–92。与相同平均预算的固定选择相比，自适应选择在 TextVQA/MME 上提高 0.90/0.81 个百分点，在 POPE/ScienceQA-IMG 上反而下降 0.13/0.57（图 3，PDF 第 9–10 页）。证据支持“预算随输入变化有用”，但收益不是跨任务一致。

### 延迟与开销

表 5（PDF 第 12 页）报告 LLaVA-1.5：full 576 token 的 prefill/E2E 为 59.95/138.37 ms；StepPrune 64 token 为 40.05/98.97 ms，即 prefill 1.50×、E2E 约 1.40×。LLaVA-NeXT 160 token 的 prefill 从 354.51 降到 98.17 ms，但绝对延迟仍慢于同预算 VisionZip 的 50.75 ms。

扩展实验把 selector 开销计入压缩 prefill 路径：LLaVA-1.5 输入仅 320 token 时 speed-up 为 0.98×，实际略慢；到 2240 token 时为 4.10×，但 selector 已占压缩 prefill 的 67.80%。长序列节省增长更快，短序列则可能无法摊销顺序 selector。

## 消融、失败条件与证据边界

双向 cross-modal encoder 比 causal encoder 高 2.2 个平均百分点。完整轨迹聚合为 94.7%，只用最后一步 pointer、均匀累计、仅存活权重分别为 90.3%、83.9%、89.5%，支持轨迹权重设计（表 7，PDF 第 13 页）。训练的噪声门代理与硬推理存在 0.3–1.2 点差距，预算越紧差距越大（表 8）。

论文明确的限制包括：过早 STOP 会永久丢失尚未选入的局部证据；文本丰富输入在激进压缩下尤其困难；视频、更大 LLM、跨 backbone selector transfer 与单 checkpoint 多预算仍未解决。另有两点实际边界：

- adaptive 是同一总体长度压力内的样本差异，不是一个模型任意接受外部预算；各 operating point 分别训练。
- selector 需要完整视觉塔输出和额外 cross-modal/顺序计算，不能视为视觉 encoder 加速。

## 对当前项目的影响

StepPrune 是“动态保留数量 + STOP”的强近邻，可作为完整视觉塔后自适应选择基线，并直接反驳固定预算足以覆盖所有输入的假设。它也提供了安全迁移的关键负面模式：STOP 一旦过早触发，局部证据无法恢复；安全评测必须单列漏报、小字/OCR、有害小区域和跨预算一致性。

当前项目若借鉴顺序决策，部署位置需前移到视觉塔浅层，并将普通 LM loss/精确答案奖励替换为政策条件的安全判别与漏报代价。是否能在浅层表示上稳定训练 STOP、是否值得支付多轮 selector 成本，均为研究假设。该笔记不把 StepPrune 的任务保持率外推为安全召回率，也不改变正式 motivation。

关联：[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|StackTok]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]；[[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|自回归 VLM 时延基线]]。

## 证据定位与待验证项

- 条件指针、轨迹聚合、噪声门、目标与 grouped execution：§3、图 2、算法 1，PDF 第 3–6 页。
- 四个 backbone 的主结果与自适应分布：表 1–4、图 3–4，PDF 第 7–11 页。
- FLOPs/延迟、扩展开销、组件与训练—推理差距：表 5–8、图 5，PDF 第 12–13 页。
- 局部证据、单 checkpoint 多预算与视频边界：§5.2–5.4，PDF 第 13–14 页。
- TODO：代码与计时实现核查；selector latency 分解；安全数据上校准 STOP；与一次性 scorer 在相同训练成本下比较。均未执行。
