---
id: multimodal-compositional-safety-research-plan
type: synthesis
title: "路线一：图文联合风险的攻击、测量与 Guard 防御"
tags: [research, multimodal-safety, safety-guardrail, safety-evaluation, safety-alignment]
project_id: multimodal-compositional-safety
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-singguard-team-2026-singguard, paper-chi-2024-llama-guard-vision, paper-liu-2025-guardreasoner-vl, paper-huang-2025-llavashield, paper-wang-2026-safeatlas-vl, webpage-usenix-security-2027-cfp-ml, webpage-ieee-sp-2027-cfp-compositional-safety, webpage-acm-ccs-2026-cfp-ml, webpage-ndss-2027-cfp-ml]
status: active
created: 2026-09-21
updated: 2026-09-21
---

# 路线一：图文联合风险的攻击、测量与 Guard 防御

## 论文命题

多模态内容安全系统即使能分别判断图片和文本，也可能在风险只由二者关系产生时失效。本文不再把“发现 `S-S-U`”作为创新，而是研究一个更具体的安全问题：**专业多模态 Guard 是否存在可系统复现、可穿透部署级联的组合式规避；能否以一个受约束的组合风险模块修复该漏洞，同时对现有显式风险和良性内容保持非劣。**

推荐的一句话题目是：

> We expose compositional evasion in multimodal guardrails with causally validated safe-safe-unsafe pairs, and mitigate it using a compatibility-preserving compositional risk adapter.

## 为什么值得做、为什么不是空白宣称

- SIUO 已直接定义安全图像与安全文本导致不安全输出；MSTS 同时发现任务模型有害输出和自动审核漏检；VLSU 用图像、文本、组合三标签证明部分联合错误不能归因于单模态误判。
- SingGuard 已构造 strict cross-modal attacks 并在自建切片上训练政策自适应 Guard。因此不能声称“首次数据集”“首次专门 Guard”或“首次图文联合安全”。
- 仍有空间的是：以同一政策和同一任务定义审计多种**专业 Guard**，通过配对反事实验证组合必要性，测量部署级联的真实逃逸，并用外部、生成器隔离的数据验证防御不依赖模板捷径。

## 威胁模型与安全属性

### 系统

在线多模态服务包含输入 Guard、任务 VLM 和可选输出 Guard。Guard 接收图像、用户文本和运行时政策；输入通过后，任务模型生成回答，回答可能再次审核。

### 攻击者

攻击者可选择自然或生成图像与文本，使每个模态在给定政策下单独安全，但联合后表达危险行动、歧视、违法意图或其他违规语义。攻击者可做释义、对象替换、关系重排和有限查询；主结果不依赖不可见像素扰动，也不把完整有害指令塞进 OCR 图像。

### 安全属性

在预先声明的政策、数据分布和 benign FPR 下，strict `S-S-U` 的漏报率不得超过目标界限；分布外或证据冲突样本应拒判或升级，而不是静默判 safe。这里的“防御不影响现有判别效果”必须写成统计上的**非劣约束**，而不是绝对零变化。

## 数据集：从样例集合变成攻击协议

### 三标签与必要性验证

每条样本标注：

$$
y_I=\mathrm{safe},\qquad y_T=\mathrm{safe},\qquad y_{I\oplus T}=\mathrm{unsafe}.
$$

此外至少包含一对同图换文和一对同文换图反事实，使组合标签翻转。人工审查分别回答：单模态是否真的安全、联合风险是否成立、政策条款是什么、最小关系证据是什么、样本是否自然。

### 构造轴

- 关系类型：实体—动作、对象—用途、指代、空间关系、时序后果、社会语境和政策例外。
- 风险类别：沿现有 Guard 政策建立，不新造无法对齐的私有 taxonomy。
- 数据来源：真实图片、授权合成图片、自然文本和控制生成文本分开登记。
- 难例：strict unsafe、benign-sensitive、borderline、显式单模态 unsafe 和普通 safe 共同组成测试集。
- 划分：按基础图片、文本模板、生成器、政策类别和语义场景 group-disjoint；禁止只做随机切分。

### 数据质量与滥用控制

报告标注一致性、淘汰率、图像许可、隐私处理、合成器版本和争议样本。公开版本可对高危操作细节做分级访问，但评测脚本、标签协议和无害复现实例应完整开放。

## 测量研究

### RQ1：专业 Guard 是否存在 strict 组合缺口

统一测试 image-only、text-only 与 joint，但不能把三者当成同一标签任务简单比较。主结果应在 joint strict unsafe 与匹配的显式 unsafe/benign 对照上报告：

- unsafe recall at fixed benign FPR；
- worst-group recall 与类别方差；
- paired counterfactual consistency；
- 校准和 selective risk；
- 组合错误中单模态都正确的比例。

### RQ2：错误是否穿透完整系统

