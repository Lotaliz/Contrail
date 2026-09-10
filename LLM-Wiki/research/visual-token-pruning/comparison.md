---
id: visual-token-pruning-comparison
type: synthesis
title: "训练参与视觉压缩：统一比较与最近邻审查"
tags: [research, visual-token-pruning, multimodal-safety, knowledge-distillation]
project_id: visual-token-pruning
sources: [paper-wen-2025-epic, paper-guo-2026-token-budget-distillation, paper-wang-2025-internvl35, paper-gao-2026-etc, paper-zhang-2026-dualspeed, paper-gu-2026-ood-vtp, paper-ding-2026-et-prune, paper-zheng-2026-visco, paper-huang-2026-evidence-rl, paper-sinha-2026-att-cot, paper-liao-2026-vtc-bench, paper-cai-2024-matryoshka-mm, paper-yang-2025-visionthink, paper-zhang-2026-security-pitfalls-token-compression, paper-chen-2025-safewatch, paper-liu-2025-guardreasoner-vl, paper-wang-2022-efficientvlm, paper-tang-2022-patch-slimming, paper-liu-2024-metr, paper-vasu-2025-fastvlm, paper-rubab-2026-dyna-vit, paper-gao-2026-quietprune, paper-na-2026-responseguard, paper-wang-2026-sap, paper-zong-2022-self-slimmed-vit, paper-feng-2026-em-kd, paper-cho-2026-restore, paper-chen-2026-otprune]
status: active
created: 2026-09-08
updated: 2026-09-09
---

# 方法比较

下表中的代码状态是本轮核查结果，不代表论文没有代码。相同 token 数不代表相同时延；训练样本、GPU 小时和可训练参数须同时匹配。新论文详见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md]]。

| 方法 | 任务/输入 | 选择信号与位置 | 预算 | 训练需求 / 结构 | 数据、基线与指标 | 效率口径 / 局限 | 代码 |
|---|---|---|---|---|---|---|---|
| EPIC | 通用图文理解 | 复用 DART/FastV/Random，层位置可渐进 | 多预算 | SFT+渐进 KL，同主干 | LLaVA-665K；多种压缩/无蒸馏消融；10 基准 | 表 2 为 POPE CUDA 总时间，非安全时延 | 作者仓库已定位，未运行 |
| TBD | 视频问答 | LLM 前 FlashVID 等，selector 不训练 | 固定保留预算 | LoRA+可靠答案蒸馏 | Video-178K；LoRA-only/多压缩模块；4 基准 | 训练完整教师仍昂贵；无 Guard 召回约束 | 官方可用实现未核实 |
| ViCO / ViR | 通用图文、OCR | patch 网格压缩，损失比监督 router | 256/64 per patch | 一致性后训+额外 ViR | SFT/OCR/VQA；Flash 对原版均分 | 表 17 非安全子群；不能代替输入 resize 时延 | 原文入口，未运行 |
| DualSpeed | MLLM 训练 | 插件式剪枝，fast/slow 模式 | 压缩/完整 | 双模式、自蒸馏、mode isolator | LLaVA 系列；剪枝训练/推理比较 | 核心是训练墙钟；full-path 失配需检查 | 作者仓库已定位，未运行 |
| ETC | 图文问答/grounding | 任务加权 hidden state 的 VID 稠密重构，LLM 瓶颈 | 1/2/4 压缩 tokens | 学习 token；训练期 MLP decoder，推理移除 | LLaVA/Qwen3；通用 VQA、RefCOCO | 完整视觉塔与完整 token prefill 仍执行；短标签时延收益未证 | 官方来源，未运行 |
| SiT / FRD | 纯视觉分类 | TSM 软聚合；训练期 RTSM 恢复稠密 token | 多 stage | 逐 block token MSE+logit KD；推理移除 RTSM | ImageNet；vanilla ViT/LV-ViT | 最接近少 token→完整特征恢复；非安全/VLM | 官方代码，未运行 |
| EM-KD | 通用 MLLM | Hungarian 匹配不等长视觉 token | 教师/学生不同 token 数 | 视觉词表 reverse KL+图文 affinity Smooth L1 | 多理解/解析基准 | 不重构全部教师位置；训练匹配开销不进入推理 | 未运行 |
| OTPrune | 通用 MLLM | 零均值高斯二阶统计、Wasserstein 代理与 log-det 覆盖；不做特征重构 | 固定原 token 子集 | training-free，Gram+Cholesky 贪心 | 11 个多模态基准 | 完整视觉塔已执行；均匀且文本无关；selector-inclusive latency 未报 | 官方来源，未运行 |
| RESTORE | 通用 MLLM | 位置保持、注意力校准和 anchor merging | 多保留率 | 推理期校准，不做教师 feature KD | LLaVA/Qwen 系列、多基准 | TextVQA merging 暴露高频细节稀释 | 官方代码，未运行 |
| VisCo | 通用图文理解 | 内在自编码、分层 memory KV | 多种紧凑预算 | 共享主干，改变 memory 执行 | 三主干、六基准 | 不改主干不等于不改执行协议 | 未核实 |
| ET-Prune | OCR 密集图文 | 问题相关、区域保护、熵密度；中层 | 动态下限 | 无训练 | TextVQA/OCRBench；多 selector | 单次评测点估计，早段成本未省 | 未核实 |
| OOD-VTP | 生成拒答/幻觉 | 语言空间距离；选定层 | 剪枝率 | 无训练 | SafeBench/MM-SafetyBench/CHAIR | 拒答不是 Guard 检出，需补良性 FPR | 作者仓库已定位，未运行 |
| Evidence-RL | 证据密集视觉推理 | 局部干预支持差，训练期 | 不研究压缩预算 | GRPO，无在线审计 | 九基准、证据/干预消融 | 无额外审计不等于短输出 | 未核实 |
| Att-CoT | 多步视觉推理 | 视觉 attention+承诺时序，训练期 | CoT 长度非视觉预算 | 辅助 SFT，同架构 | CLEVR/ChartQA 等及遮挡测试 | CoT decode 仍需计费 | 未核实 |
| EfficientVLM | 通用 VL | 先蒸馏，后按模态做结构/神经元剪枝 | 6V/3T/3X 等 | 紧凑学生，改变整体模型规模 | VQA/NLVR/检索/描述 | 报告 2.2x；非 Guard、非输入 patch 联合压缩 | 未运行 |
| Patch Slimming | 纯视觉分类 | final→early 的 top-down patch 影响 | 分层 patch 预算 | 微调既有 ViT | ImageNet 等 | FLOPs 降低不等于 VLM 判定时延 | 未运行 |
| METR | 纯视觉分类 | 多出口压力使早期 `[CLS]` attention 可用于删 token | 多层 reduction | 训练多出口+自蒸馏；推理保留 reduction | 标准视觉基准 | 已直接覆盖“早层任务压力+token reduction” | 未运行 |
| FastVLM | 通用 VLM | 新 FastViTHD 编码器，以输入分辨率控制 token | 多分辨率 | 换视觉 backbone 并训练 | 多项 VLM/OCR 基准 | 显式测 vision+prefill；结构变化较大 | 官方代码，未运行 |
| Dyna-ViT | 纯视觉分类 | encoder 前按能量/边缘/熵等无参显著性选 patch | 固定 Top-K | 主干不改，无新增参数 | VOC/CIFAR/Tiny-ImageNet | 不看 query/policy；安全小证据可能低显著 | 未运行 |
| QuietPrune | 通用 VLM | 文本→视觉 `[Q-CLS]`；ViT 内早剪和聚合 | 多剪枝率 | 训练轻量 adapter，改变前向输入 | Qwen3-VL/InternVL3，多项 VLM 基准 | 同时省视觉塔和 prefill；安全政策未测 | 无代码入口，未运行 |
| ResponseGuard | 独立多模态 Guard | 单次 pooled 表示直接分类 | 固定全输入 | LoRA+小 head，冻结视觉编码器 | prompt/response harmfulness | 报 67.6 ms；图像组仍弱，骨干非同模型对照 | 官方代码，未运行 |
| SAP | 被保护生成 VLM 的 jailbreak 安全 | 推理期恶意锚点识别、良性 token 恢复和 attention 重分配 | 多剪枝率 | plug-and-play，推理协议变化 | 3 安全+4 utility（仓库说明） | 非独立 Guard 检出；论文正文链接本轮未得 | 官方代码，未运行 |

