---
id: note-2026-song-policyshiftguard
type: paper-note
title: "PolicyShiftGuard: Benchmarking and Improving Policy-Adaptive Image Guardrails"
authors: [Mingyang Song, Luxin Xu, Haoyu Sun, Minzhou Pan, Yu Cheng, Bo Li]
year: 2026
venue: arXiv
source_id: paper-song-2026-policyshiftguard
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, safety-guardrail, multimodal-safety, safety-evaluation, vision-language-model]
status: active
created: 2026-09-22
updated: 2026-09-24
---

# PolicyShiftGuard：同图政策翻转与边界配对训练

来源：[arXiv 原文](https://arxiv.org/html/2607.05910)与[官方项目页](https://policyshiftguard.github.io/)。精读正文 §1–7、表 1–6、图 1–5，以及附录 A–G 中政策目录、PSS、实现和质量审计；另核对官方 GitHub、Hugging Face 模型卡、文件列表和数据卡，未下载权重/数据或本地复现。

## 更严格的问题定义

论文将 policy-adaptive image guardrail 定义为：给定同一视觉证据，模型必须依据当前运行时 policy bundle 改变 pass/block 判定，而不是把“危险”视为图像固有属性。

设图像在类别 $c$ 上的原子属性为 $A_c(x)$，类别政策为规则 $f_{c,p}$，则类别决策为：

$$
z_{c,p}(x)=f_{c,p}(A_c(x)).
$$

运行时 bundle 为每个类别选择一条政策；图像只要违反任意激活政策即 block：

$$
y(x,\mathcal{B})=\mathbf{1}\{\exists c:f_{c,p_c}(A_c(x))=1\}.
$$

这把任务分成“图像里有什么”和“当前规则如何处置”两层，并允许固定图像、只改变政策得到严格反事实。

## PolicyShiftBench 如何构造

七个风险类别覆盖裸露/性内容，暴力/仇恨/恐怖主义/自残，受管制物品，IP/品牌，文化宗教敏感，隐私/PII，以及图中文字安全。五类现实场景包括主流社交平台、家庭保护、医疗教育、新闻、游戏或地区文化等；类别与场景的有效交叉形成 28 个评测政策变体。

数据构造不是直接让模型标 safe/unsafe，而是：

1. 为每类定义可观察的原子属性，包括触发条件和医疗、艺术、新闻等豁免；
2. 三个多模态标注器分别输出属性，字段级多数投票；
3. 对投票属性执行显式政策规则，确定类别标签与最终 OR 标签；
4. 优先采样同图、同类别、换政策后标签翻转的实例，同时保留始终安全/危险锚点。

最终评测集 2,000 个实例、265 张图、28 个政策，平均每图 7.55 个政策条件 prompt；262/265 张图同时存在 pass 和 block 标签。Adaptive split 使用训练见过的政策家族，Shift split 使用 12 个 held-out 政策定义。训练语料 9,816 条、2,945 张训练图，包括 3,000 条 RP-SFT、3,000 条 reasoning 诊断数据和 3,816 条 BP-Adapt 边界对。

质量控制中，475,569 个字段决策有 97.5% 三标注器一致；论文另报 Adaptive/Shift 的盲人类准确率 88%/90% 和两个 split 95% qualified rate。高模型一致率不等于人工真值；其独立人审和可执行规则提高了可审计性，但属性遗漏仍会系统性传入所有标签。

## 训练方法

### Stage 1：Randomized Policy SFT

每个样本输入图像和七类政策 bundle，输出短结构化结果 `false` 或 `true | category`。训练随机打乱政策顺序、表面标识和类别槽位，并同步转换目标类别 ID，迫使模型读政策语义而非记忆固定位置。

RP-SFT 提高输出接口可靠性并减少模板捷径，但作者消融显示随机化本身不保证 held-out policy sensitivity；7B 的 Shift PSS 甚至比普通 SFT 低 9.7 点。

### Stage 2：Boundary-Pair Policy Adaptation

核心训练单元固定同一图像和视觉证据，只切换目标类别政策：

$$
q^+=(x,\mathcal{B}^+)\rightarrow\texttt{true}\mid c,
\qquad
q^-=(x,\mathcal{B}^-)\rightarrow\texttt{false}.
$$

总损失由 answer CE、标签分离、类别稳定项和 pair margin 构成。关键 pair loss 强制 blocking policy 的 unsafe score 高于 permitting policy：

$$
\mathcal{L}_{pair}=max\left(0,m-[s_\theta(\texttt{true}\mid q^+)-s_\theta(\texttt{true}\mid q^-)]\right).
$$

因此它不是“再加一些政策数据”，而是直接优化同图政策边界。表 6 中移除 pair loss 后，3B/7B Avg. F1 分别下降 10.6/17.7 点，支持配对结构而非数据量本身是主要因素。

## 评测指标：Policy Shift Score

PSS 先按 `(same image, same target category)` 分组，只保留 gold label 不同的政策对。一对样本只有 pass 侧和 block 侧都预测正确才计分，最后在组间宏平均。这比单样本 accuracy/F1 更严格：一个始终拦截危险图像的模型可以有可观 F1，却无法获得 policy flip 得分。

该指标仍只测二元翻转，不包含 fixed-FPR 校准、违规严重度、政策冲突优先级或压缩后条款遗漏；当前课题需要在 PSS 外增加这些指标。

## 主要证据

- PolicyShiftGuard-7B：作者报告 Adaptive F1/PSS 86.8/73.8，Shift F1/PSS 67.0/70.4，平均 F1/PSS 76.9/72.1。
- SafeGuard-VL-RL-7B：平均 F1 51.0，但 PSS 4.0；GuardReasoner-VL-3B 平均 F1 59.2，PSS 3.2。该差距证明普通风险识别不等于政策敏感。
- 跨 benchmark：PolicyShiftGuard-7B 在 UnSafeBench、SafeEditBench、Adaptive、Shift 的 F1 分别为 64.1、61.7、86.8、67.0。
- concise no-think 训练在 3B/7B 两阶段均优于 reasoning 版本；输出通常不超过五个 token，作者报告同 7B 基座时延从 273.3 ms 降至 163.9 ms。计时改善混合了训练和输出长度变化，不能归因为 token pruning。

以上均为作者报告，未本地复现。

## 局限与证据边界

作者明确限制为静态图像、显式英文政策和结构化 moderation policy style；不覆盖视频、多轮、网页、跨语言、法律文档式或长用户自定义政策。政策目录虽含 held-out split，仍来自同一属性/规则 schema 和有限 28 个变体。

属性—规则分离使标签可审计，也可能产生 closed-world 偏差：模型只需覆盖预定义属性和政策模板；现实中未建模的属性、模糊规则和跨条款冲突不在任务内。多数属性由 VLM 投票获得，可能有相关错误。PSS 不评估概率校准或部署安全代价。

## 公开模型、代码和数据

官方公开了四个直接可加载的检查点：最终 [PolicyShiftGuard-3B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-3B) 与 [PolicyShiftGuard-7B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-7B)，以及各自的 RP-SFT 中间检查点。3B 名称对应 Qwen2.5-VL-3B-Instruct 基座，但 Hugging Face 对完整多模态模型计为约 4B 参数，BF16 仓库约 7.53 GB；7B 版本计为约 8B。对当前压缩课题，3B 最适合作为首个开发基座，7B 更适合作为 teacher/尺度验证。

[PolicyShiftBench 公共包](https://huggingface.co/datasets/PolicyShiftGuard/PolicyShiftBench)包含 RP-SFT、reasoning SFT、BP-Adapt boundary pairs、Adaptive/Shift 评测、boundary group 元数据、可执行政策规则和政策释义，足以避免重新采集或人工标注主数据。许可标签为 `other`，数据卡限制为非商业研究、评审和复现，使用及再发布前必须遵循 `LICENSE` 与 `TERMS.md`。

[官方代码](https://github.com/ssmisya/PolicyShiftGuard)公开了评测、生成式 SFT、冻结 VLM 分类器基线、RL 数据准备/reward、数据整理和验证工具，复现指南直接示范 Qwen2.5-VL-3B。方法监督在概念上可迁移到其他能接收图像与政策并输出结构化 verdict 的 VLM，但官方结果和训练路径没有证明跨架构零修改复用；更换架构至少需要适配 processor、视觉 token 接口、prompt/parser 并重新微调。

## 对当前课题的启发

这篇更适合作为主任务定义：压缩 Guard 必须保持同图 policy flip，而不仅是平均 F1。其可执行条款和属性 schema 可作为 policy compiler 的教师信号；BP-Adapt 可直接改造成“full policy vs compressed policy”边界保持损失。但论文明确不覆盖长用户政策，因此不能用其结果证明长政策压缩已经解决。

关联：[[LLM-Wiki/research/visual-token-pruning/papers/2026-piao-safeguard-vl.md|SafeGuard-VL]]；[[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|两篇比较]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。
