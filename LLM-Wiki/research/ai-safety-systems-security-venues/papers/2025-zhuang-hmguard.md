---
id: paper-note-zhuang-2025-hmguard
type: paper-note
title: "I know what you MEME! Understanding and Detecting Harmful Memes with Multimodal Large Language Models"
authors: ["Yong Zhuang", "Keyan Guo", "Juan Wang", "Yiheng Jing", "Xiaoyang Xu", "Wenzhe Yi", "Mengda Yang", "Bo Zhao", "Hongxin Hu"]
year: 2025
venue: "NDSS 2025"
source_id: paper-zhuang-2025-hmguard
project: ai-safety-systems-security-venues
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, safety-guardrail, multimodal-safety, content-moderation]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-09-08
---

# I know what you MEME! Understanding and Detecting Harmful Memes with Multimodal Large Language Models

## 书目信息

- 论文：Yong Zhuang et al., *I know what you MEME! Understanding and Detecting Harmful Memes with Multimodal Large Language Models*, NDSS 2025。
- DOI：`10.14722/ndss.2025.240415`。
- 原文：[[LLM-Wiki/raw/papers/2025-zhuang-hmguard.pdf]]；来源登记为 `paper-zhuang-2025-hmguard`。
- 本次阅读层级：`deep-read`。已核对正文、图 4–6、表 I–XI 与附录中的提示流程、标注手册和字符扰动实验；未执行代码或复现实验。

## 一句话结论

HMGUARD 的核心不是训练一个新的 meme 分类器，而是把强多模态大模型改造成一条**面向内容审核的结构化询问链**：先用领域/角色提示缩小任务空间，再依次审查表层内容、图文融合、拼接叙事、宣传手法和攻击意图。论文在两个公开测试集及一个 Pinterest 集合上报告了显著提升，但结论主要支持“结构化提示提高特定 GPT-4V 设置下的分类效果”，尚不足以证明低成本、稳定、跨语言或广义对抗鲁棒的生产部署能力。

## 任务（问题）场景

### 1. 输入、输出与使用者

- **输入**：一张互联网 meme，通常同时含图像、嵌入文字以及需要结合文化/社会背景才能理解的隐含语义。
- **输出**：二分类标签 `harmful` / `harmless`。HarMeme 中 `very harmful` 与 `somewhat harmful` 被合并为有害；FHM 的 hateful meme 被视为 harmful meme 的子集。
- **使用场景**：社交平台内容审核。用户可能有意或无意传播仇恨、暴力、歧视、侮辱等内容；检测器需要同时控制漏检与误杀。
- **任务难点**：单看文字或图像可能均无害，组合后才形成攻击；有害性也可能藏在多格叙事、反讽、暗示或修辞操纵中。

### 2. 作者先做失效测量，再定义问题

作者清洗 HarMeme 与 FHM 的测试样本，去除重复项和文字不可辨认项，得到 1,000 张 meme（532 有害、468 无害）：HarMeme 289 张，FHM 711 张（表 I，第 4 页）。测量得到三类关键障碍：

1. **多模态语义融合不足**：需要解释图像与文字如何共同表达含义。解释文本的 BERTScore F1 从 VisualBERT 的 0.47、VL-T5 的 0.45，提高到 LLaVA 的 0.79 和 GPT-4 的 0.83（表 III，第 5 页）。这说明通用 MLLM 更擅长生成接近人工解释的语义描述，但 BERTScore 只衡量文本相似性，不等同于有害性判断正确。
2. **图像构成与跨面板叙事**：拼接图占样本约 33%；既有工具在单面板 meme 上的平均 TPR 为 52.35%，在拼接图上仅 35.18%（表 IV，第 6 页）。多格顺序、因果和对比关系会改变最终含义。
3. **宣传/修辞技巧掩蔽意图**：作者用 22 类 propaganda techniques 标注修辞模式。带此类技巧的样本平均 TPR 为 38.98%，不带时为 50.77%，绝对下降 11.79 个百分点（表 V，第 7 页）。

因此，论文真正解决的问题不是普通 OCR 后分类，而是：**如何让 MLLM 显式恢复“表层元素 → 图文关系 → 构图叙事 → 修辞策略 → 攻击意图”的证据链，再据此作二分类。**

## 方法设计：HMGUARD 与 HMCOT

### 1. 总体定位

