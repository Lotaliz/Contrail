---
id: deepstack-visual-token-injection
type: concept
category: method
title: DeepStack 视觉 Token 深度注入
aliases: [DeepStack, 深层视觉 Token 堆叠, Depth-wise Visual Token Injection, Layer-wise Visual Token Stacking, Multi-level Visual Feature Injection]
tags: [method, technology]
status: active
related: [multimodal-token-pruning, vision-transformer-token-pruning-basics]
sources: [paper-meng-2024-deepstack, paper-bai-2025-qwen3-vl]
created: 2026-08-31
updated: 2026-08-31
---

# DeepStack 视觉 Token 深度注入

## 一句话定义

DeepStack 是一类面向 Transformer 多模态模型的 **序列长度保持型、跨层视觉信息注入方法**：保留固定数量的视觉 token 槽位，把不同尺度或不同视觉编码深度的补充特征，在多个早期 Transformer 层中通过残差加法写入，而不是把全部信息横向拼成长序列。原始 DeepStack 使用多尺度/高分辨率 token；Qwen3-VL 将其扩展为多深度 ViT 中间特征注入。

## 它解决什么问题

传统 LMM 把 $M$ 个视觉 token 作为前缀一次性送入 LLM。提高图像分辨率、多裁剪或加入视频帧时，$M$ 急剧增长，引起：

- attention 与 MLP 计算增加；
- prefill、KV cache 和训练激活显存上升；
- 为压缩序列而做 pooling/resampling 时又可能丢失 OCR、小目标和文档布局细节。

DeepStack 的核心问题是：**能否让模型接触更多细粒度视觉证据，但不增加同时存在于 LLM 序列轴上的视觉位置数？**

## 核心机制

设低分辨率全局图像产生：

$$
X\in\mathbb{R}^{m\times d}.
$$

高分辨率视觉特征经 2D 空间采样后被拆为 $s$ 组：

$$
X_{stack}=\{X_{stack}^{1},\ldots,X_{stack}^{s}\},
\qquad X_{stack}^{i}\in\mathbb{R}^{m\times d}.
$$

每组与 $X$ 具有相同 token 数，并尽量让相同索引对应邻近图像区域。全局 $X$ 从输入层进入，在选定早期层 $\ell_i$ 的视觉位置执行：

$$
\widetilde H_V^{(\ell_i)}
=H_V^{(\ell_i)}+X_{stack}^{i}.
$$

Transformer 随后继续处理 $\widetilde H^{(\ell_i)}$。因此序列始终只有 $m$ 个视觉位置，但这些位置沿深度累计接收了约 $(s+1)m$ 个视觉 token 的信息。

## “堆叠”到底是什么意思

这里的 stack 不是：

- 把 token 在序列维拼成 $[(s+1)m]\times d$；
- 把 token 在 channel 维拼成 $m\times[(s+1)d]$；
- 在推理时删除低重要性 token；
- 把所有高分辨率 token 同时保存为独立 KV 位置。

它更接近 **深度复用或 layer-wise multiplexing**：同一组视觉槽位在不同网络深度接收不同但空间相关的高分辨率证据。

## 原始方法的两种落点

| 变体 | 注入位置 | 主要收益 | 额外要求 |
|---|---|---|---|
| DeepStack-L | LLM 早期 decoder layers | 固定 LLM context/KV 长度，引入更多细节 | 需要多模态训练；层位置需配置 |
| DeepStack-V | ViT encoder layers | 在视觉塔内逐层增强高分辨率表征 | 通常需要解冻视觉 encoder |

## Qwen3-VL：从多尺度 Token 改为多深度特征

Qwen3-VL 不是通过额外分辨率组构造 DeepStack。它先把最终 ViT 输出经主 merger 作为常规视觉 embedding 放入 LLM 输入，然后从三个中间 ViT 层抽取同空间网格的特征，经三个独立 merger 投影，并分别加到前三个 LLM block 输出处：

$$
H_V^{(j+1)} \leftarrow H_V^{(j+1)}+P_j\!\left(Z^{(d_j)}\right),
\qquad j=0,1,2.
$$

因此更准确的结构不是“浅层逐步替换成深层”，而是：

- **语义主路：** ViT 最终层特征从 LLM 输入处进入；
- **多层侧路：** 浅、中、较深的 ViT 中间特征在 LLM 早期逐层补写；
- **共同空间槽位：** 各路 merger 后 token 数与视觉位置相同，不增加 context length。

公开配置中，Qwen3-VL-2B 从 24 层 ViT 的 `[5,11,17]` 抽取，8B 从 27 层 ViT 的 `[8,16,24]` 抽取。这里的“浅、中、深”是相对分段，不是跨模型固定层号。

这种设计的内涵是把单一的视觉—语言接口改造成 **分阶段的跨模态特征金字塔**：最终层提供强语义对齐，中间层侧路绕过 ViT 最终层这一信息瓶颈，把可能在深层抽象中被削弱的纹理、文字笔画、局部结构和布局线索直接送到 LLM。Qwen3-VL 报告只证明多层组合有效，并未用逐层探针证明每个深度具有固定功能分工。

## 与其他视觉 Token 方法的区别

| 方法 | 对额外视觉信息的处理 | LLM context length | 信息损失与成本特点 |
|---|---|---|---|
| Sequence concatenation | 全部横向拼接 | 随 token 数增长 | 信息最直接，LLM/KV 成本最高 |
| Pooling/resampler | 压成固定少量 token | 固定 | 成本低，但可能丢细节 |
| Token pruning | 按重要性删 token | 减少 | 目标是加速，存在漏证据风险 |
| Token merging | 相似 token 聚合 | 减少 | 比纯删除保真，但有合并开销 |
| Dimension concatenation | 沿 channel 拼接后投影 | 固定 | 同层融合，可能造成特征拥挤 |
| DeepStack | 按层注入不同尺度或不同编码深度的特征 | 固定 | 保留更多跨层有效信息，但需要额外分支投影或视觉编码成本 |

