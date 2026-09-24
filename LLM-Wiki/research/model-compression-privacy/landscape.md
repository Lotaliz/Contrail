---
id: model-compression-privacy-mia-landscape
type: synthesis
title: 2025—2026 成员推断攻击研究版图
tags: [research, membership-inference]
project_id: model-compression-privacy
sources: [paper-li-2026-compleak, paper-du-2026-cmia-pmia, paper-lu-2026-icp-mia, paper-chen-2026-window-mia, paper-tong-2026-tokenizer-mia, paper-nguyen-2026-menta, paper-wang-2026-vidleaks, paper-zhang-2025-soft, paper-shang-2025-wemem, paper-li-2025-dhattack, paper-tan-2026-neural-activation-mia]
status: active
created: 2026-09-15
updated: 2026-09-15
---

# 2025—2026 成员推断攻击研究版图

## 综合判断

MIA 仍是 AI/ML 隐私研究的**主流子方向和经验隐私审计工具之一**，但不是 AI 系统隐私的同义词。它与训练数据提取、模型反演、属性推断、梯度泄露、提示/检索库泄露、差分隐私、机器遗忘和机密推理并列。

安全顶会中的信号包括：NDSS 2025 设置了以 membership inference 为主题的完整 session；2026 年的 USENIX Security 与 NDSS 又分别接收面向 LLM 微调、tokenizer、RAG、视频生成、模型压缩、开放权重激活和联邦学习的多篇 MIA 工作。研究重心已从“证明分类器会泄露”迁移到**真实访问约束、低 FPR、系统组件和生命周期特定攻击面**。

## 方法机制

### 1. 更现实的访问约束

- [DHAttack](https://www.usenix.org/conference/usenixsecurity25/presentation/li-hao)：只返回标签，5–30 次查询，利用样本特定决策边界距离。
- MEntA：无 surrogate、五次自然语言查询，面向 RAG 检索语料成员身份。
- ICP-MIA：训练自由的黑盒 in-context probing，估计微调后的 optimization gap。

趋势是减少影子模型、完整 posterior 和大量查询依赖；这些正是 CompLeak 当前威胁模型较强的地方。

### 2. 从全局分数转向局部或条件化信号

- WBC：不再平均整段 loss，而是在多尺度滑窗上比较局部记忆信号。
- CMIA/PMIA：建模多个查询样本之间的 membership dependency，或用行为相似的代理样本估计 posterior odds。
- 开放权重 LLM MIA：利用跨层神经元激活，而非仅看输出概率。

趋势是针对传统 loss/confidence 分数的难度混淆、稀释和分布偏移问题，寻找条件化、局部化或内部表示信号。

### 3. 攻击面从模型扩展到系统生命周期

- Tokenizer MIA：把 tokenizer 训练语料本身作为泄露面。
- MEntA：攻击 RAG 检索库的文档 membership。
- VidLeaks：结合稀疏关键帧重构和多次生成的时间稳定性。
- CompLeak：利用原模型与多个压缩版本形成的相关视图。

这类论文的前沿价值更多来自**新系统对象和新的可观察信号**，而不是提出一个能统一支配所有任务的 MIA。

### 4. 防御从通用正则转向流程特定干预

- SOFT：在 LLM 微调时选择高影响数据并做可调数据混淆。
- WeMem：针对迭代剪枝中的数据复用和样本固有可记忆性抑制 memorization。
- 差分隐私仍是提供形式化保证的主要路线；MIA 则用于经验审计，但攻击失败不能证明不存在隐私泄露。

## 判断边界

MIA 在大规模预训练 LLM 上仍面临成员标签不可靠、成员/非成员分布偏移、训练轮数少和模型规模失配。因此，“MIA 是主流”表示问题、方法和审计用途持续活跃，并不意味着现有攻击能在所有现代基础模型上可靠工作。
