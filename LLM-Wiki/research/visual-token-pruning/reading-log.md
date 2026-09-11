---
id: visual-token-pruning-training-reading-log
type: synthesis
title: "训练参与的视觉 Token 压缩：检索与证据日志"
tags: [research, visual-token-pruning, knowledge-distillation, multimodal-safety]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-gu-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-chen-2024-llavolta, paper-xing-2024-pyramiddrop, paper-wang-2026-loreal, paper-2026-covipal, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap, paper-zong-2022-self-slimmed-vit, paper-feng-2026-em-kd, paper-cho-2026-restore, paper-chen-2026-otprune, paper-yu-2023-x-pruner, paper-fan-2026-visual-token-semantics, paper-wang-2026-information-horizon]
status: active
created: 2026-09-08
updated: 2026-09-10
---

# 检索范围

检索日与截止日：2026-09-10。以 arXiv 原文、CVF、NeurIPS、OpenReview、ACL、AAAI、ECVA 和作者项目页为证据；搜索引擎中的聚合页只用于发现，再回到原文。覆盖 2022—2026，重点补充 2025—2026 的训练、蒸馏、跨分辨率一致性及压缩安全研究。不以检索未命中证明研究不存在。

纳入：改变训练目标或训练输入预算、具有直接新颖性冲突、研究压缩导致的语义/安全失败，或提供强比较基线的工作。排除：纯权重压缩、无视觉任务的上下文压缩、纯生成加速、单纯 serving 优化；保留必要相邻工作作为反证。代码未运行，论文数字不视为本地测量。

## 检索批次与 discovered 候选（先登记，后核验）

| 批次 | 实际查询关键词 | 初步候选与处理 |
|---|---|---|
| Q1 | visual token pruning training aware fine tuning low high resolution distillation 2026; visual token compression training safety guard pruning 2026 | ViCO、VisCo、ETC、TBD；待原文阅读 |
| Q2 | site.arxiv.org visual token compression training 2026 distillation; ViCO; PyramidDrop; LLaVolta | InternVL3.5、PyramidDrop、LLaVolta；区分训练加速和推理压缩 |
| Q3 | Token-Budget Distillation; visual token pruning-aware training; visual token safety compression training distillation | TBD、Fast-Slow、CoViPAL、ET-Prune；待核对结构与任务 |
| Q4 | visual Progressive Consistency Distillation; Security Pitfalls Token Compression; Visual Token Compression Enhances Robustness; high low-resolution distillation VLM token | ICD、Security Pitfalls、Robustness、LOREAL、RADIOv2.5；待区分 Guard 检测与被保护模型拒答 |
| Q6 | early vision encoder layer reduction distillation VLM; pre-encoder token pruning; query-guided early pruning; efficient multimodal guard frozen vision encoder | EfficientVLM、Patch Slimming、METR、FastVLM、Dyna-ViT、QuietPrune、ResponseGuard；用于三项策略排重 |
| Q7 | token-pruning-induced vulnerabilities safety-aware pruning; compression-aware safety training guard | SAP 及相邻压缩攻击；区分生成模型 jailbreak/拒答与独立 Guard 漏报 |
| Q8 | visual token pruning feature reconstruction/distillation; unbalanced vision-token alignment; distribution/attention alignment; least-squares recovery | SiT/FRD、EM-KD、ETC、OTPrune、RESTORE；用于“少 token→完整表征恢复”排重 |
| Q9 | early-layer vision token pruning; shallow feature token importance; explainable ViT pruning; causal token information | 复核 Patch Slimming、METR、Dyna-ViT、QuietPrune；补入 X-Pruner、EmbedLens 与 Information Horizon，区分热图、probe 与因果删除解释 |

候选尚不构成 motivation；后续阅读结果、唯一来源 ID、版本和排除原因在本页更新。项目主文仍为 [[LLM-Wiki/research/visual-token-pruning/multimodal-safety-token-pruning-research-plan.md]]。

## 阅读结果与版本边界

