---
id: paper-note-bai-2025-qwen3-vl
type: paper-note
title: "Qwen3-VL Technical Report"
authors: ["Qwen Team"]
year: 2025
venue: "arXiv"
source_id: paper-bai-2025-qwen3-vl
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, vision-language-model, visual-token-pruning, efficient-inference]
status: active
related: [deepstack-visual-token-injection, multimodal-token-pruning]
created: 2026-08-31
updated: 2026-08-31
---

# Qwen3-VL Technical Report

## 本次阅读范围

本笔记聚焦 Qwen3-VL 的 DeepStack 架构、公开实现与对应消融，不把对整份 42 页技术报告的阅读标为 deep-read。关键证据核对了技术报告 §2、§2.2、§5.12.2、Table 12，以及 Hugging Face 官方模型配置和 Transformers 实现。

## 它与原始 DeepStack 的关键差异

原始 DeepStack 将多尺度或高分辨率视觉 token 按空间对应关系分组，再沿 LLM 深度注入。Qwen3-VL 保留“固定序列长度、跨层残差注入”的核心，但把注入源改成 **同一次 ViT 前向传播的多深度中间特征**（§2.2，p. 4）。

因此，Qwen3-VL 的实现更准确地表示为：

1. 最终 ViT 输出经主 merger 后，照常替换输入序列中的视觉占位符，进入 LLM 第 0 层；
2. 从三个中间 ViT 层各取一组同空间网格特征；
3. 每组经过独立、可学习的 vision-language merger，完成 $2\times2$ 空间压缩和 LLM hidden-size 投影；
4. 三组特征依次在 LLM 前三个 block 的输出处，对视觉位置做残差加法。

它不是纯粹的“浅层特征替换为中层，再替换为深层”，而是 **最终层语义主路 + 多层视觉侧路的渐进补写**。

## 公开实现定位

Transformers 实现中，ViT 在 `deepstack_visual_indexes` 指定层收集中间 hidden states；每个层有独立 `deepstack_merger_list`，最终 ViT hidden states 则经过主 `merger`。LLM 每完成一个早期 decoder layer 后，只在 `visual_pos_masks` 指定的位置执行：

$$
H_{V}^{(j+1)} \leftarrow H_{V}^{(j+1)} + P_j\!\left(Z^{(d_j)}\right),
$$

其中 $Z^{(d_j)}$ 是 ViT 深度 $d_j$ 的特征，$P_j$ 是该深度专属 merger。视觉 token 的序列位置数不变。

公开配置显示模型规模间的抽取层会变化：

- Qwen3-VL-2B：24 层 ViT，`deepstack_visual_indexes=[5,11,17]`；
- Qwen3-VL-8B：27 层 ViT，`deepstack_visual_indexes=[8,16,24]`。

这说明“浅、中、深”是相对于视觉塔深度的分段取样，不是一个适用于所有规模的固定绝对层号。主路仍使用 ViT 最终输出。

## 方法内涵

### 绕过单一末层瓶颈

只把 ViT 最后一层送入 LLM，隐含假设是最终特征足以同时保存局部纹理、文字笔画、空间布局、对象部件和高层语义。Qwen3-VL 用多深度侧路放松这一假设，使被深层语义抽象弱化的信息仍可抵达语言模型。报告将其表述为保留从低层到高层的丰富视觉信息并加强视觉—语言对齐（§1、§2.2）。

### 把视觉—语言融合变成分阶段过程

传统 projector 接口只在 LLM 输入处完成一次模态转换。Qwen3-VL 让前三个 LLM block 在处理最终层视觉语义后，继续收到不同视觉深度的补充证据。它更接近跨模态 feature pyramid 或多出口侧连接，而不是增加新 token 位置。

### 空间槽位不变，表征深度改变

每个注入分支在 merger 后与同一批视觉位置对齐，因此系统保留固定的空间索引与上下文长度，但同一位置的 hidden state 沿 LLM 深度获得来自不同 ViT receptive field 和抽象层次的增量。这是一种 **空间位置共享、特征尺度分层** 的表示方式。

## 实验证据与边界

Table 12 在同一个内部 15B-A2B LLM、200B 预训练 token、无 post-training 的条件下比较：

