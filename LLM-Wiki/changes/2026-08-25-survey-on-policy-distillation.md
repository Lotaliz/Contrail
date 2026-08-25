---
id: change-2026-08-25-survey-on-policy-distillation
type: change
tags: [research, method]
title: 调研安全判别压缩中的 On-policy 蒸馏
date: 2026-08-25
change_type: content
---

# 调研安全判别压缩中的 On-policy 蒸馏

- 登记并分层阅读 8 篇一次论文，覆盖 imitation-learning 谱系、GKD、reverse/skew KL、对比蒸馏、前缀降本、目标稳定化与安全自蒸馏。
- 新建可复用概念 [[LLM-Wiki/concepts/methods/on-policy-distillation.md]]，明确严格 OPD 与静态 KD、强化学习和 encoder 错误驱动造数的边界。
- 在安全判别压缩项目中新增技术路线、统一比较、候选缺口 G6 与待验证假设 H8；因为直接安全证据仅有一篇预印本且不是 Guard 分类器，未升级正式 Motivation。
- 保存来源 PDF 与校验值；没有运行实验，也没有把通用生成任务结果外推为安全 Guard 结论。