分别报告输入 Guard 漏报、任务模型 harmful assistance、输出 Guard 漏报和完整级联逃逸。避免把回复审核结果误写成输入 Guard 的能力，也避免把模型拒答但没理解当成正确组合推理。

### RQ3：攻击是否可迁移与可适应

测试跨 Guard 迁移、跨政策释义、图像替换、关系重排、查询预算和针对防御重新构造的自适应样本。若漏洞只在单一模板或单一闭源 API 上成立，论文应降级为数据诊断。

## Guard 改进方案

### 最小可行方法

在冻结或低学习率更新的基础 Guard 上增加**组合风险残差模块**。它同时读取视觉 Token、用户文本 Token 和政策表示，输出只用于修正组合关系的 residual score。训练包含四部分：

1. strict joint classification loss；
2. 同图换文、同文换图的配对反事实一致性；
3. 对既有 Guard 数据的 logit/feature compatibility distillation；
4. 固定 FPR 或非劣约束下的校准损失。

核心不是新造一个 cross-attention，而是把残差模块限制为只解释“单模态安全、联合风险”的增量，并用因果配对证明它没有改学危险词或图片风格。

### 必须比较的防御

- 只增加 strict 数据的普通 SFT；
- 类别重加权、hard-negative mining 和温度校准；
- 标准 concat/pooling/cross-attention head；
- 完整 Guard 全量微调；
- 显式关系/政策推理 Guard；
- 候选 residual adapter 加或不加反事实、compatibility 和校准约束。

若普通 SFT 已达到相同外部泛化和非劣前沿，则复杂模块不应作为主贡献。

## “不影响现有判别”的验证标准

不能只比较平均 accuracy。建议预注册：

- 在至少两个既有安全基准上，以置信区间检验 macro/micro F1、AUPRC、unsafe recall 和 benign FPR 的非劣；
- 在显式单模态 unsafe、普通 safe、benign-sensitive 和政策例外四个子群分别报告；
- 在相同阈值与 matched-FPR 两种设置下比较，防止靠阈值移动制造“无损”；
- 报告最坏类别退化和校准变化；
- 将 strict 提升与 legacy 退化画成 Pareto 前沿。

非劣 margin 必须在看测试集之前根据部署风险或开发集确定，不能事后选择。

## 安全顶会写作结构

推荐标题方向：**When Safe Meets Safe: Measuring and Mitigating Compositional Evasion in Multimodal Guardrails**。

1. **Introduction：** 从部署流水线和一个最小反例切入；明确既有工作已发现现象，本文贡献是专业 Guard 测量、攻击协议和兼容防御。
2. **Threat Model：** 攻击者能力、单模态安全约束、政策边界、输入/输出 Guard 角色。
3. **Dataset and Audit Protocol：** 三标签、配对反事实、人工验证、group-disjoint split 和伦理。
4. **Measurement：** 多 Guard、多任务角色、组件与端到端结果；先证明漏洞普遍和可利用。
5. **Defense：** 组合风险残差模块与非劣训练；把模型设计放在已测量漏洞之后。
6. **Adaptive Evaluation：** 迁移、自适应攻击、外部 benchmark、部署阈值和失败案例。
7. **Limitations and Ethics：** policy ambiguity、文化差异、生成数据偏差、公开高危内容的控制。

安全顶会版本不要以“新模型在 benchmark 上 F1 更高”为摘要主句。USENIX Security 的当前指南尤其要求 systems-security relevance；CCS/NDSS/IEEE S&P 也会追问现实威胁模型、一般性和系统影响。

## 可行性、风险与停止条件

### 可行性判断

- **数据构造：高。** 已有 strict 数据和政策 taxonomy 可复用，但人工验证成本高。
- **漏洞复现：中高。** 现有证据支持存在性，但最新专业 Guard 上的普遍程度未知。
- **方法实现：高。** residual adapter、配对训练和 compatibility distillation 都可实现。
- **顶会创新：中高但结果依赖强。** 真正价值来自测量与防御闭环，不来自模块名称。

### Go

- 多个专业 Guard 家族在 group-disjoint strict 数据上重复出现显著漏报；
- 漏报能形成端到端系统风险，而非仅标签争议；
- 防御在外部 strict 数据上提升 fixed-FPR recall；
- legacy 基准达到预注册非劣，且自适应攻击后收益仍保留。

### Pivot

- 若漏洞成立但方法收益主要来自数据，转为 benchmark + measurement paper；
- 若 Guard 已很稳但任务模型仍失败，转向任务模型对齐而非 Guard；
- 若漏洞只出现在某一部署优化路径，改写为该路径的系统安全论文。

### No-Go

- strict 标签经人工审查后大量失效；
- 最新专业 Guard 未出现可重复差距；
- 提升只在同源合成测试集成立；
- 防御靠整体提高拒绝率或牺牲既有安全类别换取 strict recall。