HMGUARD 是建立在 MLLM 之上的纯提示框架，主实验以 `gpt-4-vision-preview` 为基础模型。论文没有为主模型微调权重；所谓 **adaptive prompting** 指利用上下文提示做领域与任务适配，而非在线训练或参数自适应。HMCOT（Harmful Meme Chain-of-Thought）则把一次泛化提问拆成多个有依赖关系的显式问答。

```mermaid
flowchart LR
    X[图像 + 嵌入文字] --> A[领域对齐\n这是 meme 语境]
    A --> B[任务适配\n内容审核角色与危害范围]
    B --> M1[M1 表层含义]
    M1 --> M2[M2 图文融合]
    M2 --> M3[M3 构图/多格叙事]
    M3 --> M4[M4 宣传技巧]
    M4 --> M5[M5 意图验证]
    M5 --> Y[汇总中间答案\n有害 / 无害]
```

### 2. 七阶段推理流程

1. **Meme domain alignment**：先告诉模型这是 meme 语境，使其不要只做孤立图像描述。
2. **Task-specific adaptation**：把模型设定为内容审核专家，并明确关注仇恨、暴力、歧视及其他伤害。
3. **Surface Meaning Identification（M1）**：检查文字或画面本身是否直接有害；明显案例可以在这里作出判断。
4. **Fusion Meaning Identification（M2）**：询问图文是否形成显式或隐式关联，以及联合含义是否有害。这是对“单模态均无害、组合后有害”的直接处理。
5. **Composition Meaning Identification（M3）**：先判断是否为拼接/多面板图；若是，再分析面板之间的顺序、对比、因果和整体叙事。
6. **Propaganda Meaning Identification（M4）**：识别是否借助命名攻击、恐惧/偏见、loaded language、smear、transfer 等宣传技巧表达伤害。
7. **Intention Verification（M5）与最终裁决**：验证是否存在针对个人或群体的贬低、羞辱、侮辱、讽刺或诋毁意图，最后把前述中间答案一起放入终局提示，要求输出一致的二分类结论。

从实现语义上看，这里的 CoT 是**多次显式提示调用及中间文本传递**，而不是模型内部可观测、经训练获得的隐式推理结构。它的优势是诊断步骤清楚；代价是调用次数、生成 token、时延和 API 成本都可能上升，而论文未报告端到端成本。

## 实验设置

### 数据集与指标

- **FHM**：Facebook Hateful Memes，论文将 hateful 作为 harmful 的一种；清洗后测试子集 711 张。
- **HarMeme**：COVID-19 相关 harmful meme 数据；清洗后测试子集 289 张。
- **HMW（in-the-wild）**：作者用关键词从 Pinterest 获取 512 张，去重和去除模糊样本后保留 300 张，其中 102 有害、198 无害。由两名论文作者标注；先在 100 张上讨论统一，再用 50 张检查，报告最终 100% 一致，但未给 Cohen's kappa 等独立一致性统计（第 12–13 页）。
- **指标**：Accuracy、Precision、Recall、F1；类别分析另报 TPR。HMW 部分说明因类别不平衡应更重视 macro-F1，但论文对其他表格中的 F1 口径交代不够统一。

### 对比方法

MOMENTA、HateDetectron、MR.HARM、ExplainHM，以及仅使用通用提示“判定有害/无害”的 GPT-4。主方法和通用提示基线都使用 `gpt-4-vision-preview`，因此二者的差异最直接反映提示流程的价值；与训练式基线的差异则同时混入了基础模型规模、预训练知识和 API 能力差异。

## 实验效果

### 1. 公开数据集主结果

表 VI（第 10–11 页）报告：

| 数据集 | 方法 | Accuracy | Precision | Recall | F1 |
|---|---|---:|---:|---:|---:|
| FHM | 最佳基线准确率：HateDetectron | 0.69 | 0.54 | 0.73 | 0.58 |
| FHM | 通用提示 GPT-4 | 0.61 | 0.55 | 0.64 | 0.60 |
| FHM | **HMGUARD** | **0.86** | **0.88** | **0.83** | **0.85** |
| HarMeme | MR.HARM | 0.80 | 0.56 | 0.82 | 0.66 |
| HarMeme | 通用提示 GPT-4 | 0.74 | 0.72 | 0.50 | 0.69 |
| HarMeme | **HMGUARD** | **0.92** | **0.83** | **0.98** | **0.91** |

最可信的直接比较是“同一 GPT-4V + 通用单问”对“同一 GPT-4V + HMCOT”：FHM 的 Accuracy/F1 从 0.61/0.60 提升到 0.86/0.85；HarMeme 从 0.74/0.69 提升到 0.92/0.91。结果支持结构化提示显著改善此设置下的检测。

