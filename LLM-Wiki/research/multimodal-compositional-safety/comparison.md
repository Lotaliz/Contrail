---
id: multimodal-compositional-safety-comparison
type: synthesis
title: 图文联合安全基准与防御的证据比较
tags: [research, multimodal-safety, safety-evaluation, safety-guardrail, vision-language-model]
project_id: multimodal-compositional-safety
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-zhou-2024-multimodal-situational-safety, paper-kiela-2020-hateful-memes, paper-singguard-team-2026-singguard, paper-zong-2024-vlguard, paper-zhang-2024-spa-vl, paper-chakraborty-2024-cross-modal-safety, paper-gou-2024-ecso, paper-shayegani-2023-jailbreak-pieces, paper-huang-2025-llavashield]
status: active
created: 2026-09-20
updated: 2026-09-20
---

# 图文联合安全基准与防御的证据比较

## 基准与攻击

| 工作 | 年份 | 核心对象 | 是否严格 `S-S-U` | 规模 | 主要任务 | 对用户问题的直接性 |
|---|---:|---|---|---:|---|---|
| Hateful Memes | 2020 | 仇恨梗图与 benign confounders | 部分/任务等价，不逐条三标签 | 10K 级 | 内容二分类 | 早期证明单模态审核不足 |
| Jailbreak in Pieces | 2023 | 毒性 embedding + 泛化文本 | 否；图片经过对抗优化 | 攻击集 | 生成越狱 | 只作表征攻击近邻 |
| SIUO | 2024/2025 | 自然日常图片与安全文本 | **是** | 167 人工 + 102 AI 辅助 | 安全/有效生成、MCQA | 对任务模型失效最直接 |
| MSSBench | 2024/2025 | 活动在安全/危险情境中翻转 | 部分；强调情境而非逐条政策安全 | 1,820 图文对（v2 摘要） | chat/embodied 行为安全 | 现实情境扩展 |
| MSTS | 2025 | 40 类危险行动的指代组合 | **是** | 200 案例、400 英文提示，另有 10 语言 | 生成与回复审核 | 同时覆盖两个用户假设 |
| ELITE | 2025 | 多种安全/不安全图文极性 | 含 `S-S-U`，但非唯一重点 | 4,587（VLSU 对照表） | 输出安全评测 | 广义组合覆盖 |
| VLSU | 2025/2026 | 图、文、组合三标签 | **是，且覆盖 17 种组合** | 8,187 | 三分类与安全回应 | 最适合诊断组合失败 |
| MMDS | 2025/2026 | 多轮、多图风险累积 | 部分 | 4,484 对话 | 输入/输出多轮审核 | 时序扩展 |
| SingGuard-Bench | 2026 | 图像、多模态、动态政策、hidden intent | **含严格子集** | 56,340 总量；strict 数量未单列 | 专用 Guard | 防御侧最直接但属自建评测 |

> MSSBench 的公开版本数字在论文版本间出现 1,820、1,840/1,960 等口径差异。本页采用 arXiv v2 摘要的 1,820，不把不同版本合并为一个确定值；需要复现实验时必须锁定数据版本。

## 关键定量证据

