---
id: paper-note-meng-2024-deepstack
type: paper-note
title: "DeepStack: Deeply Stacking Visual Tokens is Surprisingly Simple and Effective for LMMs"
authors: ["Lingchen Meng", "Jianwei Yang", "Rui Tian", "Xiyang Dai", "Zuxuan Wu", "Jianfeng Gao", "Yu-Gang Jiang"]
year: 2024
venue: "NeurIPS 2024"
source_id: paper-meng-2024-deepstack
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: medium
tags: [paper-note, research, method, vision-language-model, visual-token-pruning, efficient-inference]
status: active
related: [deepstack-visual-token-injection, multimodal-token-pruning]
created: 2026-08-31
updated: 2026-08-31
---

# DeepStack: Deeply Stacking Visual Tokens is Surprisingly Simple and Effective for LMMs

## 论文角色与研究问题

传统 projector-based LMM 把所有视觉 token 横向拼成前缀并从 LLM 第 0 层输入。高分辨率、多裁剪和视频会线性拉长视觉上下文，并放大 LLM attention、MLP、KV cache 与训练显存；压缩/重采样虽保持短序列，却可能丢失 OCR、文档和小目标所需的细粒度视觉信息。DeepStack 提出另一维度：不把更多视觉 token 同时放在序列轴上，而是将它们分组后沿 Transformer 深度分批注入（Abstract、§1，pp. 1–3）。

DeepStack 的目标不是在相同视觉信息下进一步删 token，而是在固定 LLM visual context length 下承载更多高分辨率视觉信息。因此它与 token pruning 相邻，但不属于 importance-based pruning。

## 输入、任务与系统场景

- **用户输入：** 单幅普通或高分辨率图像加问题/指令；视频实验将 6 帧均匀采样后拼成 $2\times3$ 网格图，再作为单图输入。
- **任务特点：** 通用 VQA、OCR、图表、文档、信息图、幻觉评测和开放式/多选视频 QA。高分辨率任务要求读取小文字、局部数字和密集布局，是主要收益场景（§4.2，pp. 7–8）。
- **系统主干：** LLaVA-1.5/LLaVA-NeXT 式 CLIP ViT + MLP projector + Vicuna/Phi-3 decoder-only LLM。
- **训练条件：** 遵循 LLaVA 两阶段训练；LCS-558K 做预训练，LLaVA-mixed-665K 或作者组合的 748K 数据做 SFT。PT 只训练 projector，SFT 解冻 LLM；DeepStack-V 与 HD 设置还以 $10^{-6}$ 学习率微调视觉编码器（§4.1，pp. 6–7）。它不是无需训练的推理期插件。

## 方法

### 两条视觉流

1. global-view stream 将低分辨率图像编码为 $m$ 个全局视觉 token $X$，照常占据 LLM 的 $m$ 个视觉位置；
2. high-resolution stream 对高分辨率图像或多裁剪特征进行编码，再通过保持空间对应关系的 2D dilation sampling，拆成 $s$ 组 $X_{stack}^{1:s}$。每组仍为 $m$ 个 token，且每个 token 对应全局网格位置附近的高分辨率邻居（§3.2、Equation 4，p. 5）。

### 沿深度注入

全局 token 从输入层进入。到指定早期层 $\ell_i$ 时，不扩展序列，而在原视觉位置做残差加法：

$$
\widetilde H_V^{(\ell_i)}=H_V^{(\ell_i)}+X_{stack}^{i},
$$

然后让该层继续处理更新后的隐藏状态。默认连续四个早期层各注入一组，后续层恢复普通序列建模（Algorithm 1、Equation 5，pp. 5–6）。

因而，论文中的 `Vis. Tok.=2880, Cxt. Len.=576` 表示模型总共接触了 576 个全局 token 加四组各 576 个高分辨率 token，但任何一层的视觉序列位置数仍是 576。这里的 2880 是跨深度累计的“有效视觉 token”，不是 2880 个同时共存的上下文位置。

### 两个变体

- **DeepStack-L：** 把额外高分辨率 token 注入 LLM 的早期 decoder layers；视觉 encoder 在基础公平对比中可冻结。
- **DeepStack-V：** 在 ViT 内部做类似注入：patch embedding 和前若干 encoder layers 先编码高分辨率组，再将其注入后续 ViT layers；需要解冻视觉编码器适应新数据流（Figure 2、§3.2、§4.3）。

## 为什么可能有效

- 序列拼接让所有高分辨率 token 同时进入所有 LLM 层；DeepStack 复用固定的视觉位置，把额外证据沿深度逐步写入同一组 hidden slots。
- 早期 decoder layers 兼具视觉特征融合作用，后期 layers 再进行语言条件的序列建模。论文将其解释为“early-layer visual encoding + later-layer sequence modeling”两阶段（Equation 8，p. 6）。
- 空间对应至关重要：同一 hidden slot 在不同注入层接收邻近高分辨率 patch，便于逐层累积局部细节；随机或一维重排会破坏这种对应。

这是由方法结构与消融共同支持的解释，不是经过严格理论证明的因果机制。

## 主要实验

### 同视觉上下文长度

