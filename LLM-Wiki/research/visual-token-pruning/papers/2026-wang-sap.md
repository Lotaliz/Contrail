---
id: note-2026-wang-sap
type: paper-note
title: "Understanding and Mitigating Token-Pruning-Induced Vulnerabilities in VLMs"
tags: [paper-note, research, visual-token-pruning, multimodal-safety, jailbreak-defense, safety-evaluation, efficient-inference]
source_id: paper-wang-2026-sap
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-09-08
---

# Understanding and Mitigating Token-Pruning-Induced Vulnerabilities in VLMs

来源：[作者官方代码仓库与论文说明](https://github.com/liongliong/SAP)；仓库标注 ICML 2026；本轮阅读公开摘要、机制和结果说明，未获得论文正文链接、未运行代码。

## 方法与直接证据

作者研究多模态 jailbreak 下 token pruning 对生成模型安全性的影响，提出 Pruning-Induced Malicious Amplification：背景 token 被移除后，注意力可能集中到少量恶意前景锚点。推理期 SAP 识别恶意锚点、恢复部分良性 token 并重分配注意力。官方仓库称覆盖五种剪枝方法、三项安全和四项 utility benchmark，并报告攻击成功率最高下降 62%。

## 与本课题的边界

“安全感知 token 剪枝”与“压缩导致特有安全行为”已经有更直接先例，故安全分支不能只做一次攻击迁移或按危险性改 score。SAP 面向被保护生成模型的 jailbreak/拒答，且是推理期修复；本课题可保留的空白是独立 Guard 检测、输入分辨率与视觉深度共同压缩、固定 FPR 下的漏报，以及训练后跨未知压缩状态的泛化。会议状态暂仅依据作者官方仓库登记。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/gaps.md]]。