## 与既有证据的关系

- M3 已联合训练嵌套视觉网格；不能声称首次任意预算训练。
- VisionThink 已用训练决定何时看高清；不能声称首次学习分辨率升级。
- SafeWatch 已是 policy-aware pruning 的直接安全先例。
- VTC-Bench 与 XGuard 已使 resize 成为必须比较的方案。
- Security Pitfalls 已研究压缩状态特有漏洞；“发现剪枝可被攻击”不足以构成新安全论文。

上述复用已登记来源及主文已有来源定位，本轮不将其整体阅读级别自动提升。

## 拟议方法必须增加什么

| 候选增量 | 最近邻已覆盖 | 仍须证明的差异 |
|---|---|---|
| 任务+压缩联合训练 | EPIC/TBD/ViCO | 固定 FPR 下困难政策子群改善，不仅均分恢复 |
| 高清→低清对齐 | ViCO 相邻预算、TBD full→compressed；LOREAL 待读 | 学生证据可见性决定监督与拒绝强一致性，且击败相同训练的 resize |
| 少 token→完整表征恢复或分布覆盖 | SiT/FRD、EM-KD、ETC、OTPrune、RESTORE | ETC 属于任务表征重构，OTPrune 只做二阶分布覆盖；安全证据加权的训练期可恢复性还需证明其预测 harmful flip，不能只报全局 feature MSE |
| 首标签政策关系蒸馏 | TBD margin；Att-CoT；GuardReasoner-VL | 不增加在线推理长度仍改善组合风险，且避免标签/语言捷径 |
| 干预生成训练监督 | Evidence-RL | 干预×压缩的交互收益，而非普通 grounding 后训收益 |
| 可靠蒸馏 | TBD 教师过滤 | 独立检查学生可观察性与 full/pruned 双向纠错 |
| 压缩安全防御 | Security Pitfalls；OOD-VTP | 明确 Guard 威胁模型、固定 FPR、跨攻击/预算泛化，不靠全回退 |
| 浅层安全视觉塔 | EfficientVLM；MuE；METR | 不是普通 early exit；须证明政策条件下的安全充分性、真实截断及 image-only/worst-group 增益 |
| encoder 前/内早剪 | Patch Slimming；Dyna-ViT；QuietPrune | 不是 query adapter 换成 policy；须处理低显著度危险证据和输入×深度交互 |
| 单次 Guard 判定 | ResponseGuard | 同 backbone/数据下拆分视觉前缀、输出形式和训练目标；严格 FPR 而非只报加权 F1 |
| 安全感知剪枝 | SAP；SafeWatch；Security Pitfalls | 独立检测 Guard、漏报威胁与训练泛化；不把生成拒答或 jailbreak ASR 当 recall |

完整可执行对照矩阵见主文 §20；候选性质见 [[LLM-Wiki/research/visual-token-pruning/gaps.md]]。