因此，DeepStack 不是剪枝算法；它是 **高分辨率视觉信息与固定 LLM 序列预算之间的连接策略**。

## 为什么空间一致性重要

如果某个 visual slot 在第 0 层表示左上区域，后续层又向该 slot 加入右下角的无关 patch，隐藏状态会混合不对应的局部语义。DeepStack 使用 2D dilation/spatial sampling，使同一槽位沿层深接收相邻区域的细节。原论文中 2D spatial 优于 2D grid 和 1D sequential，说明“按层注入”必须与空间对应共同设计。

## 效率应该怎样理解

必须区分三种数量：

- **输入视觉上下文长度：** 同时占据 LLM 序列位置的 token 数，如 576；
- **跨层有效视觉 token 数：** 各层累计注入量，如 2880；
- **视觉塔实际处理量：** 低分辨率与高分辨率/多裁剪编码的总成本。

DeepStack 主要控制第一项。它会显著避免把 2880 个 token 全部写入每层 LLM 与 KV cache，但不消除高分辨率视觉编码和 projector 开销。没有真实 latency/FLOPs 分解时，不能把“context length 不增加”直接表述为“端到端推理加速已被证明”。

## 适用场景

- 高分辨率 OCR、文档、图表和信息图理解；
- 小目标、密集对象和细粒度属性；
- 希望限制 LLM/KV 长度、但不愿过早压缩视觉证据的系统；
- 将视觉候选按尺度、空间、时间或政策拆组后逐层注入的研究设计。

## 不适用或高风险场景

- 完全不能增加视觉塔计算的极端低功耗设备；
- 要求 training-free 接入现有模型；
- 依赖所有局部 token 在同一层显式两两交互的任务；
- 原生长视频时序、音频视频融合或需要精确帧级定位但没有相应分组机制的任务；
- 仅凭论文现有证据就声称改善安全召回、P95 latency 或多轮 cache。

## 与视觉 Token 剪枝的组合

DeepStack 可把剪枝问题从“为整幅图选一次 Top-k”改成“在空间位置与表征深度两个维度选择互补子集”：

$$
S_i=\operatorname{Select}(X_{candidate},q,\ell_i),
$$

其中 $S_i$ 可分别强调全局语义、OCR、小目标、跨帧事件或不同安全政策。潜在优势是多个层的选择集合可以互补；潜在风险是预算、层位置和选择器形成更大的联合搜索空间，而且后注入 token 并非普通输入前缀，不能直接套用只针对 layer-0 token 的剪枝实现。

Qwen3-VL 变体进一步带来五点直接启发：

1. **重要性是深度条件化的。** 同一空间位置在最终 ViT 层不重要，不代表其中间层特征不含 OCR、边缘或小目标证据；单层分数不再足够。
2. **跨分支 mask 要保持空间一致。** 若删除 LLM 中的视觉位置，主路、三个侧路与 `visual_pos_masks` 必须同步；否则残差注入失去位置和形状对应。
3. **剪枝越早，收益越大、不可逆性越强。** ViT 浅层删除一个位置会同时消除其所有后续深度表征；在某个抽取点之后再剪，则已保存的侧路可作为 evidence rescue，但节省的视觉塔计算较少。
4. **可以剪“深度分支”而不只剪空间 token。** 对简单样本关闭部分 merger/注入支路是一种结构化门控；但若 ViT 仍完整前向，它主要减少侧路开销，不能等同于显著的 ViT 加速。
5. **评分应聚合所有注入路径。** 可对各深度的任务损失增量、activation-gradient product 或校准集风险取 max/风险加权 union；安全场景中保守聚合有望保护只在单一深度显著的稀有证据，但尚需实验验证。

## 多模态安全判别中的启示

对于安全 Guard，DeepStack 提供了一个与 aggressive pruning 不同的思路：固定 LLM context/KV 长度，同时把高分辨率文字、小型危险物体、局部符号和不同视频事件按层注入。可考虑：

1. layer 0 注入全局场景；
2. 后续早期层分别注入 OCR、小目标、政策相关区域和跨帧事件；
3. 以风险召回或证据覆盖约束决定每层子集；
4. 在低风险样本减少注入组，高风险或不确定样本恢复全部组。

这些属于研究假设，不是 DeepStack 原论文已经验证的安全结论。

## 证据边界

- 原论文在 LLaVA/Phi-3 系列上验证，主要收益来自 VQA、OCR、文档和图表；
- Qwen3-VL 的多深度变体在内部 15B-A2B、200B 预训练 token 的消融中将 11 项平均分从 74.7 提高到 76.0，OCRBench、InfoVQA、ChartQA、DocVQA 分别提高 2.6、2.3、1.8、1.6，但 TextVQA 下降 0.1；
- Qwen3-VL 没有公开三个视觉抽取层、注入顺序或各分支的独立消融，也没有 DeepStack latency/FLOPs 分解；
- 需要训练或微调，不是 plug-and-play inference method；
- 层起点、间隔和组数仍是启发式配置；
- 没有充分的真实 latency、吞吐、显存与跨硬件数据；
- 没有多模态安全、长政策、多轮对话或原生长视频实验。

## 来源与继续阅读

- [[LLM-Wiki/research/visual-token-pruning/papers/2024-meng-deepstack.md|DeepStack 论文精读]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-bai-qwen3-vl.md|Qwen3-VL DeepStack 聚焦笔记]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md|视觉 Transformer 与 Token 剪枝基础]]
