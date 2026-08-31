---
id: paper-note-zhong-2025-blockpruner
type: paper-note
title: "BlockPruner: Fine-grained Pruning for Large Language Models"
authors: ["Longguang Zhong", "Fanqi Wan", "Ruijun Chen", "Xiaojun Quan", "Liangzhi Li"]
year: 2025
venue: "Findings of ACL 2025"
source_id: paper-zhong-2025-blockpruner
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, structured-pruning, model-compression, training-free]
status: active
related: []
created: 2026-08-27
updated: 2026-08-31
---

# BlockPruner

## 核心方法

把每个 Transformer 层拆成 MHA 与 MLP 两个最小残差块；逐个 mask 后在校准数据上计算新模型 PPL，以 PPL 作为块重要性，并迭代删除当前最低重要块、重新估计余下块。

## 对本课题的证据与边界

“真实删除—重新前向—迭代重排”能显式捕获残差块间交互，优于一次性静态打分；但 PPL 衡量生成分布，不保证与安全判别边界、固定 FPR 或长尾类别一致。对专用 Guard，应该保留其迭代消融框架，替换目标函数，而不是只替换最终验收指标。

论文的 Llama2-7B/13B 分模块实验还给出一个有条件的敏感性结论：参数剪枝率低于约 17% 时，只剪 MHA blocks 的性能损失小于只剪 MLP blocks，混合搜索也倾向先删除 MHA；超过该区间后继续剪 MHA 会出现陡降。该结果说明低预算区间存在较多 MHA 块冗余，但不能外推成跨架构、跨任务或高剪枝率下的统一排序。

## 证据位置

- 最小残差块与 PPL 重要性：§3.1–3.2。
- 迭代剪枝：§3.3。
- PPL 与 Block Influence 比较：Appendix D。
- MHA/MLP 单独剪枝与已删块组成：§5.2，Figures 4–5。
