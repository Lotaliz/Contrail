---
id: change-2026-09-04-consolidate-visual-token-pruning-research
type: change
tags: [metadata, research, visual-token-pruning]
title: "合并多模态安全 Token 剪枝研究记录（Consolidated）"
date: 2026-09-04
change_type: Changed
---

# 合并多模态安全 Token 剪枝研究记录

- 将本轮会话涉及的结构重要性、MHA/MLP、代表性多模态方法、选择器时延、分辨率优先、DeepStack、离线校准、profile serving 与可解释性统一整理为一份自包含研究方案。
- 将项目主线收束为带空间—文本—政策 provenance 的 evidence-carrying token compression、unsafe-sufficiency/safe-coverage 非对称证据契约和 attribution-instability fallback。
- 删除 `research/visual-token-pruning` 下原有的专题综合、阅读日志和逐篇论文笔记，使目录只保留统一研究方案。
- 保留 `raw/sources.yaml` 与原始论文文件；它们仍是统一方案中来源 ID 和事实引用的证据层。
- 将 Wiki 首页、研究索引、标签索引、概念页、相邻研究页和实验页中指向已删除记录的链接统一改到新方案。