**重要数据质量警告**：表 VI 的若干 Precision、Recall、F1 三元组不满足标准调和平均关系。例如 HarMeme 上 ExplainHM 的 0.25/0.62 不可能得到 F1=0.71，GPT-4 的 0.72/0.50 通常约为 0.59 而非 0.69；HMGUARD 的 0.83/0.98 通常约为 0.90。可能原因包括宏/微平均口径混用或表格录入错误，但论文没有解释。因此 Accuracy、Recall 及作者明确报告的结果可以引用，跨方法解释 F1 时必须保留这一不一致性。

### 2. 针对三类难点的效果

HMGUARD 在单面板和拼接图上的 TPR 分别为 97.44% 与 96.88%；在带宣传技巧的样本上为 97.78%（表 VII，第 11 页）。这与作者的设计动机相符：复杂构图和修辞样本不再呈现基线中明显的性能塌陷。不过表中 `Improvement` 的计算口径未充分说明，且这些是同一数据的类别切片，不能视为独立测试集。

### 3. 自适应提示消融

表 VIII（第 12 页，HarMeme）：

| 设置 | Accuracy | F1 |
|---|---:|---:|
| HMCOT，不含两类自适应提示 | 0.85 | 0.59 |
| 去掉 meme domain alignment | 0.86 | 0.74 |
| 去掉 task-specific adaptation | 0.87 | 0.55 |
| **完整 HMCOT** | **0.92** | **0.91** |

完整方法相对完全移除自适应提示的绝对增益为 Accuracy +0.07、F1 +0.32。两个提示模块存在交互：单独移除任务适配时 F1 降得最明显，但这只是一次消融表，不能推出稳定的因果贡献排序。

### 4. 推理模块消融

表 IX（第 12 页）报告只保留自适应提示时为 0.77 Accuracy / 0.57 F1；逐一去掉 M1–M5 时分别为：M1 0.78/0.68、M2 0.78/0.61、M3 0.81/0.65、M4 0.76/0.62、M5 0.83/0.75；完整方法为 0.92/0.91。所有模块的一次性消融都低于完整系统；按表中绝对差，M4 对 Accuracy 的影响最大，M2 对 F1 的影响最大。由于没有多次运行、置信区间或模块组合消融，证据只说明“这些步骤在当前提示链中共同有用”。

### 5. 实景、可移植性与鲁棒性

- **HMW**：HMGUARD 为 0.88 Accuracy、0.83 Precision、0.89 Recall、0.86 F1；HateDetectron 为 0.70/0.53/0.52/0.51，MR.HARM 为 0.73/0.57/0.52/0.50（表 X，第 13 页）。结果显示对 Pinterest 样本有一定外推，但关键词采样、单平台和作者自标注限制了代表性。
- **迁移到开源 MLLM**：在 LLaVA-v1.6-34B 上部署该框架，HMW Accuracy 为 0.78，低于 GPT-4V 版本的 0.88，但作者称高于通用 LLaVA 与现有工具；正文未给完整指标表。
- **字符扰动**：选取 FHM 中 15 张含敏感词的有害 meme，施加增字、删字、换位、插空格四类扰动，共 60 张；HMGUARD 的 TPR 从 100% 降至 95%（表 XI，第 17 页）。这只证明对小规模、简单 OCR/NLP 字符扰动有韧性，不能泛化为图像攻击、语义改写、跨语言或自适应攻击下的整体鲁棒性。

## 作者主张、直接证据与本笔记判断

| 层级 | 内容 |
|---|---|
| 作者主张 | 自适应提示与分解式多模态推理显著提高 harmful meme detection，并能迁移到其他 MLLM。 |
| 直接证据 | 两个清洗后的公开测试集、一个 300 张 Pinterest 集合、HarMeme 消融、60 张字符扰动样本，以及 LLaVA-v1.6-34B 的 HMW Accuracy。 |
| 本笔记判断 | 证据较强地支持“结构化 prompting 优于同模型通用 prompt”；较弱地支持“普遍优于专用检测器”，因为模型容量与信息条件不对等；不支持低成本生产部署或广义鲁棒性。 |
| 待验证假设 | 公共数据可能被闭源模型预训练接触，且 `gpt-4-vision-preview` 为可变 API 版本，可能影响可复现性；论文没有做污染审计或固定快照验证。 |

## 优点

