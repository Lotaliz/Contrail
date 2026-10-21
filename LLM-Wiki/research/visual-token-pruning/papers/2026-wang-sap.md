---
id: note-2026-wang-sap
type: paper-note
title: "Understanding and Mitigating Token-Pruning-Induced Vulnerabilities in VLMs"
tags: [paper-note, research, visual-token-pruning, multimodal-safety, jailbreak-defense, safety-evaluation, efficient-inference]
source_id: paper-wang-2026-sap
reading_level: deep-read
verification: source-checked
status: active
created: 2026-09-08
updated: 2026-10-20
---

# Understanding and Mitigating Token-Pruning-Induced Vulnerabilities in VLMs

## 2026-10-10：原文精读与证据升级

用户再次将本文选为 selected。本次获得 [arXiv 2610.09703v1](https://arxiv.org/abs/2610.09703v1) 完整正文，原件见 [HTML 原文](https://arxiv.org/html/2610.09703v1)，论文为 CC BY 4.0；作者仓库 MIT 仅适用于代码。复用 `paper-wang-2026-sap`，保留下面的早期仓库略读记录，本文升级为 deep-read / source-checked。精读 §3–6、图3–7、表1–15、附录A–G/I；未运行模型或攻击，也未独立核验会议接收状态。

### 机制、威胁模型与干预

§3.1–3.4：defender白盒可访问内部表征，attacker黑盒且不知道剪枝/SAP。在视觉token子空间定义恶意能量 $S$、背景buffer能量 $N$，恶意密度为 $S/(S+N)$；utility排序若偏向保留恶意foreground而删除background，softmax再归一化可能放大恶意影响。这是作者机制模型，不证明每张图背景都安全。

§4三阶段，免训练但需模型内部修改：MAI把指令token到视觉token的平均attention乘上与safe vector的cosine偏离，取top-m锚点。safe vector由通用“安全准确回答”指令在各层的hidden state一次计算、跨样本复用，**不是运行时政策表示或有害区域真值**。BTR从原drop集合均匀采样k个token，与keep集合的最低importance k个交换；最终序列长度保持不变，而非额外增加背景预算。均匀恢复没有逐token良性认证。

AR在每个decode step、所有层、逐head修改post-softmax attention：锚点权重乘$(1-\lambda)$，取出的质量均匀加给restored集合，其他不动，然后才与value聚合。无需重算softmax不等于无需暴露/修改attention权重；fused kernel和服务部署仍需另核验。正文未完整交代每种pruner在各层恢复token的hidden state/KV维护协议，不能推断被删token免费拥有当前层KV。

§6.1：LLaVA-1.5-7B，RTX4090，默认75% pruning，m=10、lambda=0.6、交换keep集合的10%；main greedy温度0/seed42，utility四任务。不是pre-ViT预算、分辨率分配或独立Guard训练。

### 结果、评价协议与数字更正

表1调查八个压缩器，table2的SAP主评测附加于TRIM/HiPrune/PruMerge/FasterVLM/FitPrune五个方法。Original三安全任务平均ASR54.01，TRIM62.33；SAP后50.19，**下降12.14个百分点、相对19.5%**；utility63.84→63.45。随机75%剪枝ASR52.73并非证明随机剪枝在所有任务都安全；LLaVA-Mini等query compressor的backbone/训练和极端保留率也与同一冻结pruner不同。

表4的“最高下降62%”来自 **SAP†图文扩展**，FasterVLM的MM-Safety72.02→10.32：按表中数值为61.70个百分点、相对下降约85.7%，不能当视觉SAP平均降低62%，也不能称普遍免疫。图文扩展的完整utility对应结果未在该表提供。

附录A：MM-Safety由GPT-4o-mini按13scenario判Safe/Unsafe/Refusal；FigStep先refusal关键词再由GPT-4o-mini判执行；JailBreakV由Llama-Guard按16hazard类别判断。ASR衡量被保护生成模型输出，不是本项目unsafe recall、FPR或同图policy flip。附录F，5seed greedy/sampling的ASR标准差≤0.7个百分点，包含BTR与judge随机性，未覆盖adaptive attacker。

### 消融、理论强度与局限

表5，BTR单独MM-Safety65.87→63.89，AR单独53.57但MMBench66.92→63.23；合并52.78/67.27，支持恢复与reallocation互补。表6，m升至30时MMBench59.02，过度抑制有代价。附录E全层、逐head好于只浅层/深层或head平均；附录B前景移除降低ASR、背景移除提高ASR，附录C关联attention entropy，温度干预图5提供更直接机制证据。

**阅读判断：** §5的“support变小必使entropy下降”和“attention集中必使output KL上升”不是无条件数学结论；对一般子集条件化，entropy不必单调，而输出KL还需模型映射假设。mixture entropy凹性可以成立，但不足以单独推出安全保证或KL上界。附录D使用“比值的期望≈期望的比值”，是近似而非普遍恒等式；本文实验证据不能被写成任意模型定理。

附录I承认adaptive攻击未评测、>95%压缩可能挤掉重要foreground；作者关于攻击组合成本的讨论没有替代实际自适应攻击测试。未覆盖多backbone、政策翻转或known-clean误拒/独立Guard阈值。safe方向可能混同任务相关内容与危险性，属于待验证风险。

### 部署成本与当前研究边界

表8，原始94.29ms/8.79T/14.66GB，TRIM55.90ms/2.22T/14.51GB，SAP57.19ms/2.22T/14.53GB；SAP相对TRIM增加1.29ms（约2.3%）。论文没有充分说明这些毫秒是否TTFT、固定输出长度、batch、同步与重复统计，不能据此直接认定E2E延迟或fused serving收益。表3的外部LLaVAGuard160.09ms是另一流程，不能用于本项目Guard自身速度排名。

关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-yan-fata.md|FATA]]、[[LLM-Wiki/research/visual-token-pruning/comparison.md]] 和 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|旧Cx方案（历史方案，已删除）]]。SAP修复生成模型在decode中的拒答，Cx分配政策条件视觉证据；对检测Guard，抑制危险证据可能反而漏报。此为项目假设，不能由本文ASR直接证实。早期记录中的“课题空白”只作当时判断，不由单篇全文证明当前新颖性。

TODO：固定长度/预算的随机背景交换对照、clean refusal、跨政策selector干预、不同pruner的层级KV恢复、完整前处理/attention修改计时与adaptive攻击。本轮不新增concept、不更新正式motivation。

## 历史记录：2026-09 仓库略读（以下为当时证据）

来源：[作者官方代码仓库与论文说明](https://github.com/liongliong/SAP)；仓库标注 ICML 2026；本轮阅读公开摘要、机制和结果说明，未获得论文正文链接、未运行代码。

## 方法与直接证据

作者研究多模态 jailbreak 下 token pruning 对生成模型安全性的影响，提出 Pruning-Induced Malicious Amplification：背景 token 被移除后，注意力可能集中到少量恶意前景锚点。推理期 SAP 识别恶意锚点、恢复部分良性 token 并重分配注意力。官方仓库称覆盖五种剪枝方法、三项安全和四项 utility benchmark，并报告攻击成功率最高下降 62%。

## 与本课题的边界

“安全感知 token 剪枝”与“压缩导致特有安全行为”已经有更直接先例，故安全分支不能只做一次攻击迁移或按危险性改 score。SAP 面向被保护生成模型的 jailbreak/拒答，且是推理期修复；本课题可保留的空白是独立 Guard 检测、输入分辨率与视觉深度共同压缩、固定 FPR 下的漏报，以及训练后跨未知压缩状态的泛化。会议状态暂仅依据作者官方仓库登记。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]。
