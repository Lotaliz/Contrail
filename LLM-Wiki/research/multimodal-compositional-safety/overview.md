---
id: multimodal-compositional-safety
type: research-overview
title: 图文联合内容风险与组合式安全
aliases: [跨模态组合风险, Safe-Safe-Unsafe, SIUO]
tags: [research, multimodal-safety, safety-alignment, safety-evaluation, safety-guardrail, vision-language-model]
status: active
related: [visual-token-pruning, safety-classifier-compression]
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-zhou-2024-multimodal-situational-safety, paper-kiela-2020-hateful-memes, paper-singguard-team-2026-singguard, paper-zong-2024-vlguard, paper-zhang-2024-spa-vl, paper-chakraborty-2024-cross-modal-safety, paper-gou-2024-ecso, paper-liu-2025-guardreasoner-vl, paper-chi-2024-llama-guard-vision, paper-huang-2025-llavashield, paper-wang-2026-safeatlas-vl]
created: 2026-09-20
updated: 2026-09-21
---

# 图文联合内容风险与组合式安全

## 一句话结论

AI 安全研究已经明确注意到“图像单独安全、文本单独安全、组合后有害”的风险。严格证据在 2024—2026 年快速形成：[[LLM-Wiki/research/multimodal-compositional-safety/papers/2024-wang-siuo.md|SIUO]]、[[LLM-Wiki/research/multimodal-compositional-safety/papers/2025-rottger-msts.md|MSTS]] 和 [[LLM-Wiki/research/visual-token-pruning/papers/2025-palaskar-vlsu.md|VLSU]] 已分别证明任务模型会生成不安全回答、自动安全判别会漏检或误报，以及模型即使分别判对两个模态仍可能判错组合。专门面向此类样本的 Guard 训练与评测则到 [[LLM-Wiki/research/visual-token-pruning/papers/2026-singguard-team-singguard.md|SingGuard]] 才出现较直接的规模化证据，仍缺独立复核。

## 当前研究路线

本项目当前只保留一条主线：构造经过三标签和配对反事实审计的 strict 数据，系统测量专业多模态 Guard 的组合式规避，并以 compatibility-preserving 的组合风险残差模块修复漏洞。速度、视觉 Token 剪枝和早退出不再属于本项目的核心贡献；它们归入独立的 [[LLM-Wiki/research/visual-token-pruning/research-plan.md|政策条件 ViT 前剪枝路线]]。

完整研究问题、威胁模型、数据协议、防御和安全顶会写作建议见 [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|路线一研究计划]]。

## 研究范围

### 核心定义

对图像 $I$、文本 $T$ 和组合 $I\oplus T$ 分别标注安全性：

$$
y_I=\mathrm{safe},\qquad y_T=\mathrm{safe},\qquad y_{I\oplus T}=\mathrm{unsafe}.
$$

该页把这种 `S-S-U` 或 strict cross-modal hidden intent 作为核心。联合风险可能来自实体—动作绑定、指代消解、空间情境、常识或领域知识、潜在意图和行动后果。

### 包含

- 自然语义组合：两种模态表面和单独语义均无显式有害内容，联合后构成危险建议、犯罪意图、歧视或其他政策违规。
- 情境安全：同一安全活动在不同视觉环境中由安全转为危险。
- 输入 Guard 与输出 Guard：既判断用户图文请求，也判断回复是否在图文语境中构成有害协助。
- 组合式硬负例、反事实配对、政策条件化判别与显式安全推理。

### 不直接等同

- 把完整有害指令写进图片的 OCR/排版越狱，例如 FigStep、MM-SafetyBench；此时图片本身通常不是语义安全。
- 视觉扰动或毒性 embedding 攻击，例如 *Jailbreak in Pieces*；其图片只是对人看似无害，在模型表征空间并不安全。
- 只有单一模态已经明确有害的 `U-S-U`、`S-U-U` 或 `U-U-U` 样本。

## 两个用户假设的证据判断

