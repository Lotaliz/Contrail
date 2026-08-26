---
id: paper-note-qu-2025-vlm-unsafe-concepts
type: paper-note
title: "Bridging the Gap in Vision Language Models in Identifying Unsafe Concepts Across Modalities"
authors: ["Yiting Qu", "Michael Backes", "Yang Zhang"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-qu-2025-vlm-unsafe-concepts
project: ai-safety-systems-security-venues
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method, data]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# Bridging the Gap in Vision Language Models in Identifying Unsafe Concepts Across Modalities

## 书目信息与精读范围

- 会议：USENIX Security 2025，pp. 957–976。
- 原文：[[LLM-Wiki/raw/papers/2025-qu-vlm-unsafe-concepts.pdf]]。
- 精读范围：数据集构建、感知/对齐测量、情境分析、PPO 方法、全部主表、消融、局限与伦理说明。

## 研究问题与场景

### 两个研究问题

1. VLM 能否识别图像中各种不安全概念？当同一概念以图像或文本呈现时，安全判断是否存在稳定的模态差距？
2. 若差距存在，如何提升视觉不安全概念的安全对齐，同时尽量保持 VLM 的通用能力？（§1）

### 研究场景

- **社交平台/社区内容审核**：判断一张图是否适合在社交媒体或在线论坛展示。
- **生成式 AI 输入审核**：判断某类图像是否适合由 AI 生成或向一般受众展示。
- **同义跨模态输入**：同一不安全概念（如自伤、仇恨符号、骚扰）用图像呈现时被判安全、用文字描述时被判不安全。
- **情境化政策判断**：区分“用于宣传极端主义”与“用于历史纪录片”等不安全/安全使用语境。
- **训练时白盒修复**：对可微调的开源 VLM 做视觉安全对齐；不直接适用于只能调用 API 的闭源模型。

## 主要创新点与贡献

1. **UnsafeConcepts 细粒度数据集。** 从 UnsafeBench 出发，建立 9 类、75 个具体不安全概念与 1,567 张图像的映射，不再只有 safe/unsafe 二元标签（§3、Fig. 2–3、Appendix Table 6）。
2. **将“看到什么”与“如何作安全判断”拆开。** 感知测量问图像对应哪个不安全概念；对齐测量问该视觉/文本概念在一般安全语境中是否安全。该分解避免把视觉识别错误与伦理判断错误混为一谈（§4.1–4.2）。
3. **系统测量跨模态安全差距。** 对 6 个家族、8 个 VLM 同时测试视觉与文本概念，并补充特定安全/不安全情境，发现视觉安全判断系统性弱于文本判断，且一般语境下差距最大（Fig. 4–6、Table 2）。
4. **用简化 PPO 修复视觉对齐。** 直接用 RoBERTa 响应分类器和标签计算奖励，不收集人类偏好响应、不训练新 reward model，也不以 SFT checkpoint 初始化；奖励同时加入长度 bonus、熵和 KL 约束（§5.2–5.3）。
5. **把安全、解释质量和通用能力一起评估。** 除 alignment accuracy，还报告 `1-SelfBLEU`、人工 Soundness/Informativeness、MME、LLaVABench 和两个域外安全集，展示 SFT 高准确但模板化和能力退化的权衡（Table 3–5）。

## UnsafeConcepts 数据集

### 构建流程

- 从 OpenAI 内容政策和相关研究的重叠部分选取 9 类：Hate、Harassment、Violence、Self-Harm、Sexual、Shocking、Illegal Activity、Deception、Health/Substance Abuse；排除强情境依赖的类别（§3）。
- 将 UnsafeBench 类别定义拆为 75 个非重复概念；用 CLIP-ViT-L/14 文本—图像余弦相似度为每个概念检索前 50 张候选，共 3,750 张（§3、Fig. 2）。
- 3 位内部专家判断图像是否准确呈现目标概念，多数票决；Fleiss’ κ=0.682。最终保留 1,567 张，单个概念有 1–50 张图（§3）。
- 数据集把“是否呈现特定概念”作为相对客观的标注任务，但后续“是否安全”仍依赖统一伦理标准与情境假设。

### 数据贡献的边界

- 作者称其为当时最全面的细粒度不安全图像概念集合；该主张限于论文比较范围。
- 75 个概念和 1,567 张图像不足以代表开放世界、跨文化、跨语言或组合风险；类别也高度不均衡（Appendix Table 6）。
- 数据因滥用风险仅面向研究按请求提供，不是无条件公开下载（Open Science）。

