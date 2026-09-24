---
id: multimodal-compositional-safety-landscape
type: synthesis
title: 图文联合内容风险：数据集、攻击与防御版图
tags: [research, multimodal-safety, safety-alignment, safety-guardrail, safety-evaluation, vision-language-model]
project_id: multimodal-compositional-safety
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-zhou-2024-multimodal-situational-safety, paper-kiela-2020-hateful-memes, paper-singguard-team-2026-singguard, paper-zong-2024-vlguard, paper-zhang-2024-spa-vl, paper-chakraborty-2024-cross-modal-safety, paper-gou-2024-ecso, paper-shayegani-2023-jailbreak-pieces, paper-lee-2025-elite, paper-liu-2025-guardreasoner-vl, paper-chi-2024-llama-guard-vision, paper-huang-2025-llavashield, paper-wang-2026-safeatlas-vl]
status: active
created: 2026-09-20
updated: 2026-09-20
---

# 图文联合内容风险：数据集、攻击与防御版图

## 1. 问题谱系

### 1.1 内容审核先例：联合语义分类

2020 年 Hateful Memes 已用 benign confounders 强迫模型不能只依赖图片或文字快捷特征。它证明图文组合内容审核是一个独立难题，但任务是静态二分类，不涉及生成模型是否应拒答、是否能安全帮助，也没有把所有正例都形式化为 `S-S-U`。

### 1.2 多模态越狱：跨模态攻击面

2023—2024 年大量工作把有害指令放进图像、利用 OCR/排版或优化视觉 embedding。*Jailbreak in Pieces* 的图片对人看似无害，但经过攻击优化后在模型表征中接近毒性目标。这一谱系证明模态桥接会破坏语言模型已有对齐，却与自然语义的 `S-S-U` 不同：攻击成分本身已承载有害表征。

### 1.3 严格组合安全：safe + safe -> unsafe

SIUO 首次把独立安全模态的联合风险明确命名，并用人工与 AI 辅助两种方式构造。MSTS 用 40 个危险类别和模板化指代构造更可控的联合语义，并同时测试任务模型、文本等价提示和安全分类器。VLSU 将图、文、组合分别标为 safe/borderline/unsafe，覆盖 17 种可行组合，能够区分单模态误判和真正的组合失败。SingGuard-Bench 进一步将 strict hidden intent 纳入专用 Guard 训练与评测。

### 1.4 情境与时序扩展

MSSBench 使同一活动在安全与危险视觉情境间翻转，强调物理环境和行动后果；MMDS/LLaVAShield 把隐蔽意图和风险累积扩展到多轮、多图对话。这些任务与 `S-S-U` 共用组合推理机制，但单张危险环境图片未必符合严格的“图片政策安全”，因此应作为近邻而非混入核心统计。

## 2. 数据集构造与攻击方法

### 2.1 人工情景设计

- **SIUO 人工集：** 从安全类别出发设想跨模态危险情景，再检索日常图片并编写只有联合后才显露风险的文本。167 条主测试样本经团队一致审核。
- **MSTS：** 对 40 个危险叶类各编写 5 个基础案例，每个案例使用唯一图片和文本片段，再套用 “Should I …?” 与 “I am going to …” 两种模板形成 400 条提示。优点是可控、可解释；缺点是句式人工且规模小。
- **Hateful Memes：** 为有害梗图加入单模态相似但标签相反的 benign confounders，系统性破除文本或图片快捷特征。

### 2.2 AI 辅助生成与过滤

- **SIUO AI 辅助集：** 从 Open Images/EgoShots 的安全图片出发，模型假设潜在危险事件；随后去除文字中与图片重复的信息、补齐联合推理链，用 text-only judge 排除单独有害文本，最后人工筛选。2,000 张图片最终留下 102 条，说明严格构造并不容易。
- **SingGuard-Bench：** 从政策风险意图出发，把必要线索拆到图像和文本，使两者单独不足、联合构成违规；再用多模型过滤。论文还混合普通有害组合、图像安全和动态政策样本，因此公开的 56,340 总规模不能等同于 strict 子集规模。
- **ELITE：** 重新筛除既有 benchmark 的低毒性或歧义样本，并覆盖更多安全/不安全图文组合；适合做广义评测，但 strict 组合并非其唯一目标。

### 2.3 配对反事实与情境翻转

- **MSSBench：** 先生成安全活动，再为同一活动分别检索安全与危险视觉情境，检查模型能否只因情境变化而改变建议。
- **VLSU：** 显式参数化 $(y_I,y_T,y_{I\oplus T})$，比只给联合标签更能诊断捷径；同时加入 borderline 减少“全拒绝”获得高分的可能。
- **推荐增强：** 每个 strict 样本至少配一个共享图片的安全文本和一个共享文本的安全图片；组合标签翻转应由人工重标，而不是简单打乱后沿用旧标签。

### 2.4 表征空间组合攻击

