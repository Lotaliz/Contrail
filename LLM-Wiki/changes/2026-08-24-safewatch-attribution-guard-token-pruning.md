---
id: change-2026-08-24-safewatch-attribution-guard-token-pruning
type: change
tags: [research, method]
date: 2026-08-24
change_type: content
title: 调研可生成归因的多模态 Guard Token 剪枝
---

# 调研可生成归因的多模态 Guard Token 剪枝

## 新增证据

- 登记并深读 ICLR 2025 SafeWatch，保存正式论文 PDF 与 SHA256。
- 确认 policy-aware visual-token pruning 已被直接用于会生成多标签安全判定和自然语言解释的视频 Guard。
- 记录关键效率边界：作者报告最高剪除 90% 视频 token 时平均性能下降小于 1%；同底座 SFT 的平均时延为 4.6 s，完整系统为 3.9 s，但极高剪枝率会明显损伤准确率和解释评分。

## 综合判断

- 将“多模态安全 Guard 能否使用视觉 Token 剪枝”从纯候选假设更新为有直接安全实验支持、但只在视频与特定训练方案下成立的方向。
- 区分自然语言解释质量与证据归因忠实度；当前论文没有建立保留 token、区域/帧证据与解释文本之间的因果链。
- 建议分离判定预算与归因预算，并引入 policy relevance、时空 coverage、保护配额、风险自适应预算和可逆回退。

## 结构影响

- 新增 SafeWatch 论文笔记和“可生成归因的多模态自回归 Guard Token 剪枝”专题综合。
- 更新安全判别压缩项目的 overview、reading log、landscape、comparison、gaps、motivation 与 hypotheses。
- 更新来源注册表与 CHANGELOG。

