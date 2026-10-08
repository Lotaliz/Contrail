---
id: note-2026-zhang-std
type: paper-note
title: "Shallow to Deep: Aligning Token Pruning with Stage-wise Roles in LVLMs"
authors: ["Shuo Zhang", "Jintao Tong", "Yixiong Zou", "Yuhua Li", "Ruixuan Li"]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-25635
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

# STD：按视觉编码器阶段角色调整 token 剪枝

## 来源与阅读边界

来源：[arXiv 2609.25635v1](https://arxiv.org/abs/2609.25635)，2026-09-22 首次提交；arXiv 页面作者备注为“Accepted to EMNLP 2026”，尚以本版预印本为阅读原件：[[LLM-Wiki/raw/papers/2609.25635v1.pdf]]，17 页。已核对正文 §1–6、表 1–10、图 2–7 及附录 A–C/Limitations；未运行代码、模型或 4090D 测试。数值均为作者报告。

## 问题、阶段假设与机制

作者研究的是：视觉塔内跨多层用同一套 CLS-attention 打分提前删 token，为何浅层精度会受损？表 1 的匹配最终 token 数对照显示，禁用浅层注意力剪枝后，LLaVA-1.5 在保留 192/128/64 token 时，四任务归一化平均由 95.4/93.3/90.5 升到 96.1/94.1/91.0。作者通过注意力热图、平均注意距离、Canny 边缘参考和物体区域参考，提出浅层偏高频轮廓、中层逐步定位主体、深层形成注意力 hub 且相邻层变化不稳定的经验分期。这些图和相似度支持一种设计启发，但不能单独证明每一层具有唯一因果功能。证据：§2、表 1、图 2–4、附录图 8–9。

STD 在**视觉编码器内部**分三阶段，始终实际缩短后续层处理的序列：

1. 浅层 $\ell\le L_1$：对当前一维 patch-token 序列做 RFFT，去掉低频段后逆变换，取每个 token 的高频能量；将其与 CLS attention 的归一化分数以 $\alpha$ 加权，避免单纯依赖浅层混乱注意力。原文保留频谱索引的上三分之二。此处频谱定义依赖 token 的序列排列；将其解释为真实二维图像边缘需 Canny 对照，不能把高频分数当作天然语义证据。
2. 中层 $L_1<\ell\le L_2$：沿 token 序列用一维 Gaussian kernel 平滑 CLS attention 分数，再选保留项；目的是减少物体局部区域被离散硬阈值拆散。浅层和中层每两层剪枝一次。
3. 深层 $\ell>L_2$：用相邻层 CLS-attention 向量的 $L_2$ 距离 $\Delta^{(\ell)}$ 表示变化；当 $\Delta^{(\ell)}<\Delta^{(\ell-1)}$ 时触发该层 attention 剪枝。这个条件只是“比前一层下降”，不保证扰动绝对值很小；作者还规定最后一次剪枝强制达到目标 token 数，所以触发器也不是绝对的质量保护。

默认边界 $L_1=6,L_2=12$；浅层混合权重 $\alpha$ 对 LLaVA-1.5 设 0.8，对 LLaVA-NeXT/Qwen2-VL 设 0.5。算法 training-free，但阶段边界、频带比例、Gaussian 参数和预算是手工设定。证据：§3、图 5、式 (1)–(7)、§4 实现细节、附录 C。

## 结果、比较与消融

- LLaVA-1.5-7B 初始 576 token，表 2 在保留 64 个（删除 88.9%）时，STD 的八任务归一化平均为 94.3%，同期 FlowCut 93.2%；保留 128/192 时 STD 为 97.0/98.5%。这不是原始平均准确率；POPE、MME、TextVQA 等有不同计量口径。附录表 11 在 32 token 时 STD 为 89.8%，高于 FlowCut 87.6%，但 POPE 原始值相对 dense 85.9 已降至 74.8，不能用平均保持率掩盖单项风险。证据：§4.1、表 2、附录表 11。
- LLaVA-NeXT-7B 初始 2,880 token，在保留 160 个（删除 94.4%）时 STD 为 89.6%，比表 3 最强比较项 FiCoCo-V 87.5% 高 2.1 个百分点。Qwen2-VL-7B 的三个预算点与 Video-LLaVA 的 8 帧、2,048→256 token 试验也报告领先；视频表 5 的 STD 平均**准确率保持**为 96.7%，平均 score 保持为 99.1%，两列不可互换。InternVL3-8B 与 Qwen3-VL-8B 的 90% 删除实验在表 9 仍领先各表所列比较方法，但无政策安全评测。证据：表 3–5、9。
- 表 6 在单张 NVIDIA 4090D、POPE 上给 LLaVA-NeXT 的 dense→STD：prefill 323.0→83.2 ms（$3.9\times$），表中总推理时间 50:24→13:07（$3.8\times$），TFLOPs 45.61→5.16。LLaVA-1.5 的 prefill 118.0→64.3 ms（$1.8\times$）、总时间 17:53→10:05（$1.7\times$）。这些是该模型/基准/硬件下的实测，不等于本项目短政策 Guard 的收益；表未拆出 HSA、平滑、触发器单项时延。证据：§4.1、表 6。
- 64-token 消融中，相对标准多层剪枝，单加 HSA/GSA/SAT 都改善 TextVQA、GQA、POPE；三者组合为 56.0/56.1/81.2，标准法为 54.5/54.7/79.2。将模块交换层位通常变差，支持“分阶段使用”而不证明三种解释独立成立。超参数在附录表 13 的有限 POPE 扫描内变化较小，但作者在 Limitations 承认跨分辨率、预算和模型仍可能需要调整。证据：§4.2、表 7–8、附录表 13。

## 局限、复核注意与项目关系

作者明确指出阶段角色是经验概括，其他视觉架构未必相同；规则组件与超参数会受输入/模型变化影响；方法主要优化 prefill 视觉冗余，不直接解决 decoder latency 或 KV cache；文档、具身与细粒度推理仍未充分验证。附录表 12 的 STD 行给出 94.1% 六任务平均，但邻近文字误称“93.5 是最高”，正文/附录均存在少量口径或文字不一致，应以具体表项为准。主表写 Qwen2-VL，附录敏感性写 Qwen2.5-VL，复现实验前需要核对实际 checkpoint。证据：§4.1、表 4、附录 B/C、Limitations。

**项目判断：**STD 是 early-ViT 分层剪枝的强基线和反证：不能假定浅层注意力排名可靠，也不能简单声称“越早剪越好”。但其 HSA/GSA/SAT 均未用文本政策选择安全证据；RFFT 的一维序列高频是否对应政策相关的局部风险对象，也未经验证。对当前项目可在同图政策翻转、unsafe recall/FPR、OCR/小物体上比较它与政策条件选择器，并分别测 ViT、selector、LLM prefill、decode。[[LLM-Wiki/research/visual-token-pruning/papers/2026-he-coreprune.md|CoRePrune]] 的深度条件删除效应提供另一种解释：浅层删除后的长传播路径也可能贡献精度差，不能把 STD 的浅层结果全部归因于“注意力混乱”。这是跨论文综合假设，仍需同预算、同位置的受控实验。

## 证据定位与待验证

- 浅层禁剪对照与阶段观察：§2、表 1、图 2–4；算法与参数：§3、图 5、式 (1)–(7)。
- 各 backbone 的主结果、视频与计时：§4、表 2–6、9；组件与层位消融：表 7–8；32-token 和参数扫描：附录表 11、13。
- TODO：核实 Qwen checkpoint 名称和代码实现的频谱维度/最后层强制预算；在政策 Guard 上补安全非劣、same-image policy flip 与 selector-inclusive 端到端计时。本轮未执行。
