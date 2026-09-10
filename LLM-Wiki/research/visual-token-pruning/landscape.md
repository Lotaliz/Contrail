---
id: visual-token-pruning-landscape
type: synthesis
title: "背景：从推理删 Token 到训练可压缩的安全判别"
tags: [research, visual-token-pruning, multimodal-safety, knowledge-distillation]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-guo-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-liao-2026-vtc-bench, paper-cai-2024-matryoshka-mm, paper-yang-2025-visionthink, paper-zhang-2026-security-pitfalls-token-compression, paper-chen-2025-safewatch, paper-liu-2025-guardreasoner-vl, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap, paper-zong-2022-self-slimmed-vit, paper-feng-2026-em-kd, paper-cho-2026-restore, paper-chen-2026-otprune]
status: active
created: 2026-09-08
updated: 2026-09-09
---

# 机制背景

## 1. 将训练位置与压缩位置分开

“training-free selector”与“训练过的 compressed model”可以同时成立。TBD 固定压缩逻辑而训练学生，说明研究对象可以是判别模型本身。EPIC 则直接反驳必须新增网络结构才能学会低预算表示的假设。详见 [[LLM-Wiki/research/visual-token-pruning/comparison.md]] 与各 paper-note。

| 路线 | 训练改变什么 | 推理需要什么 | 对本项目的含义 |
|---|---|---|---|
| 现有推理 selector | 无，或只做离线配置校准 | 原模型+选择/合并 | 必须保留为基线，不能作为唯一研究框架 |
| 同结构压缩适配：EPIC、TBD | 在真实压缩输入上更新共享权重或 LoRA | 压缩后的同类主干 | 最直接的训练基线；“有训练”已不是创新 |
| 多预算表示：既有 M3、ViCO | 学习多个压缩预算下的输出 | 固定网格，或额外 router | 检验一个 checkpoint 是否覆盖多个预算；勿混同输入像素降低 |
| 任务统计量/记忆压缩：ETC、VisCo | 学紧凑表示及信息传递 | 瓶颈 mask、memory/KV 流程 | 最近邻概念反例，超出首选执行约束 |
| 训练吞吐优先：DualSpeed；LLaVolta 候选 | 调整压缩训练与完整训练分配 | 需逐篇核对 | 训练加速不等于 Guard 判定加速 |
| 证据依赖训练：Evidence-RL、Att-CoT | 反事实奖励/推理监督 | 原生模型或 CoT 输出 | 因果监督与延迟承诺已有先例，需检验压缩特有差异 |
| 压缩安全：Security Pitfalls、OOD-VTP | 主要是评测或免训练防御 | 压缩路径 | 区分攻击面、生成拒答与检测召回 |

## 2. 用户三项策略的直接最近邻

| 用户策略 | 已有直接覆盖 | 因而不能单独声称的创新 | 仍值得问的问题 |
|---|---|---|---|
| 重训练后减少视觉层 | EfficientVLM 蒸馏后把视觉编码器缩到 6 层；MuE 动态跳过统一 VLM 编码/解码层；METR 用多出口任务压力和自蒸馏改善早期视觉 token 重要性 | “首次蒸馏浅视觉塔”“首次早出口”“首次让浅层任务相关” | 何种浅层表示对**图文—政策安全判别**已经充分；能否只部署原塔前缀并在固定 FPR 下保持最坏组召回 |
| encoder 前/内的早剪 | Patch Slimming 用深层有效 patch 指导早层；Dyna-ViT 在 encoder 前做无参显著性选择；QuietPrune 用 query adapter 在 ViT 内早剪 | “首次前置剪枝”“首次 query 引导早剪”“不加参数即可早剪” | 低显著度、小 OCR、语境依赖危险证据如何得到空间覆盖；输入预算和可截断深度是否需联合训练 |
| 构造剪枝样本再训练 | EPIC、TBD、ViCO、多预算/嵌套模型均已把压缩状态放进训练 | “首次 compression-aware SFT/KD”“首次多预算课程” | 是否应优先生成**能使 full→compressed 安全判定翻转**的样本，并以学生可观察性决定蒸馏目标 |

FastVLM 进一步说明，视觉编码时延和送入 LLM 的 token 数必须同时计算；但其贡献依赖新的混合视觉编码器。若本项目强调不改主干，FastVLM 更适合作为换 backbone 的强上界。