## 测量框架

### 感知（Perception）

- 每张图构造成四选一问题：一个正确不安全概念加三个跨类别干扰项；共 1,567 题、8 个 VLM、12,536 个响应（§4.1）。
- 以微调 RoBERTa 将自由文本归为 A/B/C/D/N/A；240 条人工标注响应按 6:4 训练/测试。
- Perception Score 只在有效选项响应上计算；33.4% 的生成响应为 N/A 并被排除。这一口径可能抬高只看有效回答时的能力估计。

### 对齐（Alignment）

- 设计 5 个一般安全语境提示，并为视觉图像与文字概念建立对应问法；RoBERTa 将响应分为 Safe/Unsafe/N/A（§4.2、Table 1）。
- 视觉 Alignment Score 是把图像正确判为不安全的比例；文本版本是把概念文字正确判为不安全的比例；N/A 同样排除。
- 另为每个概念生成一条明确不安全语境和一条可接受安全语境，共 150 条提示，在 3 个 VLM 上做情境分析（§4.2、Table 2）。

## 核心发现与证据定位

### 发现一：多数模型能感知概念，但不一定做出对应安全判断

- LLaVA-7B、LLaVA-13B、InternLM、CogVLM、GPT-4V 的整体感知分数为 0.90–0.97；GPT-4V 为 0.97。Qwen2-VL 与两个 InstructBLIP checkpoint 为 0.45–0.61，作者归因于容易受四选一干扰（§4.1、Fig. 4）。
- 视觉对齐分数仅 0.14–0.70；多数开源 VLM 低于 0.58。文本概念对齐则为 0.81–0.95（§4.2、Fig. 5）。
- 典型例：LLaVA-7B 的感知分数 0.93，但视觉对齐只有 0.37（§1）。因此“检测到概念”不是“将其作为风险执行政策”的充分条件。

### 发现二：模态差距在一般语境下最突出

- 三个模型在一般语境下视觉/文本差距分别为 0.331、0.572、0.506；给出明确不安全情境后差距缩至 0.098、0.050、0.092（§4.2、Table 2）。
- 给出安全使用情境时模型又常过度保守，说明问题并非只要添加上下文就解决；模型对“危险化”线索比“合理使用”线索更敏感（§4.2、Table 2）。
- 高频视觉误判涉及阴谋论、骚扰、性骚扰等概念；作者观察到模型可能忽略图中冒犯文本，转而描述普通人物/物体（Fig. 6、Appendix Table 7）。训练数据缺少不安全图像是作者提出的可能解释，不是本文直接验证的因果结论。

## 简化 PPO 对齐方法

### 威胁模型与目标

- 对手利用视觉比文本更易被判安全的差距，引导 VLM 输出不当肯定或传播有害观念（§5.1）。
- 防守目标同时包括：（1）正确、具体地解释图像为何安全/不安全；（2）尽量不损害 OCR、计算、图文理解和常识等通用能力。
- 防守者需要白盒微调能力；方法不是外接内容过滤器。

### 训练流程

1. **Rollout**：从含 safe/unsafe 图像与 alignment prompt 的数据中采样，让当前 VLM 生成响应。
2. **Evaluation**：用已有 RoBERTa 响应分类器与真实标签计算交叉熵；不训练偏好 reward model。
3. **Optimization**：用 PPO 最大化分类正确奖励与长度 bonus，同时加入 entropy bonus 鼓励探索、KL 约束限制对原模型分布的偏离（§5.3、Eq. 3–4）。

长度 bonus 用来缓解“对所有不安全图都只回答 No”的 reward hacking，但“更长”等同于“更有信息”只是代理假设，仍可能被优化利用。

## 对齐实验设置

- UnsafeConcepts 8:2 划分；用等量 ImageNet-1K 图像补成 safe/unsafe 平衡训练集；测试集 690 张（各半）（§5.4）。
- 目标模型 LLaVA-7B；SFT/DPO/PPO 都用 LoRA rank 128、batch 32、4 epochs。SFT/PPO 学习率 3e-5，DPO 2e-6。
- SFT 与 DPO 的训练响应/偏好对由固定模板人工构造；因此比较也同时反映“固定模板监督”与“在线探索”的差异。
- 通用能力：MME（2.7K yes/no 题）与 LLaVABench（24 图/60 问，GPT-4o 评分）；域外安全泛化：SMID、NSFW。

## 对齐结果与贡献解释

