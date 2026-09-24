---
id: change-2026-09-21-multimodal-guard-two-track-plan
type: change
title: "将多模态安全 Guard 研究重组为两条独立投稿路线"
tags: [change, research, multimodal-safety, visual-token-pruning]
date: 2026-09-21
change_type: Changed
status: active
---

# 变更说明

根据用户的新研究边界，将原有多模态安全研究方案重组为两个相互独立、可分别投稿的项目：图文联合风险的安全攻击—测量—防御，以及图像风险 + 文本政策的 ViT 前视觉 Token 剪枝。

## 新增

- `research/multimodal-safety-guard/overview.md`：双路线总计划、边界、可行性、阶段门与会议排期。
- `research/multimodal-compositional-safety/research-plan.md`：路线一的威胁模型、数据协议、专业 Guard 测量、兼容性防御、安全顶会写作和停止条件。
- `research/visual-token-pruning/research-plan.md`：路线二的 pre-ViT 定义、policy-conditioned selector、数据与实验矩阵、CVPR 写作和停止条件。
- `raw/sources.yaml` 中的 CVPR 2027 官方 CFP 来源。

## 覆盖更新

- 路线一的 overview、motivation、gaps 和 reading-log：明确现象已有先例，创新集中于专业 Guard 的可利用漏洞、外部复验和 legacy 非劣防御。
- 路线二的 overview、motivation、gaps 和 reading-log：当前主线改为 `(image, policy)` 的首个 ViT block 前视觉 Token 选择；旧实验只作为历史证据。
- 研究索引、首页、标签代表页和跨项目链接统一指向新计划。

## 删除

- `research/multimodal-compositional-safety/fast-joint-token-guard-security-venue-assessment.md`：旧的快速联合 Token Guard 投稿评估。
- `research/visual-token-pruning/early-joint-safety-exit-assessment.md`：旧的浅层联合判别与早退出分支评估。
- `research/visual-token-pruning/multimodal-safety-token-pruning-research-plan.md`：旧的安全充分视觉前缀综合方案。

## 保留

所有论文笔记、原始来源、reading-log 的历史条目、专题综述、实验 README、负结果和未完成证据均保留。删除只针对纯方案/评估文档；未修改原始论文文件或实验输出。

## 学术边界

- 路线一不声称首次发现 `S-S-U`、首次 strict 数据或首次专门 Guard；这些均有 SIUO、MSTS、VLSU、SingGuard 等直接近邻。
- 路线二不声称首次 pre-encoder、首次 text-guided 或首次 policy-aware pruning；Dyna-ViT、QuietPrune 和 SafeWatch 分别构成直接近邻。
- 所有方法效果、非劣性、漏洞普遍性和真实加速仍为待实验假设；本次未运行模型或生成实验结果。