| 设置 | 平均分 | OCRBench | InfoVQA | ChartQA | DocVQA | TextVQA |
|---|---:|---:|---:|---:|---:|---:|
| Baseline | 74.7 | 81.0 | 71.9 | 81.5 | 89.5 | 80.6 |
| Qwen3-VL DeepStack | 76.0 | 83.6 | 74.2 | 83.3 | 91.1 | 80.5 |
| 差值 | +1.3 | +2.6 | +2.3 | +1.8 | +1.6 | -0.1 |

收益集中于细粒度、OCR、文档与图表任务，但并非每项都提高。报告没有给出：

- 三个抽取深度各自的独立消融；
- 注入顺序、注入到哪几个 LLM 层的搜索；
- DeepStack 分支带来的真实 latency、显存和 FLOPs 增量；
- 多模态安全判别或 token 剪枝联合实验。

因此，“不同深度分别承担纹理、布局和语义”的解释符合层级视觉表征的一般理解，但 Qwen3-VL 报告没有逐层探针证明明确的一一功能分工。

## 对 Token 剪枝的直接影响

### 重要性从一维变为二维

Qwen3-VL 中，一个空间 token $i$ 不再只有最终层表示，而对应一组深度特征：

$$
\mathcal{Z}_i=\left\{Z_i^{(d_1)},Z_i^{(d_2)},Z_i^{(d_3)},Z_i^{(D)}\right\}.
$$

剪枝单元应至少考虑“空间位置 $i$ × 视觉深度 $d$”。只用最终 ViT 层、单个 LLM 层 attention 或单一 activation norm 评分，可能删除在深层看似冗余、但在浅层仍携带 OCR、边缘或小目标证据的位置。

### 剪枝时机决定可获得的收益与风险

- **ViT 输入前/很浅层剪枝：** 同时消除该位置的所有后续层级特征，算力收益最大，漏掉细粒度安全证据的风险也最大；
- **某个 DeepStack 抽取点之后剪枝：** 已缓存的浅层侧路仍可保留该位置证据，形成“可恢复剪枝”，但省下的 ViT 计算较少；
- **进入 LLM 前剪视觉位置：** 必须同步修改主 merger 输出、各 DeepStack 分支及 `visual_pos_masks`，否则残差注入失去位置和形状对应；
- **只关闭某个 DeepStack 分支：** 是深度维的结构化门控，容易实现，但若 ViT 已完整运行，主要只省 merger/传输/残差成本，不能自动获得显著 ViT 加速。

### 评分应覆盖各注入路径

可将任务对齐的重要性写成：

$$
I_i=\operatorname{Agg}_{d\in\mathcal D}
\left[\Delta\mathcal L_{task}(i,d),
\left|Z_i^{(d)}\odot\nabla_{Z_i^{(d)}}\mathcal L_{task}\right|\right],
$$

其中 `Agg` 可用最大值、风险加权和或保守 union。对于安全判别，最大值/union 比简单平均更能保护“只在一个深度显著”的稀有危险证据；这是研究假设，需要本地校准集验证。

## 建议的联合剪枝实验

1. **Final-only baseline：** 只用最终 ViT 特征评分，并对所有 DeepStack 分支施加同一 mask；
2. **Multi-depth shared mask：** 对三个中间层和最终层的重要性取 mean、max、learned weighted sum，仍保持跨分支同一空间 mask；
3. **Per-depth mask：** 每个注入分支独立选择 token，再用空间覆盖约束限制某位置被所有深度同时删除；
4. **Rescue mask：** 主路采用激进剪枝，浅层/OCR/高风险分支保留少量可恢复 token；
5. **Branch gating：** 按样本不确定性决定是否启用三个侧路，单独衡量精度收益与实际系统开销。

多模态安全评测除平均准确率外，应重点报告 unsafe recall/FNR，并按 OCR 隐写、小目标危险物、符号/手势、复杂场景语义和长视频稀有事件分桶；效率要分别报告 ViT、merger、LLM prefill 与端到端 latency。

## 来源与继续阅读

- [[LLM-Wiki/concepts/methods/deepstack-visual-token-injection.md|DeepStack 视觉 Token 深度注入]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-meng-deepstack.md|原始 DeepStack 论文精读]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
