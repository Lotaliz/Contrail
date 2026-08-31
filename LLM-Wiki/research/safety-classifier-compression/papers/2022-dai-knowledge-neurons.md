---
id: paper-note-dai-2022-knowledge-neurons
type: paper-note
title: "Knowledge Neurons in Pretrained Transformers"
authors: ["Damai Dai", "Li Dong", "Yaru Hao", "Zhifang Sui", "Baobao Chang", "Furu Wei"]
year: 2022
venue: "ACL 2022"
source_id: paper-dai-2022-knowledge-neurons
project: safety-classifier-compression
reading_level: skimmed
verification: source-checked
relevance: medium
priority: medium
tags: [paper-note, research, representation-probing]
status: active
related: []
created: 2026-08-31
updated: 2026-08-31
---

# Knowledge Neurons in Pretrained Transformers

## 核心发现

论文在 BERT 填空式事实召回上用 attribution 找到与特定事实表达相关的 FFN 神经元；这些神经元的激活与事实表达正相关，并通过定向修改探索事实更新和擦除。

## 对本课题的边界

该工作加强了“某些 MLP 神经元承载任务相关知识”的证据，也说明按幅值无差别删除神经元可能伤害稀有概念。结果局限于 BERT 事实知识和案例研究，不能直接外推到现代 LLM、视觉语言融合或安全政策知识。

## 证据位置

- 摘要；knowledge attribution 方法；知识编辑案例。
