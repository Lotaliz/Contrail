---
id: note-2026-piao-safeguard-vl
type: paper-note
title: "Towards Policy-Adaptive Image Guardrail: Benchmark and Method"
authors: [Caiyong Piao, Zhiyuan Yan, Haoming Xu, Yunzhen Zhao, Kaiqing Lin, Feiyang Xu, Shuigeng Zhou]
year: 2026
venue: CVPR 2026
source_id: paper-piao-2026-policy-adaptive-image-guardrail
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

# SafeEditBench / SafeGuard-VL：跨政策泛化与能力保持

来源：[CVPR 2026 官方论文](https://openaccess.thecvf.com/content/CVPR2026/papers/Piao_Towards_Policy-Adaptive_Image_Guardrail_Benchmark_and_Method_CVPR_2026_paper.pdf)与 [arXiv v2 HTML](https://arxiv.org/html/2603.01228)。精读正文 §1–5、表 1–6、图 1–7，以及补充材料的政策定义与相关实现说明；另核对官方 GitHub、Hugging Face 模型卡、文件列表和数据卡，未下载权重/数据或本地复现。

## 问题定义

论文把 harmful-image guardrail 从固定映射 $y=g(I)$ 改为条件映射 $y=g(I,P)$：safe/unsafe 不是图像的固有属性，而由运行时自然语言政策 $P$ 决定。同一图像在不同政策下可以改变标签。作者重点关注两个失败：

1. 固定 taxonomy 分类器遇到新类别或政策改变需要重训；
2. 现有 VLM Guard 经单一政策 SFT 后会过拟合训练模板和政策分布，跨政策下降，并可能损失一般 instruction-following 与 VQA 能力。

这里的“policy-adaptive”主要指：**在未见或变化的政策文本下仍能做合理判定，同时保持通用多模态能力**。论文通过五个全局政策等级测 cross-policy generalization，但没有专门的成对 policy-flip 指标。

## SafeEditBench 如何构造问题

基准从 LlavaGuard 测试集出发，用图像编辑模型对 unsafe 图像做局部、语义保持的安全化编辑，例如把武器改成相机。目标是保持场景、构图和大部分物体不变，只改变违规局部，减少模型依赖粗粒度场景先验。

同一批图像在五个自然语言政策 L1–L5 下重新标注：L1 极宽松，L5 极严格，L3/L4 更接近常见社会规范。政策不仅改变阈值，也改变允许情境和类别定义。正文 §3.1 写 128 张图像，§3.2/图 4 写五个政策统一作用于 62 组图像对；两处口径约有 4 张图像差异，需以数据发布进一步核对。

每个实例为 `(image, textual policy, safe/unsafe label)`。每个政策分别计算二分类 F1；L1 因全部图像为 safe 而改用 accuracy；最终对五个政策的数值做宏平均。因此总指标混合了 F1 和一个退化全负类设置的 accuracy，且没有要求同一图像在一对政策下两侧都预测正确。

## SafeGuard-VL 如何解决

### Stage 1：有害语义 SFT

作者不先训练 safe/unsafe 分类，而让 Qwen2.5-VL 学会明确描述有害视觉内容。约 100K 网络图像先由基座模型生成可能“淡化风险”的 caption，再由 Gemma-27B 做最小 recaption，补回被拒答机制省略的有害细节，同时尽量保持原句结构和中性事实。

这一阶段试图学习政策判定之前的视觉语义 $h(I)$，避免分类标签把感知与规范混在一起。风险是 recaption 的精确性和有害细节由教师模型生成；论文通过下游消融支持其有用，但未证明 caption 对每个局部事实完全忠实。

### Stage 2：Policy-aware RLVR

模型再接受 `(image, policy)`，用 GRPO 做政策条件安全判定。LlavaGuard 训练数据被重用为 policy-conditioned RL 数据；ground-truth safe/unsafe 是可验证奖励，模型同时被鼓励根据政策解释判定。作者的核心直觉是 RL 在模型自己的采样分布上优化，比固定答案 SFT 更不容易锁死在单一模板或政策上。

方法概念上把**有害语义理解**与**规范性安全判定**分开：先学图像里有什么，再学当前政策是否允许。论文没有验证生成解释是否忠实，也没有把政策解析成显式条款或可执行逻辑。

## 实验证据

- UnsafeBench：SafeGuard-VL-Full 作者报告 overall 72.2，SFT-only 为 67.0；加入 RL 相比 SFT 提高约 5.2 点。一般能力平均值在所列变体间约 53.1–56.9。
- 单政策训练、跨五政策测试：极端政策 SFT 会退化。例如 L1 SFT 在其他四个政策上为 0；RL 缓解但并未消除跨政策依赖。
- SafeEditBench 表 6：Qwen2.5-VL-7B 为 48.68，SafeGuard-VL-RL 为 45.59，加入 SafeEditTrain 后为 49.43。即作者的 edited-pair 训练比其原始 RL 提高，但相对未专门训练基座只小幅超过；该表不支持“跨政策问题已被充分解决”。
- LlavaGuardBench 与通用任务：QwenGuard-7B 在自有 benchmark 高，但跨安全和通用任务下降；SafeGuard-VL-RL 更均衡。这更有力地支持“减少过专门化/灾难性能力损失”，而不是严格 same-image policy flip 能力。

以上均为作者报告，未本地复现。

## 实际解决了什么、没有解决什么

**较可信地解决：** 建立首批 vision-centric cross-policy 近邻评测；展示单政策 SFT 的过拟合；用语义 SFT + RL 提高外部安全集和一般能力的平衡。

**证据较弱或未解决：**

- 缺少 paired flip 指标，模型可能仍按“图像看起来危险”作答；
- 五个全局严格度政策不能覆盖真实平台中按类别、地区和例外组合的复杂 policy bundle；
- L1 全 safe，容易测试输出先验而非细粒度政策推理；
- policy reward 主要来自最终标签，生成 rationale 的因果忠实性未验证；
- 没有研究长政策 token 成本、政策压缩、缓存或视觉—政策联合预算。

## 公开模型、代码和数据

[官方代码](https://github.com/adorableChowhound/SafeGuard-VL)公开了推理、SafeEditBench/UnsafeBench 评测、self-recaption、图像编辑、ms-swift SFT 和 GRPO 脚本。可直接加载的 [SafeGuard-VL-RL](https://huggingface.co/tyodd/SafeGuard-VL-RL)是 Qwen2.5-VL-7B-Instruct 级完整 BF16 权重，仓库文件约 16.6 GB；它不是轻量模型。Hugging Face 页面显示的 `849k params` 与基座名称及四个总计约 16.6 GB 的权重分片矛盾，不作为可信规模。

更重要的是，模型卡明确说明公开权重只做了 Stage-2 GRPO，**没有 Stage-1 SFT**。因此它是论文中 `SafeGuard-VL-RL` 的可用基线，不等于完整 `SafeGuard-VL-Full`。若要复现完整两阶段功能，需要使用公开 recaption/SFT 管线自行构造或取得 Stage-1 数据并训练。

[SafeEditBench 数据卡](https://huggingface.co/datasets/tyodd/SafeEditBench)列出 901 张训练图、128 张测试图、601 个 policy-conditioned 测试实例以及五个完整政策文本，许可为 CC BY 4.0，但访问文件前需同意研究用途条件。它足以支持现成评测和有限训练，不等于论文 Stage-1 约 100K recaption 语料。

PolicyShiftGuard 后续在更严格的 PSS 上报告 SafeGuard-VL-RL-7B 的 Avg. F1 为 51.0、Avg. PSS 仅 4.0，直接说明普通跨数据 F1 与真正的政策翻转敏感性不是同一能力。

## 对当前课题的启发

SafeEditBench 适合作为外部近邻视觉证据测试；Stage 1 的“先感知、后政策判断”可迁移为 full-token teacher。主评测不能只采用其宏 F1，应加入 PolicyShiftGuard 式同图 policy flip、fixed-FPR unsafe recall 和完整政策/压缩政策判定一致性。

关联：[[LLM-Wiki/research/visual-token-pruning/papers/2026-song-policyshiftguard.md|PolicyShiftGuard]]；[[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|两篇比较]]；[[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|当前研究计划]]。
