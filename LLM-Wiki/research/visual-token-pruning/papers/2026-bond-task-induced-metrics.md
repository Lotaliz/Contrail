---
id: note-2026-bond-task-induced-metrics
type: paper-note
title: "Task-Induced Riemannian Metrics for Vision Transformer Feature Spaces"
authors: ["Andrew Bond", "Ege Erdem Özlü", "Tuna Çimen", "Ilkin Umut Melanlioglu", "Tolga Birdal", "Erkut Erdem", "Aykut Erdem"]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-27988
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, efficient-inference]
status: active
created: 2026-09-25
updated: 2026-09-25
---

# Task-Induced Riemannian Metrics：按下游任务敏感性衡量视觉 token

## 来源与阅读边界

来源：[arXiv 2609.27988v1](https://arxiv.org/abs/2609.27988)，2026-09-23 首次提交；本地原件 [[LLM-Wiki/raw/papers/2609.27988v1.pdf]]，31 页。已阅读正文 §1–8、表 1–2 与附录 D–H、M 的方法、数据、消融和局限；未运行代码、训练 importance head 或复测时延。下述数值均为作者报告；本笔记中的“项目判断”不是原文结论。

## 问题、假设与方法

作者问的是：冻结 ViT 与任务 decoder 后，欧氏/余弦特征距离能否代表下游任务对不同特征方向的敏感度？在视觉塔某层特征 $F^\ell\in\mathbb{R}^{N\times D}$ 上，将剩余视觉层和 decoder 合成映射 $\psi_\ell$，其 Jacobian $J$ 定义局部半正定形式 $g(F)=J^\top J$；$v^\top gv=\|Jv\|^2$ 是一阶输出变化，不是远距离特征图的全局度量。正文 §3、图 1 明确说明原始 $g$ 通常奇异，推理用低秩项加各向同性正值底座。

第一步是**先诊断是否值得学习低秩任务几何**。$\kappa_{cap}(r)=\sum_{j\le r}\sigma_j^2/\|J\|_F^2$ 衡量前 $r$ 个奇异方向覆盖的敏感度，奇异向量在 token 间的能量变异系数 CV 衡量空间集中度。作者用 Hutchinson、随机 Lanczos 与矩阵无关的 JVP/VJP 和幂迭代离线估计；默认 $r=20,m=100,q=2$，约 140 组 JVP/VJP，不能视作推理免费步骤。表 1 将 DPT depth、DINOv2 CLS、VGGT camera/pointcloud/depth 分为谱丰富、低秩但分散、谱丰富但空间集中、输出维度限秩四种情形。低 CV 时独立逐 token 打分信号弱，这里的判断依赖特定 backbone–decoder–探测层，不能推广为“所有视觉 token 都不可排序”。证据：§4、表 1、附录 E。

第二步用 Spectral Pullback Network（SPN）从特征预测低秩方向及其能量；训练目标来自幂迭代的子空间与奇异值监督。实际 token 选择可只运行约 310K 参数、含跨 token 注意力的 importance head，用缓存的 Jacobian 谱目标训练，推理时无需 decoder 反向传播，但**需要离线训练且针对特定任务/层**。对 CLS decoder，低分 token 按任务度量软合并到保留 token；对 DPT 等密集 decoder，则硬剪枝、保留原位置，并用 Last-Layer Fusion（LLF）在最后一个 ViT block 前重新插入被剪 token。因而 DPT 的方案不是全程把这些 token 删除，最后一层仍付出完整序列计算。证据：§5–7、图 1、附录 D。

对于 VGGT dense head 的高有效秩，作者另训练 VAE 将多个视觉层特征压入 32 个 register token、每个 128 维，再在压缩潜空间学习 SPN。该路径测量的是**VAE 重构后**的 pullback，不等于原模型的精确任务度量，也与表 2 的 ViT token 剪枝试验分开。证据：§6、附录 M。

## 实验设置与直接证据

- 诊断覆盖 Depth-Anything V2/DPT、DINOv2、CLIP 与 VGGT 的不同 decoder；DINOv2 CLS importance head 用 2,000 张 ImageNet-val 图像训练、200 张留出图像评估，token 排名相对 Jacobian 谱目标的 Spearman $\rho=0.998\pm0.001$。这验证拟合目标，不直接证明下游任务准确率提升。DPT 低 CV 情形的对应 $\rho\approx0.20$，直接预测完整 Jacobian block norm 仅约 $0.09$。证据：§4–5、表 1、附录 F。
- 表 2 在 ImageNet-val 224 输入、三种选择器共用相同合并/LLF 流水线、三次种子下比较额外误差。DINOv2 CLS 于删除比例 $\eta=0.50$ 时，importance 的余弦距离退化为 $2.09\times10^{-2}$，ToMe 选择为 $3.82\times10^{-2}$；CLIP CLS 也有同向结果。DPT 单阶段的额外 SILog（表中 $\times100$）在 $\eta=0.50$ 时为 importance 3.08、ToMe 4.09，约减少 25%；但 $\eta=0.05$ 时 importance 4.88，反而差于 ToMe 4.29。证据：§7、表 2、附录 G。
- NYU-Depth-V2 的密集预测结果依赖数据与阶段数。单阶段在高删除比例或 448 分辨率可能输给 ToMe；两阶段 $[4,8]$ 于表 5–6 所列比例均有优势，但优势并非正文所说的每档约 25–35%：NYU@224、$\eta=0.50$ 为 5.58→5.12，仅约 8%；NYU@336/448 同档也约 10%。正文的概括与表格在紧预算端不一致，应以逐格数值为准。证据：§7.3、附录 D、表 4–6。
- 成本以单张 A40、batch 1 的 ViT backbone 计。224 分辨率、$\eta=0.20$ 虽减少理论 FLOPs 12.1%，实际为 $0.96\times$（慢于未剪）；两阶段同分辨率为 $0.88\times$。448 分辨率单阶段才有 $1.12\times$，仍低于 ToMe 的 $1.15\times$。没有完整 MLLM/Guard 端到端时延。证据：附录 D “Cost”、附录 M。

## 局限、作者主张与项目判断

作者主张任务几何可改善 token 选择，表 2 支持特定 ViT 任务的表征保真与深度误差改善；ImageNet top-1 在各方法中接近，不能据此推出分类准确率显著获益。原文承认单阶段受数据集、分辨率和删除比例影响，四阶段在高比例累积误差，VAE 几何无原模型误差界，importance head 不保证跨 decoder 迁移，且低分辨率时延可能变差。证据：§7、附录 D、H、M。

**项目判断：**当前短政策条件 Guard 的目标是保留政策相关安全证据并获得真实端到端加速；本论文没有 MLLM、文本政策或 unsafe recall 评测。可迁移的是“以目标输出扰动而非通用相似度定义 token 价值”的诊断思想，以及先测低秩/空间集中度再决定是否训练选择器。若想把政策条件引入其 $\psi_\ell$，需要明确 Guard 输出/风险条款距离，重新训练 head，并单独测 selector、LLF、ViT 与 LLM 全链时延；这是研究假设，非论文已验证结果。可与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-qcpruner.md|QCPruner]] 的 query proxy，以及 [[LLM-Wiki/research/visual-token-pruning/papers/2026-he-coreprune.md|CoRePrune]] 的局部删除扰动比较，但三者的 proxy、剪枝位置与计算开销不同。

## 证据定位与待核验

- 几何定义、四类诊断与理论适用边界：§3–4、图 1、表 1、附录 C/E。
- SPN、importance head 与 VAE：§5–6、式 (5)–(8)、附录 B/J/M。
- 剪枝规则、共享流水线、主结果及成本：§7、表 2、附录 D、表 4–6、附录 G/H。
- TODO：复查实现中的任务距离与 head 训练/验证划分；在政策 Guard 上做同图政策翻转与证据保留评测，并计入离线训练和在线选择成本。本轮均未执行。
