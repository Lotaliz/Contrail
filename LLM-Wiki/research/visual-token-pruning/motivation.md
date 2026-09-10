---
id: visual-token-pruning-motivation
type: synthesis
title: "研究动机：面向低时延 Guard 的安全充分视觉前缀"
tags: [research, writing, visual-token-pruning, multimodal-safety, knowledge-distillation]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-liao-2026-vtc-bench, paper-zhang-2026-security-pitfalls-token-compression, paper-gu-2026-ood-vtp, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-wang-2022-efficientvlm, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap]
status: draft
created: 2026-09-08
updated: 2026-09-08
---

# 论点—证据—可写边界

| 论点 | 直接证据与定位 | 门槛与边界 |
|---|---|---|
| 训练必须成为强基线 | EPIC §3–4；TBD §3–4 | 两篇独立来源证明训练先例，不证明本方法新颖或安全有效 |
| 低预算有信息恢复边界 | TBD §5；VTC-Bench 既有分辨率敏感评测；XGuard §3.2 | 多来源加本地证据支持问题，“可见性门控更好”仍未验证 |
| 真实时延与风险需联合评估 | 用户关键路径约束；XGuard 时延测量 | 场景约束加直接实验达到门槛，当前并非固定 FPR 安全加速结论 |
| 生成模型安全不等于 Guard 检出 | OOD-VTP §4.1；Security Pitfalls §4–5 | 用于限定评价对象，尚未证明本地 Guard 的新增漏洞 |
| 整体表现不足以衡量困难子群 | XGuard §2 的类别缺失与 §3.2 异质性；VTC-Bench 筛选原则 | 支持独立子群评测，不支持预设哪个子群必然受益 |
| 视觉塔是独立时延与能力瓶颈 | FastVLM 的 vision+prefill 分解；ResponseGuard §5.3–5.4 | 支持直接研究视觉路径；ResponseGuard 未证明解冻或截层一定有效 |
| 浅层任务压力与前置剪枝已有先例 | EfficientVLM；METR；Dyna-ViT；QuietPrune | 反证简单组合的新颖性，迫使方法回答安全充分性与最坏压缩状态 |
| 安全感知剪枝已出现 | SAP 官方论文仓库；Security Pitfalls | 生成模型 jailbreak 与独立 Guard 漏报必须分开，不能声称首次安全剪枝 |

原文与阅读层级见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md]]；本地证据见 [[LLM-Wiki/experiments/20260907-xguard-token-pruning-analysis/README.md]]。VTC-Bench 沿用既有原文与主文证据，本轮不声称重新完整精读。

# 可用于研究计划的动机草稿

多模态安全判别器必须在较短时间内根据图像、用户文本和政策作出决定；决定性证据可能是局部小字、实体间关系，或图文结合后才出现的风险。本地 XGuard 实验表明，输入降分辨率比已比较的中间层选择更快，同时呈现不同的类别退化。FastVLM 将视觉编码与 LLM prefill 同时计入效率分析，进一步说明只在视觉塔之后删 token 会漏掉关键成本。这些证据支持直接优化视觉路径，但不足以证明安全召回可以无损保持。

研究范围不能局限于对既有模型施加推理剪枝。EPIC 和 TBD 已将压缩纳入训练；EfficientVLM 已用蒸馏派生浅视觉语言模型；METR 已用多出口监督把任务压力送入早期视觉层；Dyna-ViT 与 QuietPrune 已分别覆盖无参 pre-encoder 选择和 query-guided ViT 早剪。因此，仅增加微调、截层、前置 Top-K 或合成剪枝样本都不是充分贡献。

安全任务仍有一个可检验的交叉空白。ResponseGuard 的单次判定把剩余差距定位到 image-only cells，并把冻结视觉编码器列为可能原因；同时，SAP 已表明 token 选择会改变多模态 jailbreak 行为。这两项证据共同提示，视觉路径不只是通用精度组件，其压缩状态可能改变安全决策边界。现有工作没有据此证明：原有视觉塔的一个浅层前缀能否在图文—政策监督下成为安全判别的充分表示，以及输入分辨率、patch mask 与截断深度中少数最危险的组合能否通过训练被系统修复。这里的“没有证明”是本轮有限检索结论，不是全领域首次声明。

据此，本项目提出研究问题：在不设计新 backbone 的条件下，能否用完整视觉塔作训练期教师，把图文—政策决策所需的证据前移到可部署的浅层视觉前缀，并在分辨率×patch×深度压缩格上直接优化会造成漏报的尾部状态？学生仍可观察证据时，训练应保持政策反事实效应和 unsafe margin；证据被压缩抹去时，不应盲目复制高清教师的确定性。候选方法必须超过同等资源下的截层安全 SFT、logit/feature KD、METR 式 early pressure、EPIC/TBD 式多预算蒸馏、QuietPrune 式早剪及直接低分辨率训练。

这一设计把用户提出的三项策略变成同一个闭环：压缩格中的高损失状态决定合成与重采样；同一政策因果监督决定哪些 patch 应在首层前保留；同一最坏组约束决定最浅可部署深度。训练辅助出口、教师和状态搜索均在部署时删除。若固定深度和固定 token 预算已经达到目标，则无需在线 router；只有信息确实不可观察的样本才进入后续升级研究。

# 尚不能写成贡献的内容

- Hypothesis H1：可观察性门控比仅教师置信过滤更有效。
- Hypothesis H2：关系/政策训练可把部分困难判别前移到短输出路径。
- Hypothesis H3：压缩状态安全训练可缩小 Guard 特有绕过面。
- Hypothesis H4：政策因果监督可以使原视觉塔前缀在相同深度下优于普通 multi-exit/KD。
- Hypothesis H5：按 unsafe harmful-flip 的压缩尾部训练优于平均随机多预算训练。
- 不声称首次训练感知剪枝、首次因果证据训练、零信息损失、安全保证或确定达到某顶会标准。
- 完整模型也可能错；升级成本与失败必须计入最终指标。

假设的反证与停止条件见 [[LLM-Wiki/research/visual-token-pruning/gaps.md]]；流程见 [[LLM-Wiki/research/visual-token-pruning/multimodal-safety-token-pruning-research-plan.md]] §20。
