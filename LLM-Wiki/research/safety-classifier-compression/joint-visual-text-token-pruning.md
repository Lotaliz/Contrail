---
id: joint-visual-text-token-pruning-safety
type: synthesis
title: "生成式多模态 Guard 中的视觉—文本 Token 压缩"
tags: [research, multimodal-safety, vision-language-model, visual-token-pruning, efficient-inference]
project_id: safety-classifier-compression
sources: [paper-zhong-2025-aim, paper-gao-2026-quietprune, paper-sun-2026-hi-lo-prune, paper-feng-2026-asymvlm, paper-zhou-2024-rethinking-visual-dependency, paper-chen-2025-safewatch, paper-chen-2025-safeptr, paper-zhang-2026-trimtokenator, paper-cao-2023-pumer, paper-wang-2024-smarttrim, paper-shi-2024-crossget, paper-cao-2024-madtp, paper-mu-2023-gist-tokens, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard]
status: active
created: 2026-09-14
updated: 2026-09-24
---

# 生成式多模态 Guard 中的视觉—文本 Token 压缩

## 精确研究对象

检索截止 2026-09-14。核心对象限定为 Qwen3-VL、LLaVA、InternVL 等 decoder-only 生成式 MLLM：图像经视觉编码器和 projector/resampler 产生视觉 token，与 system/policy/user 文本 token 组成同一 LLM 输入序列，模型自回归生成安全标签、类别与简短归因。

CLIP 双塔、ViLT/METER 跨模态 encoder、带 `[CLS]` 分类头的 VLP 不作为直接进展或默认实验基线。只有当其机制可移植到上述同序列自回归拓扑时，才作为机制来源；移植后的有效性必须重新验证。

## 核心结论

在这一严格范围内，本轮未发现已经建立成熟闭环的“视觉 token 与当前输入文本 token 同时按样本剪枝，以保持生成式安全判别与归因并降低真实输入成本”的方法族。更准确的研究现状是：

1. 主流 decoder-only MLLM 效率工作大量裁减视觉 token，但保留 prompt 文本。
2. 同构模型上的 AIM 直接测试了 LLM 层内文本 token 剪枝，VideoMME 从 58.2 降到 45.7，因此最终只剪视觉 token。
3. AsymVLM 将两种模态视为不同阶段的瓶颈：视觉 token 在 prefill 前裁减；文本只在长生成时做 decode-time KV eviction，prompt/prefill 文本始终保护。它不是联合输入剪枝。
4. 长上下文 LVLM 中确有删除文本噪声的工作，但适用前提是长文本上下文；不能外推到短安全政策、用户指令、否定和例外条件。
5. SafePTR 是同序列 MLLM 中同时删除视觉与用户指令 token 的安全相关先例，但目标是抑制 jailbreak 触发并恢复良性生成，不是低成本安全分类；Guard 恰需保留危险证据，目标方向相反。

因此，不应把“图文都必须剪”写成通用方法前提。更有证据的起点是先测量每一类输入；若视觉主导，采用模态非对称视觉压缩；若长政策主导，则必须优先做政策结构化编译，并让视觉选择与条款覆盖协同，而不是沿用统一 BPE Top-k。

## 2026-09-22：目标 workload 的成本结构反转

原文“常见 $N_v \gg N_p+N_u$”只适用于部分图像问答/短提示场景。当前政策自适应 Guard 中，用户报告 $N_p>4N_v$，Dyna-ViT 式 90% pre-ViT 视觉剪枝仅得到 1.14× 端到端加速且精度明显下降。忽略额外选择开销，用 Amdahl 关系反推的有效可移除视觉路径约为 13.6%，对应完全消除时约 1.16× 上限。

该测量尚未链接原始 profiler，不能外推为普遍结论；但它足以否定本 workload 的“视觉预算是唯一主变量”。当前更合适的结构是：

1. 完整政策离线解析为可审计条款或 policy memory；
2. 按图像以高召回检索可能相关条款，保护否定、例外和作用域；
3. 候选条款指导 pre-ViT patch 选择，视觉预览反过来修正条款集合；
4. 对未见政策、低置信和小证据样本回退到更大预算。

MADTP 是 CVPR 2024 的联合视觉/语言 token 剪枝先例，但采用 CLIP/BLIP 双分支与短文本，其附录反而显示语言分支成本低且更敏感。Gist Tokens 提供政策编译/缓存机制先例，同时报告 FLOPs 与墙钟收益显著不一致，说明这里必须测 cold/warm policy 和真实端到端时延。

## 同构模型的核心证据

| 方法 | 模型拓扑与输出 | 视觉侧 | 文本侧 | 对当前问题的结论 |
|---|---|---|---|---|
| AIM, ICCV 2025 | LLaVA-OneVision/LLaVA-1.5；decoder-only 生成 | LLM 前相似性合并；LLM 层内渐进剪枝 | 全部保留；剪枝消融显著退化 | 直接反证统一图文 Top-k；visual-only 是强基线 |
| QuietPrune / Hi-Lo Prune, CVPR 2026 | Qwen3-VL 等 decoder-only VLM | ViT 早剪，或早期 LLM 层先 merge 再删 | 不剪文本；query 只指导视觉选择 | Qwen3-VL 直接强基线，但仍是 visual-only |
| SafeWatch, ICLR 2025 | 会生成多标签判定与解释的视频 Guard | policy-aware Top-k 视觉 token | 政策并行编码，不剪当前文本 token | 任务和输出最接近；证明视觉剪枝可与生成式归因共存 |
| SafePTR, NeurIPS 2025 | decoder-only MLLM jailbreak 防御 | vulnerable layers 删除偏离安全空间的 token | 同时删除用户指令 token，后续恢复 | 架构同构但目标相反；只能迁移分模态打分/保护思路 |
| TrimTokenator, ACL Findings 2026 | LLaVA 系列生成式 MLLM | 自适应视觉剪枝 | 明确保留全部文本 token | 进一步支持模态非对称策略 |
| AsymVLM, 2026 预印本 | 现代 decoder-only VLM | prefill 前样本级视觉预算 | 仅长生成后做文本 KV eviction；保护 prompt | 把输入压缩和 cache 管理分开；短归因场景文本收益可能很小 |
| Rethinking Visual Dependency, 2024 预印本 | 长上下文 LVLM 推理 | 保持视觉信息 | 删除长文本上下文中的低价值信息 | 只证明长文本噪声可压，不支持短 prompt 任意 BPE 删除 |