| 方法 | source_id / 笔记 | 本轮层级 | 处理 |
|---|---|---|---|
| epic | [[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-epic.md]]；`paper-wen-2025-epic` | deep-read / source-checked | 2510.00515v1；会议身份另核对 NeurIPS 2025 官方页 |
| tbd | [[LLM-Wiki/research/visual-token-pruning/papers/2026-guo-token-budget-distillation.md]]；`paper-guo-2026-token-budget-distillation` | deep-read / source-checked | 2608.28138v1，2026-08-28；会议标注来自稿件，未独立确认 proceedings |
| vico | [[LLM-Wiki/research/visual-token-pruning/papers/2025-wang-internvl35-vico.md]]；`paper-wang-2025-internvl35` | skimmed / source-checked | 2508.18265v2；仅聚焦 ViR/ViCO，authors 登记第一作者，完整名单见原文 |
| etc | [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-etc.md]]；`paper-gao-2026-etc` | deep-read / source-checked | 2606.00543v2；§1–5、附录 A.1–A.2、图表与执行路径 |
| dualspeed | [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-dualspeed.md]]；`paper-zhang-2026-dualspeed` | skimmed / source-checked | 2602.03815v1 |
| ood | [[LLM-Wiki/research/visual-token-pruning/papers/2026-gu-ood-vtp.md]]；`paper-gu-2026-ood-vtp` | skimmed / source-checked | 2607.22716v1；稿件会议 DOI 为占位符，不据此确认录用 |
| etprune | [[LLM-Wiki/research/visual-token-pruning/papers/2026-ding-et-prune.md]]；`paper-ding-2026-et-prune` | skimmed / source-checked | 2608.01979v1 |
| visco | [[LLM-Wiki/research/visual-token-pruning/papers/2026-zheng-visco.md]]；`paper-zheng-2026-visco` | skimmed / source-checked | 2607.12756v1 |
| evidencerl | [[LLM-Wiki/research/visual-token-pruning/papers/2026-huang-evidence-rl.md]]；`paper-huang-2026-evidence-rl` | skimmed / source-checked | 2608.08021v1 |
| attcot | [[LLM-Wiki/research/visual-token-pruning/papers/2026-sinha-att-cot.md]]；`paper-sinha-2026-att-cot` | skimmed / source-checked | 2606.01558v1 |
| llavolta | [[LLM-Wiki/research/visual-token-pruning/papers/2024-chen-llavolta.md]]；`paper-chen-2024-llavolta` | discovered / unverified | 2406.20092v2；本轮仅题录/摘要与作者项目页 |
| pyramiddrop | [[LLM-Wiki/research/visual-token-pruning/papers/2024-xing-pyramiddrop.md]]；`paper-xing-2024-pyramiddrop` | discovered / unverified | 2410.17247v2；本轮只核题录/摘要 |
| efficientvlm | [[LLM-Wiki/research/visual-token-pruning/papers/2022-wang-efficientvlm.md]]；`paper-wang-2022-efficientvlm` | skimmed / source-checked | 2210.07795v1；蒸馏后缩短视觉/文本/融合层 |
| patch-slimming | [[LLM-Wiki/research/visual-token-pruning/papers/2022-tang-patch-slimming.md]]；`paper-tang-2022-patch-slimming` | skimmed / source-checked | 2106.02852；final→early patch 选择先例 |
| metr | [[LLM-Wiki/research/visual-token-pruning/papers/2024-liu-metr.md]]；`paper-liu-2024-metr` | skimmed / source-checked | ICLR 2024 官方页/PDF；多出口 early pressure+自蒸馏 |
| fastvlm | [[LLM-Wiki/research/visual-token-pruning/papers/2025-vasu-fastvlm.md]]；`paper-vasu-2025-fastvlm` | skimmed / source-checked | CVPR 2025；新混合视觉编码器，显式测 vision+prefill |
| dyna-vit | [[LLM-Wiki/research/visual-token-pruning/papers/2026-rubab-dyna-vit.md]]；`paper-rubab-2026-dyna-vit` | skimmed / source-checked | CVPR 2026 Findings；无参 pre-encoder saliency |
| quietprune | [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md]]；`paper-gao-2026-quietprune` | skimmed / source-checked | CVPR 2026；query adapter 引导 ViT 内早剪 |
| responseguard | [[LLM-Wiki/research/visual-token-pruning/papers/2026-na-responseguard.md]]；`paper-na-2026-responseguard` | deep-read / source-checked | 2607.21401v1；§1–6、主表、视觉差距与校准 |
| sap | [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md]]；`paper-wang-2026-sap` | skimmed / source-checked | 官方作者仓库；正文链接本轮未得，会议状态仅按仓库登记 |
| sit-frd | [[LLM-Wiki/research/visual-token-pruning/papers/2022-zong-self-slimmed-vit.md]]；`paper-zong-2022-self-slimmed-vit` | skimmed / source-checked | ECCV 2022；RTSM 训练期稠密恢复+逐 block MSE |
| em-kd | [[LLM-Wiki/research/visual-token-pruning/papers/2026-feng-em-kd.md]]；`paper-feng-2026-em-kd` | skimmed / source-checked | AAAI 2026；Hungarian matching+视觉语义/图文 affinity 蒸馏 |
| restore | [[LLM-Wiki/research/visual-token-pruning/papers/2026-cho-restore.md]]；`paper-cho-2026-restore` | skimmed / source-checked | ICML 2026；位置与注意力失真校准、anchor merging |
| otprune | [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-otprune.md]]；`paper-chen-2026-otprune` | deep-read / source-checked | arXiv 2602.20205v3；§1–6 与附录；原文标注 CVPR 2026 |