| 证据 | 结果 | 能支持什么 | 不能支持什么 |
|---|---|---|---|
| SIUO 模态安全过滤 | GPT-4V/Gemini 的输入安全标记约 94.76%/95.96% | 单模态或常规过滤会把多数输入视为安全 | 不能证明每条都经独立人类单模态政策标注 |
| SIUO 任务模型 | 13/15 模型安全率低于 50%；GPT-4V 约 53.29%，其余模型中位约 23.65% | strict 组合可使任务模型安全响应失败 | 不能外推到当前所有新模型版本 |
| MSTS 模态对照 | MiniCPM-2.6 unsafe rate：联合 7.3%，文本等价 2.5%；GPT-4o 两者均 1.0% | 至少部分模型因多模态而更不安全 | 只有两个模型进行了该对照 |
| MSTS 自动判别 | Gemini 宏 F1 0.79、unsafe P/R 0.53/0.68；Llama Guard 3 Vision R 0.20；LlavaGuard R 0.05；Omni Moderation R 0.10 | 回复 Guard 在图文语境下会漏检且精确率/召回率失衡 | 不是同一输入 Guard 的 image/text/joint 三路消融 |
| VLSU 联合分类 | 清晰单模态信号可达 90%+，需联合推理的组合约 20%–55%；联合错误中 34% 是两种单模态均判对 | 组合算子本身是独立失败源 | 主要测试通用 VLM，不等同于生产专用 Guard |
| SingGuard-Bench attack split | F1：GuardReasoner-VL 0.5071、Llama Guard 4 0.7795、LLaVAShield 0.7348、SingGuard-2B 0.9164 | strict 定向数据和政策推理可能显著改善 Guard | 自建合成基准、strict 数量未单列、尚缺独立验证 |

## 防御方法比较

| 方法家族 | 代表工作 | 是否直接训练 strict 组合 | 成本 | 优点 | 主要风险 |
|---|---|---:|---|---|---|
| 安全 SFT | VLGuard | 未单独报告 | 中 | 简单、可与指令微调混合 | 学到危险词/物体捷径；过度拒答 |
| 偏好对齐 | SPA-VL | 未单独报告 | 中—高 | 联合优化安全与帮助性 | 偏好 judge 可能同样不懂组合 |
| 文本 unlearning | Cross-Modal Safety Alignment | 否，主要是视觉越狱 | 低—中 | 复用语言主干安全边界 | 不能自动获得新组合关系 |
| 图转文推理 | ECSO | 否 | 推理时中 | 无需训练、可复用 LLM 对齐 | caption 丢失空间/指代/隐含线索 |
| 结构化/多代理安全推理 | VLSU prompt、MSSBench pipeline | 用 strict/情境样本评测，训练较少 | 高 | 显式分解感知、关系和政策 | 延迟、错误传播、解释不忠实 |
| 原生多模态 Guard | Llama Guard 3 Vision、SafeAtlas-VL | 多数未单列 | 中 | 可做输入/输出独立审核 | 任务目标混合、专用 strict 证据不足 |
| 推理式 Guard | GuardReasoner-VL、LLaVAShield | 部分/未单列 | 高 | 能输出政策理由、支持复杂语境 | CoT 长、校准与过度拦截问题 |
| strict + 政策条件化 Guard | SingGuard | **是** | 中—高；有快慢模式 | 当前最直接覆盖 hidden intent | 最新预印本、自建数据同源性 |

## 指标建议

| 角色 | 主指标 | 必须同时报告 | 不应单独使用 |
|---|---|---|---|
| 任务模型 | unsafe assistance rate；有效安全回应率 | safe-by-design、safe-by-accident、borderline 帮助性 | 只看拒答率或 ASR |
| 输入 Guard | strict `S-S-U` unsafe recall@固定 FPR | P/R 曲线、最坏类别召回、校准 | 只看 accuracy 或宏 F1 |
| 输出 Guard | harmful assistance recall@固定 FPR | 图文语境与 text-only 回复的差值 | 脱离原始图文只审核回复 |
| 端到端系统 | 任务模型漏报且 Guard 再漏报的联合概率 | 延迟、人工复核率、良性阻断率 | 把各组件 F1 简单平均 |

## 总体证据等级

- **强：** strict 组合会使部分任务模型安全对齐失效；三篇独立工作以不同构造重复观察。
- **中强：** 自动审核器能在图文语境中显著漏掉有害回复；MSTS 有人工金标和多个专用系统对照。
- **中：** strict 定向训练能大幅修复 Guard；目前主要由 SingGuard 自建数据/基准支持。
- **弱或待证：** 任意专用 Guard 都会在图文联合输入相对单模态时显著下降；缺少跨 Guard、同数据、三路输入的统一因果对照。