## 3. 为什么安全视觉前缀仍可能形成独立问题

ResponseGuard 在单次 pooled 判别中取得很低的判定时延，但剩余差距集中于 image-only cells；作者把冻结视觉编码器视为可能原因，同时明确未完成解冻因果消融。这不证明浅视觉塔可行，却把“安全感知能否被训练前移”从一般压缩问题转成了 Guard 的直接瓶颈。

同时，SAP 已把 token pruning 与多模态 jailbreak 防御相连，并提出推理期恢复良性 token 的方法。因此安全论文不能再停留于“剪枝会降低安全”或“用安全分数保留 token”。独立 Guard 的漏报、固定 FPR、输入分辨率与视觉深度联合压缩，以及训练后对未知压缩状态的泛化，才是可保留的差异。

## 4. 三种“高低分辨率语义对齐”不能混用

1. **像素级低分辨率学生**：教师见高清，学生在 patchify 前降像素；同时节省视觉编码和 LLM，可能不可逆丢失小字或细节。
2. **高清编码后的少 Token 学生**：两者都付高清视觉塔成本，学生只缩短进入 LLM 的网格/序列；低预算不等于低清。
3. **压缩前语义凝聚**：先让原生编码器/浅层将局部关系汇入保留表示，再剪；潜在信息保留更好，但前段成本仍在。

本课题可在相同 LLM token 预算下比较前两者，定位失败是视觉输入不可辨、特征聚合损失还是政策判别失配，再决定训练哪个模块。不能笼统对齐所有视觉 feature：这可能浪费预算拟合背景，或把消失的证据伪装成可恢复信息。

### 4.1 少量 token 与完整 token 的表征对齐已有四种口径

| 口径 | 代表工作 | 对齐对象 | 与“最小二乘恢复”的距离 |
|---|---|---|---|
| 稠密特征重构 | SiT/FRD | 训练期把 $K$ 枚 token 非线性恢复成 $N$ 枚，再逐 block 做 token MSE | 最接近，但恢复器是学习型 RTSM，不是闭式最小二乘 |
| 不等长集合匹配 | EM-KD | Hungarian 匹配后的视觉词表分布，以及视觉—文本 affinity matrix | 解决对应关系，但不恢复全部教师空间位置 |
| 任务充分统计量 | ETC | instruction-aware predictive statistic；压缩表示经辅助 decoder 恢复该统计量 | 保留任务信息，不要求复刻所有视觉 feature |
| 分布、位置与注意力保持 | OTPrune；RESTORE | full/pruned token 分布；原位置关系和视觉注意力质量 | 多为选择或推理校准，不是教师—学生特征回归 |

EPIC/TBD/ViCO 主要在输出或相邻预算行为上做一致性，属于更弱的间接表征约束。以上工作共同说明“让少 token 保留 full-token 语义”不是空白；仍可研究的是不增加部署结构的**训练期安全充分子空间恢复**：只对经干预确认的危险证据和图文—政策关系加权，判断其是否能从极浅层固定预算 token 线性恢复，而不是最小化全图背景 MSE。

## 5. 从“保留教师表现”转向“学习正确的安全决策”

完整教师可能误判；低清学生也可能纠正教师。教师置信过滤已有 TBD 先例，仍不解决“教师正确但学生无法观察决定性证据”。此外，图像和文本各自安全、组合后违规，或同一对象在不同政策下标签不同，要求对齐关系与政策条件，而非仅实体向量。

这是本项目的综合推断。现有本地实验只能说明 full/pruned 行为不等价，尚不能确认这些机制在安全数据上的频率。[[LLM-Wiki/experiments/20260826-safety-pruning-finetuned/README.md|text-only 微调负结果]]提醒：没有有效的多模态任务学习，减少视觉 token 可能不是召回瓶颈。

## 6. 原方案需要降级的主张

“可解释/证据感知剪枝”“基于不确定性分配预算”“训练期反事实审计”和“延迟作答”都有直接相邻工作。保留为诊断或组件，不预设为主贡献。先检验可观察证据条件下的风险保持训练，再决定需要何种在线选择。背景无需重建模型结构或引入 serving 主线。