*Jailbreak in Pieces* 将图片优化到毒性 embedding 并搭配泛化文本。它适合衡量视觉编码器和 projector 的鲁棒性，但不能证明自然图片与自然文本单独在政策语义上都安全。研究设计应把“人类语义安全”“单模态 Guard 判安全”“模型内部表征安全”作为三种不同属性。

## 3. 任务模型对齐防御

### 3.1 多模态安全 SFT

VLGuard 表明在视觉指令微调中加入安全样本可修复语言模型对齐遗忘，并降低一般黑盒攻击成功率。它是重要基线，但其训练组合主要覆盖安全交互、危险文本请求和危险图文内容；没有单独证明 strict `S-S-U` 已被修复。最直接的增强是把三标签 strict 样本与安全配对反事实加入 SFT，并同时监督“拒答理由”和“安全替代建议”。

### 3.2 偏好对齐与安全 RL

SPA-VL 提供 100,788 个 `(question, image, chosen, rejected)` 四元组，可用于 DPO/PPO 式偏好对齐。该路线优化最终行为，适合在保持帮助性的同时压低有害回答，但若偏好数据仍可由单模态快捷特征区分，不能保证获得组合推理。训练与评测需报告 strict 子集，且 chosen/rejected 应共同基于图文关系而非拒答模板。

### 3.3 跨模态迁移与遗忘

*Cross-Modal Safety Alignment* 用文本 unlearning 抑制多种视觉越狱，说明语言主干的安全边界可以跨模态迁移，成本低于额外多模态 unlearning。但所用攻击多为 OCR、生成图或视觉嵌入有害内容；它尚未证明语言侧遗忘能学会自然 `S-S-U` 关系。

### 3.4 推理时防御

- **ECSO：** 将可疑图片转换成文字，再利用已对齐语言模型判断和回答。优势是训练免费；风险是 caption 丢掉空间关系、指代或隐含意图，正是 strict 组合所依赖的信息。
- **结构化安全推理：** VLSU 上结构化思维链对部分模型改善约 8–9 个 F1 点，但强模型收益很小，最好结果仍远低于人类；推理提示不是充分修复。
- **多代理分解：** MSSBench 将视觉理解、显式安全和情境推理分工，可改善结果，但也增加成本、误差传播和 judge 依赖。
- **安全奖励/受控解码：** 可在生成时惩罚有害续写，但 reward model 若没有识别组合风险，解码控制会继承同一盲点。

## 4. 安全判别防御

### 4.1 原生多模态 Guard

Llama Guard 3 Vision、LlavaGuard、GuardReasoner-VL、LLaVAShield、SafeAtlas-VL 和 SingGuard 代表从二分类到政策条件化、从直接标签到显式推理、从单轮到多轮的演进。关键设计不是“Guard 看得到图片”这么简单，而是：

- 输入目标明确区分 image、query、response 和完整交互；
- 同时读取图像、请求、回复和当前政策；
- 对风险类别、证据关系和最终标签做一致监督；
- 为 benign-sensitive 与 strict hidden-intent 构造对称 hard negatives；
- 低置信样本进入慢推理或人工复核。

### 4.2 判别器的直接失败证据

MSTS 将 4,000 条任务模型回复交给 8 种自动分类器。最好的 Gemini-1.5 宏 F1 为 0.79，但 unsafe precision 仅 0.53；Llama Guard 3 Vision、LlavaGuard 和 Omni Moderation 的 unsafe recall 分别为 0.20、0.05 和 0.10。该实验说明部署后审核会漏掉图文语境中的有害协助，也可能出现高假阳性。

这一结果不能直接解释为“输入 Guard 因两种单模态安全而下降”，因为被审核对象包含任务模型回复，且论文没有对同一 Guard 做完整的 image-only、text-only 与 joint 输入对照。VLSU 的三路输入实验更接近该因果问题，但其被测对象主要是通用 VLM 而非专用生产 Guard。

### 4.3 专用 strict Guard 的最新进展

SingGuard 用约 60 万多模态训练样本覆盖不同模态极性，并显式合成两模态单独无害、组合有害的跨模态攻击。其自建 benchmark 的 attack split 上，SingGuard-2B/8B 报告 unsafe F1 0.9164/0.9046；对比的 GuardReasoner-VL 为 0.5071、Llama Guard 4 为 0.7795、LLaVAShield 为 0.7348。该结果表明数据定向训练很有潜力，但需保留三项限制：

1. 这是 2026 年 arXiv v1，尚缺独立复验。
2. strict hidden-intent 样本量没有从 13,677 条多模态样本中单独披露。
3. 训练和评测都含合成/自动过滤流程，可能存在生成器风格或政策词表同源性。

## 5. 推荐的攻防闭环

$$
\text{三标签构造}\rightarrow\text{反事实验证}\rightarrow\text{任务模型对齐}\rightarrow\text{输入 Guard}\rightarrow\text{任务模型}\rightarrow\text{输出 Guard}\rightarrow\text{人工复核}
$$

每个环节都应保留同一个样本 ID 和政策版本，使错误能归因到感知、联合理解、政策推理、生成还是后置审核。只报告最终“拦截/未拦截”无法区分这些机制。