第一次训练参与调研登记 14 条来源：原表 12 条及下列 2 条待核候选；新增 12 篇笔记（现为 3 deep-read、7 skimmed、2 discovered）。针对用户三项策略的二次排重再登记 8 条来源并新增 8 篇笔记（1 deep-read、7 skimmed）。表征恢复补检新增 4 条来源与 4 篇笔记（现为 1 deep-read、3 skimmed）。累计登记 26 条来源、24 篇笔记（5 deep-read、17 skimmed、2 discovered）；来源原件未下载，仅登记稳定 URL；未改动已存 PDF、原始实验和旧笔记。

- LOREAL：`paper-wang-2026-loreal`；[CVF PDF](https://openaccess.thecvf.com/content/CVPR2026/papers/Wang_LOREAL_Mitigating_Low-Resolution_Challenges_in_Vision-Language_Models_with_Attribute-driven_Prompt_CVPR_2026_paper.pdf) 搜索可见，但直接 PDF/HTML 访问失败；discovered，作者字段待核，不用于正式动机。它是 G1 新颖性结论的重要未决项。
- CoViPAL：`paper-2026-covipal`；[OpenReview 稿件](https://openreview.net/pdf?id=RqY4w2gxW9) 仅搜索片段；discovered，题录/状态待核，不用于正式动机。
- Q5 补检：`visual token training September 2026`、`visual token safety distillation guard`、`visual token counterfactual training`，发现并回读 Evidence-RL 与 Att-CoT；LOREAL 另用题名查询。
- Q6/Q7 补检表明三项单点均有直接最近邻：EfficientVLM/METR 对应浅层任务蒸馏，Dyna-ViT/QuietPrune 对应前置或 ViT 内早剪，EPIC/TBD 对应剪枝状态再训练；SAP 进一步排除“首次安全感知 token pruning”。Q8 表明稠密特征恢复、不等长匹配、任务统计量、分布保持与注意力校准均有先例；未检索到直接以闭式最小二乘恢复安全证据子空间的工作，但此结论仅是有限检索结果。
- 其他发现但未入核心比较：LRCP/EvoCut/SPARE（选择规则）、LiteFrame（换视觉编码器）、RADIOv2.5（视觉基础模型蒸馏）、长视频 selection/reinvestment。只作为后续检索线索，不据此概括具体论文方法或推出研究空白。

## 既有证据复用

Security Pitfalls 复查原文 §3–5 的压缩专属攻击与任务范围；VTC-Bench 核对 ACL 页面并沿用库内 PDF/主文分析；M3/VisionThink 复用既有来源。未整体提升这些论文的阅读深度，也未新建重复来源。SafeWatch、GuardReasoner-VL、DART 等使用已有 Wiki 笔记与主文。

XGuard 2026-09-07 的探索结果与 2026-08-26 text-only 微调负结果均保留。双向因果审计是计划而非已得到结果。

## 覆盖不足与证据门槛

本轮针对性搜索覆盖公开可访问材料，不等于 2026-09-08 前全部工作；无检索命中不能证明不存在。近期 arXiv 的会议页眉可能含占位元数据，TBD/OOD-VTP 不仅凭页眉宣布正式录用。EPIC 的 NeurIPS 2025 身份已核对[官方页](https://papers.nips.cc/paper_files/paper/2025/hash/6518f9339196e172fa0ceef48a85543a-Abstract-Conference.html)。

强新颖性排重仍需 LOREAL、CoViPAL 原文及更广泛低分辨率/选择性预测研究。本轮不声称复现实验或发现确定空白；候选差异均附反证和停止条件。正式动机引用事实已映射到来源/实验，方法效果均为 hypothesis。