官方摘要报告，在相同 context length 下，DeepStack 7B/13B 相对对应 LLaVA-1.5 基线在 9 项 benchmark 上平均提高 2.7/2.9 点；TextVQA、DocVQA、InfoVQA 的 7B 增益分别为 4.2、11.0、4.0。DeepStack-V 相对 LLaVA-1.5-7B 平均提高 3.8 点（Abstract；Table 1，p. 7）。

DeepStack-L 用 2880 个跨层有效视觉 token、但 context length 仅 576；论文称它以完整 2880 序列约五分之一的视觉上下文长度接近长序列对照。DeepStack-HD 进一步使用 14400 个跨层有效 token、context length 2880，重点改善 1344 分辨率文档/OCR任务（Tables 1–2，pp. 7–8）。

### 高分辨率与视频

- 文本任务涵盖 ChartQA、DocVQA、InfoVQA、MultiDocVQA、TextVQA；DeepStack 相对 576-token LLaVA-1.5 的提升明显，但仍不在所有项目上等于完整 2880-token LLaVA-NeXT（Table 2）。
- 视频零样本实验将 6 帧拼成图像；DeepStack-L-7B 对 EgoSchema 为 38.4 对 35.4，Next-QA 总 accuracy 61.0 对 59.6，MSVD accuracy 76.0 对 75.5，ActivityNet accuracy 49.3 对 48.6，提升较温和（Table 3，p. 8）。

### 关键消融

- 视觉 token 在 Phi-3 32 层中的第 8 层以前开始注入仍可接受，越过中点后性能明显下降；连续使用四层最好（Figure 3，pp. 8–9）。
- 2D spatial sampling 平均 51.1，2D grid/1D sequential 为 49.0/49.3，支持空间一致性（Table 5，p. 9）。
- 重复原低分辨率 token 的 dummy stack 平均仍为 49.1；高分辨率 stack 为 51.1，说明增益来自新增细节而非单纯残差重复（Table 6，p. 10）。
- 相同实验中，baseline、dimension concat、high-resolution string、global+high-resolution string、DeepStack 的七任务均分分别为 49.1/49.4/50.7/51.0/51.1；DeepStack 达到最好均分且只占 576 个上下文位置，但 DocVQA 等单项仍可能弱于完整 string（Table 7，pp. 10–11）。
- 微调视觉 encoder 后 DeepStack 均分从 51.1 提升到 52.4；只微调视觉 encoder 而无 DeepStack 则从 49.1 降至 48.5（Table 8，p. 11）。

## 效率证据边界

论文充分证明了 **LLM visual context length 不随高分辨率 token 总量增长**，但没有主表报告端到端 latency、throughput、峰值显存、KV cache 或 vision-encoder FLOPs。额外高分辨率图像仍需视觉编码、projector 和层间残差注入，因此：

- 相对把 2880 token 全部拼进 LLM，DeepStack 很可能显著降低 LLM attention/KV 成本；
- 相对只处理 576-token 低分辨率图像的 LLaVA-1.5，LLM 序列成本接近，但视觉塔与 projector 成本更高；
- “minimal additional cost”不能被解释为“端到端零额外成本”或已经证明实际推理加速。

## 局限与失败条件

- 注入起始层、间隔和层数是启发式超参数；作者将门控注入、layer-wise position embedding 和系统化选择留作未来工作（§5，p. 11）。
- 需要重新训练或微调，不能像 FastV/VisionZip 那样直接用于任意现有模型。
- 各高分辨率组并不作为独立 token 位置同时存在，而是加到相同 hidden slots；跨远距离小区域的显式 token-token 交互可能弱于完整长序列。
- 视频仅以 6 帧 mosaic 做零样本验证，没有原生长视频、事件级时序、音频或跨帧目标跟踪证据。
- 没有长文本、多轮 cache、真实服务时延或多模态安全判别实验。

## 与 Token 剪枝及安全判别的关系

DeepStack 与 pruning 方向相反但目标互补：pruning 尝试从 $M$ 个视觉 token 中找少量重要 token；DeepStack 允许模型在固定 $m$ 个 LLM 槽位中跨层接触约 $s\times m$ 个视觉 token。可探索的组合是先对每层候选做政策相关选择，再把不同空间/时间/政策子集注入不同早期层。

对安全 Guard，它可能帮助保留 OCR、小目标、细粒度符号和高分辨率组合危害，同时限制 LLM context/KV 长度；但论文没有证明风险召回或短暂视频事件保持。若与剪枝组合，必须防止把后注入 token 当成可自由删除的普通 prefix token，并单独计算高分辨率视觉塔成本。

## 版本与证据说明

本地保存文件为 arXiv v1；题录、正式录用状态与官方摘要的 headline results 已在 NeurIPS 2024 proceedings 页面核对。本轮未复现实验。

## 关联

- [[LLM-Wiki/concepts/methods/deepstack-visual-token-injection.md|DeepStack 视觉 Token 深度注入]]
- [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|多模态 Token 剪枝]]
- [[LLM-Wiki/research/visual-token-pruning/overview.md|视觉模型 Token 剪枝总览]]