| 假设 | 判断 | 最强直接证据 | 证据边界 |
|---|---|---|---|
| 任务模型安全对齐失效并输出有害内容 | **成立，证据强** | SIUO 中 15 个模型有 13 个安全率低于 50%，GPT-4V 约 53.3%；MSTS 中部分开源模型出现 5.8%–14% 明确支持危险行为的回答；VLSU 的联合分类困难组合仅约 20%–55% | 模型版本和拒答策略随时间变化；“安全但误解”不能算真正安全 |
| 安全判别模型显著下降并漏检联合风险 | **存在且直接可测，但不能泛化为所有 Guard 的普遍定律** | MSTS 对 4,000 条人工标注回复测试：Llama Guard 3 Vision 的 unsafe recall 为 0.20，LlavaGuard 为 0.05，Omni Moderation 为 0.10；VLSU 中 34% 的联合错误发生在两个单模态都判对时 | MSTS 主要评测图文请求语境下的**回复审核**，不是同一个 Guard 的纯输入模态消融；专用 Guard 的严格 `S-S-U` 对照仍少 |

## 机制判断

1. **训练标签拓扑缺口。** 许多早期安全集集中在 `U-U-U`、`S-U-U` 或 `U-S-U`，模型可以用任何单一危险词、危险物体或 OCR 内容完成分类，不必学习组合关系。
2. **文本主导与视觉利用不足。** VLSU 观察到联合预测更随文本预测变化，视觉相关性相对稳定且偏弱；单模态都正确也不保证组合正确。
3. **感知、组合与政策推理是三个环节。** 模型可能看见物体、理解句子，却没有完成指代绑定、意图推断、后果预测或政策匹配。
4. **拒答不等于理解。** MSTS 的 safe-by-accident 与 VLSU 的 borderline over-blocking 表明，高拒答率可能掩盖理解失败并损伤帮助性。
5. **Guard 的任务定义常错位。** 图片审核、请求审核、回复审核和完整 `(image, query, response)` 审核不是同一任务；把文本回复脱离图像审核会丢失视觉语境。

## 攻防全景

| 层面 | 代表路线 | 对严格联合风险的作用 | 当前不足 |
|---|---|---|---|
| 数据集/攻击 | SIUO、MSTS、VLSU、SingGuard-Bench；仇恨梗图的 benign confounder；MSSBench 情境翻转 | 显式构造单模态安全而组合有害的压力测试 | 数据量小或高度合成；自然分布、跨语言、视频与多轮覆盖不足 |
| 任务模型对齐 | VLGuard SFT、SPA-VL 偏好对齐、文本 unlearning、ECSO 图转文、推理或多代理流程 | 可降低一般多模态越狱率，推理/分解有机会补足组合关系 | 多数并未在 strict `S-S-U` 切片上报告效果，无法确认是否真正修复组合机制 |
| 安全判别 | Llama Guard 3 Vision、GuardReasoner-VL、LLaVAShield、SafeAtlas-VL、SingGuard | 原生联合输入、政策条件化、推理监督和 query/response 分离是正确方向 | 公开基准混合任务多，strict 子集规模与独立验证不足；F1 容易掩盖低召回或过度拦截 |

## 调研导出的数据与评测协议

以“**三标签 + 配对反事实 + 端到端双角色评测**”为主线：

1. 每条数据都标注 $y_I$、$y_T$、$y_{I\oplus T}$，并由人独立验证两个单模态确实安全。
2. 为同一图片和同一文本分别构造安全/有害配对反事实，使组合标签翻转但单模态表面统计尽量不变。
3. 同时评测任务模型的 unsafe assistance、有效安全回应和 safe-by-accident，以及输入 Guard、输出 Guard 和端到端级联的漏报。
4. 防御对比至少包括：通用多模态安全 SFT/偏好对齐、增加 strict 组合样本、显式关系/后果推理、原生多模态 Guard、图转文 Guard、快慢级联。
5. 以固定假阳性率下的 unsafe recall、最坏类别召回、校准误差和帮助性为主指标，不只报告总体 F1 或攻击成功率。

## 导航

- [[LLM-Wiki/research/multimodal-compositional-safety/landscape.md|数据集、攻击与防御版图]]
- [[LLM-Wiki/research/multimodal-compositional-safety/comparison.md|横向比较与证据强度]]
- [[LLM-Wiki/research/multimodal-compositional-safety/gaps.md|研究缺口与可证伪问题]]
- [[LLM-Wiki/research/multimodal-compositional-safety/motivation.md|正式研究动机]]
- [[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|攻击、测量与 Guard 防御研究计划]]
- [[LLM-Wiki/research/multimodal-safety-guard/overview.md|双路线总计划]]
- [[LLM-Wiki/research/multimodal-compositional-safety/reading-log.md|检索与筛选记录]]