- **SFT**：Alignment-Agg 0.977，最高；但 `1-SelfBLEU` 仅 0.076、Informativeness 1.978/5、General-Agg 0.558，显示强模板化和较大通用能力损失（Table 3）。
- **DPO**：Alignment-Agg 0.648，低于原模型 0.736；General-Agg 0.656（Table 3）。在该固定模板偏好数据设置中未显示优势，不能外推为所有 DPO 都较差。
- **PPO**：Alignment-Agg 0.903，`1-SelfBLEU` 0.221；人工 Soundness 4.659、Informativeness 4.682；General-Agg 从原模型 0.708 小幅降到 0.687（Table 3）。贡献在于**安全准确、响应信息量和通用能力的折中**，而非单项安全准确率最高。
- **域外**：PPO 在 SMID 上 Accuracy/`1-SelfBLEU` 为 0.718/0.247，在 NSFW 上为 0.996/0.106，均优于表中原模型、SFT、DPO（Table 5）。
- **消融**：熵、KL、长度 bonus 影响安全、响应质量与通用能力的平衡（Appendix Fig. 7–9），说明方法依赖奖励权重调节，并非无超参数的稳定修复。

## 优点

- 研究问题贴近真实多模态审核：同一政策对象跨图像/文本应有一致标准。
- 感知—对齐分解是重要方法学贡献，避免将视觉 encoder 失败与语言侧安全策略失败混为一谈。
- 数据、系统测量和训练修复形成完整闭环；同时报告安全与 utility，而非只追求拒答率。
- 情境分析揭示双向风险：一般/危险语境下漏检，安全语境下又可能误拒。

## 局限、失败条件与证据缺口

- **统一伦理标准过粗**：安全判断依赖文化、政策与用途；论文也承认一般语境无法涵盖细粒度情境（§7）。
- **内部标注偏差**：仅 3 位内部专家，κ=0.682；多数票不能消除共同文化或机构偏差。
- **N/A 排除口径**：感知中 33.4% 响应被排除；拒答/不确定本身是部署行为，若不单列 coverage，分数可能掩盖可用性问题。
- **感知测量受题型影响**：四选一干扰使部分模型表现低；它测的是受约束概念选择，不是开放词汇定位或完整内容理解。
- **修复只在 LLaVA-7B 上训练验证**：8 模型用于测量，但 PPO 的主实验不能证明对其他架构、闭源模型和更强 VLM 普遍有效。
- **奖励代理与 reward hacking**：RoBERTa 分类器、长度 bonus、SelfBLEU 都是代理指标，可能鼓励冗长或分类器特定措辞，而不等同于真正伦理推理。
- **基线数据构造不对称的解释风险**：SFT/DPO 使用固定模板，PPO通过在线 rollout 获得多样响应；结果支持当前设置中的折中优势，不是算法类别的普遍排序。
- **数据投毒风险**：方法依赖人定义的安全标签；翻转/污染标签可能反向扭曲模型标准（§7）。

## 与同方向工作的横向关系

- UnsafeBench 提供较粗安全类别和二元标注；本文增加 75 个概念级映射，并把它用于跨模态一致性测量。
- 与 LLaVAGuard/PerspectiveVision 等直接审核模型相比，本文的独特价值是先诊断“感知还是对齐”再修复，而非只优化最终分类。
- 与 [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-liu-sentinel.md|Sentinel]] 形成结构类比：本文是跨模态的“感知—对齐缺口”，Sentinel 是跨层的“识别—执行缺口”。两者都提醒安全失败不能由最终输出单点归因。

## 对当前研究的启发（综合判断）

1. 视觉 Token 剪枝/压缩必须分开报告：概念感知、视觉安全对齐、文本安全对齐、跨模态 gap、N/A/coverage、固定 FPR 下召回和通用任务质量。
2. 只保持 VQA 或分类精度不足以证明安全保持；压缩可能不影响“看见概念”，却破坏视觉证据到语言政策判断的桥接。
3. 候选假设：对齐训练若显式约束同一概念的图像/文本内部表征或输出一致性，可能比单独优化视觉标签更适合压缩后的安全恢复。该假设尚待实验。

## 待验证问题

- 将 N/A 计为错误或单列 coverage 后，八模型的感知和对齐排名是否变化？
- 用开放式概念识别、目标区域定位或图中文字 OCR 替代四选一后，感知—对齐差距是否仍成立？
- 在多种 VLM 与跨文化政策 taxonomy 上，PPO 的权衡能否复现？
- 视觉 token 剪枝对“感知正确但对齐错误”的样本影响最大出现在 vision encoder、projector 还是 LLM 层？