## 传统 VLP 只保留的可迁移机制

| 方法 | 为什么不属于核心证据 | 仍可迁移的机制 |
|---|---|---|
| PuMer | ViLT/METER 式融合 encoder；任务以 VQA、检索、蕴含为主 | pruning 与 merging 结合；模态内合并避免跨模态语义污染 |
| SmartTrim | METER/BLIP 类架构，依赖两模态全局表示与分类/理解目标 | 样本级 gate、成本正则、full-path 自蒸馏 |
| CrossGET | 跨 token 改造双分支/融合拓扑，不是 Qwen3-VL 原生同序列 prompt 剪枝 | 双向跨模态代理；重要性与冗余联合；merge 优先于硬删 |

这些方法不能被写成“Qwen3-VL 式联合图文输入剪枝已有先例”，也不应与可直接插入 decoder-only MLLM 的 AIM、FastV、SparseVLM、VisionZip 等并列比较，除非先完成架构移植。

## 成本结构决定是否值得碰文本 token

先记录每类 token 的真实长度与阶段成本：视觉 token 数 $N_v$、固定政策 token 数 $N_p$、用户文本 token 数 $N_u$、输出 token 数 $N_o$。不同 Guard 的排序不能预设：短提示图像问答可能是 $N_v \gg N_p+N_u$，当前长政策 workload 则观察到 $N_p>4N_v$。前者优先视觉压缩，后者应优先政策编译；两者都必须保护因果依赖、角色边界、否定、引用、例外和混淆字符串。

文本侧应分为三个不同问题：

- **固定 policy/system 文本：** 优先做模板规范化、离线编译、policy latent/soft prompt 蒸馏或可复用的前缀表示；这属于表示压缩，不等同于逐样本删 BPE token。
- **用户文本：** 默认完整保护；只有在长文本条件成立时才研究 span/句子级选择，并保护角色、否定、实体、动作、引用和政策触发 span。
- **生成标签与归因：** 用固定 schema、先 verdict 后 rationale、长度约束或按需生成降低 decode 成本；短输出下无需优先做 KV eviction。

图像中的 OCR 文字仍属于视觉证据，不能因为语义上是“文本”就计入文本预算或被视觉 selector 忽略。

## 更合适的研究假设

不应预设 $K_v$ 与 $K_t$ 都小于原长度。控制问题可写为：

$$
\min_{K_v,K_p,K_u,L_o}\; C_{device}(K_v,K_p,K_u,L_o)
\quad \text{s.t.}\quad
R_{unsafe@FPR},\ R_{worst},\ F_{rationale} \ge \tau,
$$

其中控制器允许 $K_u=N_u$，甚至把“完整保留用户文本”设为默认硬约束。真正要验证的不是能否同时删除两种 token，而是：安全任务是否存在样本使文本压缩具有正净收益；如果不存在，最优解自然退化为视觉剪枝 + 政策表示压缩 + 短归因。

## 建议的实验闭环

1. 在目标 Qwen3-VL 配置上记录 $N_v,N_p,N_u,N_o$ 分布，以及视觉塔、projector、LLM prefill、time-to-verdict、完整归因、selector 和 compact 的 P50/P95。
2. 核心基线只用同构生成模型：full tokens、低分辨率/均匀池化、QuietPrune 式 ViT 早剪、Hi-Lo/AIM 式 merge-before-drop 与层内视觉剪枝、SafeWatch 式 policy-aware visual selector。
3. 文本侧做分层负对照：随机/BPE 删除、attention token 删除、span 压缩、固定政策 latent；不要把用户文本与政策文本混为一个 retention ratio。
4. 至少设置四组输入：image-only hazard、text-only hazard、图文组合后才 unsafe、图文冲突/否定/OCR。报告 unsafe-to-safe flip、fixed-FPR recall、worst-group recall 和归因 sufficiency/comprehensiveness。
5. 只有当 text-side 方法在 selector-inclusive 真实 P95 上提供可测净收益，且不降低上述安全指标，才把它升级为联合输入压缩；否则结论应明确为模态非对称方案。

## 证据边界

AIM 的文本消融来自 VideoMME，SafeWatch 来自视频 Guard，TrimTokenator 来自通用 LLaVA，AsymVLM 与长上下文文本 pruning 目前是预印本；它们不能替代 Qwen3-VL 安全数据上的本地实验。但这些独立证据一致否定了“视觉 token 可剪，所以短文本 token 也应共同剪”的类比。

当前最可信的论文问题不是“首次联合剪视觉和文本 token”，而是：**在长政策主导的 decoder-only 多模态 Guard 中，如何把政策编译为可审计条款表示，并让视觉证据与政策条款协同分配预算，在安全非劣下获得真实端到端收益。**

关联：[[LLM-Wiki/research/safety-classifier-compression/autoregressive-multimodal-guard-token-pruning.md]]；[[LLM-Wiki/research/safety-classifier-compression/gaps.md]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。
