---
id: paper-note-wu-2024-legilimens
type: paper-note
title: "Legilimens: Practical and Unified Content Moderation for Large Language Model Services"
authors: ["Jialin Wu", "Jiangyi Deng", "Shengyuan Pang", "Yanjiao Chen", "Jiayang Xu", "Xinfeng Li", "Wenyuan Xu"]
year: 2024
venue: "ACM CCS 2024"
source_id: paper-wu-2024-legilimens
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# Legilimens: Practical and Unified Content Moderation for Large Language Model Services

## 研究问题与收录理由

论文研究如何为大语言模型服务提供统一、实用的输入与输出内容审核。它属于防御与审核系统，而非攻击方法；对本项目的价值在于展示“主模型之外配置轻量守卫”的服务化路径。

## 方法概览

Legilimens 从宿主聊天模型的内部表示中提取与安全概念相关的特征，并训练可复用的审核组件，同时覆盖用户输入和模型输出。系统将安全判别与生成主体解耦，并讨论普通及自适应攻击者下的鲁棒性。

## 主要实验与结论

作者在多种宿主 LLM、数据集和越狱方法上比较商业及学术基线，结论是该方法在有效性、效率和鲁棒性方面具有竞争力。论文也明确指出实验资源未覆盖 70B、175B 等更大模型，因此模型规模与审核效果的关系仍未解决。

## 局限与项目关联

该工作支持独立轻量 Guard 的系统设计，但不能直接证明任意压缩方法都能保持审核能力。不同论文对端到端时延、额外审核开销和生成时间的计量边界不同，不宜横向拼接其效率数字。

## 泛读结论

与轻量安全判别器和服务级部署高度相关，建议在需要复现其特征提取、训练成本或自适应攻击设置时再升级为精读。