1. **设计从实证失效模式出发**：先量化融合、构图和宣传技巧三个薄弱点，再把它们逐一映射为提示模块，问题—方法对应清晰。
2. **把二分类展开为可检查的中间证据**：相比单个“有害/无害”提示，HMCOT 更容易定位模型在哪一层理解失败。
3. **同模型提示基线较有说服力**：通用 GPT-4V 与 HMGUARD 的差距隔离了部分基础模型能力混杂。
4. **覆盖了公开集、实景集、消融和简单扰动**：虽然规模有限，但比只报单一 benchmark 更完整。

## 局限与失败条件

1. **成本缺失**：一次样本需要多个串行问答，论文未报告 API 调用数的实际执行、生成 token、端到端时延、吞吐、费用或超时率。
2. **复现条件不足**：使用 `gpt-4-vision-preview`，temperature 保持默认 1；没有固定模型快照、随机种子、多次运行、方差或置信区间。论文称实验在 4 张 A100 40GiB 上进行，但没有解释该硬件对 GPT-4 API 主实验的作用。
3. **指标表内部不一致**：表 VI 的多个 F1 与 Precision/Recall 对不上，削弱精确数值比较的可信度。
4. **数据覆盖有限**：只处理英文嵌入文字；HMW 仅 300 张、来自 Pinterest 关键词检索；标注者为两名作者，未报告独立专家复核或 κ 值。
5. **鲁棒性范围很窄**：只测 15 张原图衍生的四种字符级扰动，没有覆盖图像变换、遮挡、跨模态矛盾、文化漂移、对抗性提示或规避性隐喻。
6. **二分类政策粒度有限**：没有给出可执行的危害类别、严重度、置信度或人工复核阈值，也未评估不同群体和文化语境下的公平性。
7. **可解释性不能自动等同于忠实性**：中间答案是模型生成文本，可能是事后合理化；论文未用反事实或因果干预验证这些步骤是否忠实驱动最终标签。

## 与当前研究的关联

对多模态安全 Guard 压缩/视觉 token 剪枝，HMGUARD 给出一个有用的**任务分解坐标系**：

- M1 依赖局部显式实体和文字；M2 依赖跨模态绑定；M3 依赖空间覆盖、面板顺序和关系；M4/M5 依赖抽象政策与意图推理。
- 因此不能只看总体 Accuracy 判断剪枝是否安全；应分别测各模块对应样本切片，尤其是“拼接图”和“有宣传技巧”样本的 harmful recall。
- 候选实验假设（尚未验证）：视觉 token 剪枝可能先保持 M1 的表层识别，却破坏 M2/M3 的关系证据，最终造成“看见元素但错误绑定政策”的漏检。可用 evidence-first 提示记录中间答案，再对删 token 前后做模块级翻转分析。
- HMCOT 的串行成本也提示系统路线：可将 M1 作为低成本早退阶段，仅把不确定或多面板/隐喻样本路由到完整链；但这属于本项目假设，不是论文已验证结论。

## 证据定位

| 证据 | 原文位置 |
|---|---|
| 数据清洗与 1,000 张样本构成 | §IV-A，表 I，第 4 页 |
| 既有工具总体 TPR | §IV-B，表 II，第 4–5 页 |
| 多模态语义解释比较 | §IV-C1，表 III，第 5 页 |
| 构图与宣传技巧失效分析 | §IV-C2–3，表 IV–V，第 6–7 页 |
| 自适应提示与 HMCOT 总览 | §V-A–B，图 4–5，第 8–9 页 |
| M1–M5 及最终判定 | §V-C，图 6、式 (4)–(11)，第 9–10 页 |
| 主结果与类别 TPR | §VI-C，表 VI–VII，第 10–12 页 |
| 两组消融 | §VI-D–E，表 VIII–IX，第 12 页 |
| HMW 构建和结果 | §VI-F，表 X，第 12–13 页 |
| 局限、迁移实验 | §VII，第 13 页 |
| 22 类宣传技巧、标注手册、字符扰动 | 附录 A、C、D，表 XI，第 15–18 页 |

## 待验证问题

- 表 VI 的 F1 口径或录入错误应向作者/代码核实；在未澄清前不做基于小数点后数值的模型排序。
- 论文未公开 HMW 的完整采样清单、固定 GPT-4 版本输出和多次运行统计；复现时需冻结 prompt、API 模型日期、温度、最大 token 和解析规则。
- 若用于生产审核，应补测固定 FPR 下的 harmful recall、分组公平性、人工复核负载、端到端时延/成本，以及能针对 HMCOT 中间步骤优化的自适应攻击。
