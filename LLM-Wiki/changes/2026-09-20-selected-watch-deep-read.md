---
id: change-2026-09-20-selected-watch-deep-read
type: change
title: "精读近期追踪中选定的五篇论文"
tags: [change, research, visual-token-pruning, source]
date: 2026-09-20
change_type: Added
status: active
---

# 变更说明

用户将近期追踪索引中的五篇候选标记为 `selected`，本轮将其升级为 deep-read / source-checked：G2TM、StepPrune、VIP-Router、AdaVSkip 与 VLM 图表读数因果定位。

## 新增

- 五份 `research/visual-token-pruning/papers/` 精读笔记。
- 五份 arXiv v1 PDF 原件，保存于 `raw/papers/`，并登记 SHA256 与原始许可。

## 修改

- 更新 `raw/sources.yaml` 的本地路径、哈希、许可、阅读状态和笔记链接。
- 将候选索引中五项从 `selected` 改为 `ingested`，保留原始发现与筛选记录。
- 更新项目入口与 reading-log；正式 motivation、研究主方案、实验结果和既有 StackTok 笔记未修改。

## 证据边界

所有方法与数字均来自作者 PDF，未运行代码或模型，verification 为 `source-checked`，不是 `reproduced`。AdaVSkip v1 PDF 未包含正文所指的 profiling 附录，训练配置和计时协议存在缺口；VIP-Router 尚无可固定的公开代码；其余代码也未在本轮审查。
