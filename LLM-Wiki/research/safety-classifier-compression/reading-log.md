---
id: safety-classifier-compression-reading-log
type: synthesis
title: "安全判别剪枝与蒸馏检索日志"
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-chi-2024-llama-guard-vision, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-muralidharan-2024-minitron, paper-sun-2024-wanda, paper-xia-2024-sheared-llama, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-wu-2023-tinyclip, paper-yang-2024-clip-kd, paper-vasu-2024-mobileclip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety, paper-fairoze-2026-controlled-release, paper-nasr-2026-attacker-moves-second, paper-zhang-2026-mtk, paper-zhang-2026-vsg-safe]
status: active
created: 2026-08-24
updated: 2026-08-25
---

# 检索与阅读日志

## 检索设置

- 检索日期与时间截点：2026-08-24；近三年定义为 2023-08-24 至 2026-08-24。
- 站点：ACL Anthology、OpenReview、NeurIPS Proceedings、CVF Open Access、PMLR、arXiv 与官方研究页。
- 关键词族：safety classifier/guard/content moderation + pruning/distillation/compression/efficient/lightweight；text classification + LLM distillation/structured pruning/hard negative；vision-language/CLIP + pruning/distillation/token pruning/latency。
- 纳入：正式论文或安全领域有明确技术细节的官方预印本；至少报告判别质量；核心证据还须报告计算、时延、内存、训练或标注成本之一。
- 排除：只做生成；只量化且无剪枝/蒸馏；仅参数量或理论 FLOPs、没有质量结果；无法回到一次来源的二手文章。

## 候选到核心证据

| 论文 | 层级 | 核验 | 角色 |
|---|---|---|---|
| Llama Guard 3-1B-INT4 | deep-read | source-checked | 安全任务结构压缩、Logit 蒸馏、INT4 与移动端 |
| HarmAug | deep-read | source-checked | 安全 Guard 数据蒸馏、长尾增广与 A100 成本 |
| SafeRoute | deep-read | source-checked | 压缩学生失败样本的级联补偿 |
| MULTIGUARD | skimmed | source-checked | 跨语言/模态安全表征复用 |
| Llama Guard 3 Vision | discovered | source-checked | 多模态安全未压缩基线 |
| SafeWatch | deep-read | source-checked | 视频 Guard；policy-aware visual-token pruning；生成多标签判定与解释 |
| PGKD | deep-read | source-checked | 工业文本分类、反馈驱动数据蒸馏 |
| P-pruning | deep-read | source-checked | 先剪后调，降低分类微调成本 |
| Minitron | deep-read | source-checked | 结构剪枝 + 蒸馏降低模型家族训练成本 |
| Wanda | skimmed | source-checked | 免训练非结构化/半结构化剪枝基线 |
| Sheared LLaMA | skimmed | source-checked | 目标形状结构剪枝与数据配比 |
| SmartTrim | skimmed | source-checked | 多模态 Token/Head 动态剪枝 + 自蒸馏 |
| MoPE-CLIP | skimmed | source-checked | 跨模态重要性、宽度/深度剪枝 |
| TinyCLIP | deep-read | source-checked | affinity 蒸馏与权重继承 |
| CLIP-KD | skimmed | source-checked | 多种跨模态蒸馏信号对照 |
| MobileCLIP | deep-read | source-checked | 离线数据强化与移动端 batch=1 |
| VisionZip | skimmed | source-checked | 最新 LVLM 视觉 Token 剪枝邻接证据 |

## 检索覆盖限制

- 安全判别的直接剪枝/蒸馏论文数量远少于通用压缩论文；因此正式综合结论只在直接证据与相邻任务证据一致时给出。
- Llama Guard 3-1B-INT4 和 Llama Guard 3 Vision 为官方预印本；前者有可部署模型和设备实测，但仍不等同于同行评审会议证据。
- 不同论文的任务、硬件、batch、序列长度、计时范围和教师 API 定价不同，速度与成本数字不可直接排名。
- 2026 年会议覆盖截至 8 月 24 日，未声称穷尽所有预印本。
- 没有本地复现实验，verification 均不使用 reproduced。
- SafeWatch 是本轮唯一直接把视觉 Token 剪枝用于可生成解释的安全 Guard 的正式论文；本轮结论不声称该方向已有大量独立复现。

## 2026-08-25：On-policy 蒸馏增量检索

- 时间截点：2026-08-25。检索站点：OpenReview、PMLR、ACL Anthology、arXiv；关键词：`on-policy distillation`、`student generated rollout knowledge distillation`、`reverse KL LLM distillation`、`reasoning prefix distillation`、`on-policy safety self-distillation`。
- 纳入：能明确区分 student rollout 与固定/teacher sequence，或直接处理 rollout 成本、散度稳定和安全应用的一次论文；排除只有离线教师标签、仅在标题中泛称 online、无法核验一次来源的工作。

| 论文 | 层级 | 核验 | 角色 |
|---|---|---|---|
| Lin et al. 2020 Autoregressive KD | skimmed | source-checked | imitation-learning 谱系与 student-visited states |
| GKD | deep-read | source-checked | 固定数据/学生 rollout 混合与散度统一框架 |
| MiniLLM | skimmed | source-checked | reverse-KL、低方差与混合采样 |
| DistiLLM | skimmed | source-checked | skew-KL 与 rollout 复用/刷新降本 |
| DistiLLM-2 | skimmed | source-checked | 教师正样本—学生负样本的对比蒸馏 |
| Prefix OPD | skimmed | source-checked | 长推理前缀截断，降低 rollout/教师成本 |
| Veto | skimmed | source-checked | forward/reverse KL 病态与目标重构 |
| OPSA | deep-read | source-checked | 直接但未同行评审的安全自蒸馏证据 |

覆盖限制：核心方法证据集中于通用文本生成与推理；仅 OPSA 直接涉及安全，且不是 Guard 分类器。没有发现截至截点在“多模态自回归 Guard 分类 + 归因生成”上系统比较 OPD 与静态 KD 的正式论文；该表述是本轮检索覆盖下的结论，不是穷尽性证明。

## 2026-08-25：安全顶会审稿视角增量检索

- 范围：2024–2026 USENIX Security、ACM CCS、NDSS、IEEE S&P 中与 Guard、内容审核、越狱检测、部署近似和多模态长尾直接相关的论文；辅以 ICLR/ACL 的 Guard 压缩直接证据。
- 关键词：`prompt guard efficiency adaptive attack`、`content moderation latency`、`compression safety vulnerability`、`multimodal guard token pruning`、`cross-frame unsafe content`。
- 核心观察：安全顶会接受的工作通常不是“把模型做小”，而是揭示新的攻击面/失败机制、定义安全属性或构建可验证的系统防线；效率是实践约束和评测维度。

| 论文 | 层级 | 核验 | 对本问题的作用 |
|---|---|---|---|
| Controlled-Release Prompting | skimmed | source-checked | 轻量 Guard 与强目标模型之间存在可被攻击利用的计算不对称 |
| The Attacker Moves Second | skimmed | source-checked | 静态攻击集会显著高估防御；压缩 Guard 必须接受自适应攻击 |
| Manifold Trajectory Kinetics | skimmed | source-checked | 说明顶会更关注伪恶意输入、固定 FPR 与动态安全信号，而非平均准确率 |
| VSG-Safe | skimmed | source-checked | 跨帧分布式危害是视频审核的安全语义；激进 token/frame 削减可能破坏证据完整性 |

覆盖限制：本轮不宣称穷尽全部 2026 论文；四篇增量论文基于官方论文页、摘要和方法/结果概览完成 `skimmed`，未达到复现层级。
