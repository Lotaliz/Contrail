---
id: paper-note-zhang-2026-bleeding-pathways
type: paper-note
title: "Bleeding Pathways: Vanishing Discriminability in LLM Hidden States Fuels Jailbreak Attacks"
authors: ["Yingjie Zhang", "Tong Liu", "Zhe Zhao", "Guozhu Meng", "Kai Chen"]
year: 2026
venue: "NDSS 2026"
source_id: paper-zhang-2026-bleeding-pathways
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, jailbreak-defense, representation-probing, safety-evaluation]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-26
---

# Bleeding Pathways: Vanishing Discriminability in LLM Hidden States Fuels Jailbreak Attacks

## 研究问题与收录理由

论文研究安全与有害表示在生成过程中逐渐失去可分性，如何使越狱内容穿透仅在输入阶段判别的防线。它把安全监测从“请求前一次分类”扩展到生成中的连续判断。

## 方法概览

作者分析逐 Token 生成期间的隐藏状态轨迹，并提出 DEEPALIGN：在生成中段保持安全/有害表示的对比可分性，同时连续检测毒性并进行表示引导，从而兼顾意图消歧和过度拒答控制。

## 主要实验与结论

论文在 9 类攻击上报告接近零或较低的攻击成功率，标准任务性能下降小于 1%，过度拒答错误最多降低 3.5%。核心观察是，仅在输入时可分并不保证后续生成阶段仍保持安全边界。

## 局限与项目关联

方法需要白盒隐藏状态并改变训练或生成过程，其结果不能直接迁移到 API 模型。系统评估应分别测量首次安全判定时间、持续监控开销和完整生成时延，不能只报告最终吞吐。

## 泛读结论

与生成中动态 Guard 密切相关；若后续实现早停或逐 Token 剪枝，应升级精读。
