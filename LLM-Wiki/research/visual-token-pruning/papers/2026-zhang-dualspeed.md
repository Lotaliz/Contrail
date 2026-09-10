---
id: note-2026-zhang-dualspeed
type: paper-note
title: "Fast-Slow Efficient Training for Multimodal Large Language Models via Visual Token Pruning"
tags: [paper-note, research, vision-language-model, visual-token-pruning, knowledge-distillation]
source_id: paper-zhang-2026-dualspeed
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Fast-Slow Efficient Training for Multimodal Large Language Models via Visual Token Pruning

来源：[原文](https://arxiv.org/abs/2602.03815)；阅读版本：2602.03815v1。

## 原文事实
阅读摘要、引言、图 3、§3–4、主表与结论。fast-mode 主要用剪枝输入并加 mode isolator；slow-mode 用完整输入，接受 fast 分支自蒸馏。主要解决压缩训练→完整推理失配，方向与 full→compressed 蒸馏不同。表 1 使用 90% 剪枝设置；图 4 报训练墙钟时间，不能当推理加速。

## 边界与研究判断
“剪后模型在 full-path 自动更可靠”不成立；回退分支也须训练与校准。mode isolator 不等于完全无输入协议变化。代码：[DualSpeed](https://github.com/dingkun-zhang/DualSpeed)，未复现。待升级：隔离 token 细节及跨预算参数共享干扰；作为完整路径回归基线，不作安全召回证据。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。来源事实与“研究判断”分开；未通过本地实验验证。

