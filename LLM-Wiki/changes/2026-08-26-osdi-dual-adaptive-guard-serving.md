---
id: change-2026-08-26-osdi-dual-adaptive-guard-serving
type: change
title: OSDI 双自适应多模态 Guard Serving 调研
tags: [metadata, research, model-serving]
date: 2026-08-26
change_type: Changed
---

# OSDI 双自适应多模态 Guard Serving 调研

## 范围

在现有 `research/visual-token-pruning` 项目内补充 OSDI/SOSP/NSDI/ICML 的动态网络执行、请求级主干自适应、连续批处理与 SLO-aware serving 文献，不新建 research 项目。

## 主要变化

- 登记并泛读 Orca、Brainstorm、Deja Vu、Sarathi-Serve、Apparate、PowerInfer、SuperServe、PuDDing 八篇来源。
- 新增八份论文笔记，并在 reading log 中记录检索范围、纳入/排除标准和覆盖限制。
- 更新 overview、landscape、comparison、gaps、motivation、hypotheses 与 multimodal survey。
- 将课题从三个独立模块重构为：风险与 SLO 约束下，联合选择 Token/主干二维 profile，并解决 execution-signature-aware batching、在线审计与安全回退。
- 更新受控技术标签，新增 `model-serving`、`continuous-batching`、`slo-aware-serving`、`dynamic-sparsity`、`early-exit`。

## 证据边界与待人工决策

- 八篇新增论文均为 `skimmed/source-checked`，未在本地复现实验；论文数字不用于预测当前 Guard 系统收益。
- “Token 与主干质量面非可分”“连续 profile 导致 batch 净收益转负”“风险分层审计足够”仍是待验证假设。
- 需要在实现前决定 Guard 是短标签分类器还是自回归解释模型；两者的 batch、KV 与 TTFT/TPOT 目标明显不同。
- 需要选择主干自适应粒度：整层 omission、early exit、head/FFN block 或 neuron sparsity；不同选择会改变系统实现体量与 OSDI 新颖性。
