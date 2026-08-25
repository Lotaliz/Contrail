---
id: safety-classifier-compression-reading-log
type: synthesis
title: 安全判别剪枝与蒸馏检索日志
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-chi-2024-llama-guard-vision, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-muralidharan-2024-minitron, paper-sun-2024-wanda, paper-xia-2024-sheared-llama, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-wu-2023-tinyclip, paper-yang-2024-clip-kd, paper-vasu-2024-mobileclip, paper-yang-2025-visionzip, paper-chen-2025-safewatch]
status: active
created: 2026-08-24
updated: 2026-08-24
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
