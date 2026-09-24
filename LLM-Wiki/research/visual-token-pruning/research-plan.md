---
id: policy-guided-pre-vit-pruning-research-plan
type: synthesis
title: "历史方案：视觉—政策文本相互指导的联合压缩"
tags: [research, visual-token-pruning, multimodal-safety, efficient-inference, vision-language-model]
project_id: visual-token-pruning
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch, paper-zhang-2025-cdpruner, paper-vasu-2025-fastvlm, paper-na-2026-responseguard, paper-wang-2026-safeatlas-vl, webpage-cvpr-2027-cfp, repository-safeguard-vl, model-safeguard-vl-rl, dataset-safeeditbench, repository-policyshiftguard, model-policyshiftguard-3b, dataset-policyshiftbench]
status: deprecated
created: 2026-09-21
updated: 2026-09-23
---

# 路线二：视觉—政策文本相互指导的联合压缩

> **历史方案（2026-09-22）。** 用户于 2026-09-23 将当前主线确定为“模板短政策作为背景条件、文本政策指导视觉 Token 剪枝”。新版场景、数据构造与 baseline 计划见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|新版课题方案]]。本页保留原论证、失败假设与联合压缩候选，不代表当前拟投稿方法。

## 2026-09-22 路线转向

原主线是只在首个 ViT block 前裁剪视觉 patch。当前目标 workload 中，用户报告政策文本 token 通常超过视觉 token 四倍；Dyna-ViT 式 90% pre-ViT 剪枝仅得到 1.14× 端到端加速且精度明显下降。按忽略额外选择开销的 Amdahl 反推，有效可移除视觉路径约占 13.6%，完全消除时也只有约 1.16× 上限。这与用户独立估计约 1.15× 一致。

因此，**pure visual pruning 不再作为加速论文的完整主线**；它保留为视觉证据选择模块、强基线和鲁棒性假设。当前推荐主线改为：

> 对 `(image, runtime policy)`，以廉价视觉预览检索相关政策条款，再用候选条款反向选择高风险视觉 patch，并在一至两轮轻量交互中联合分配两类 token 预算；在同图政策翻转保持、安全非劣与不确定回退约束下，降低端到端 Guard 成本。

完整三路线比较与证据边界见 [[LLM-Wiki/research/visual-token-pruning/long-policy-bottleneck-pivot-assessment.md|长政策瓶颈转向评估]]。用户报告的计时尚待原始 profiler 归档，本页不标 reproduced。

Policy-adaptive image guardrail 的操作性定义采用 [[LLM-Wiki/research/visual-token-pruning/policy-adaptive-image-guardrail-comparison.md|PolicyShiftGuard 式同图 policy flip]]，而不只依赖跨政策宏 F1；SafeEditBench 作为局部视觉近邻外部压力测试。

## 公开基座与训练边界决策

首选开发基座为 [PolicyShiftGuard-3B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-3B)：它基于 Qwen2.5-VL-3B-Instruct，已经完成 RP-SFT 与 BP-Adapt，可直接加载；Hugging Face 将完整模型计为约 4B 参数，BF16 仓库约 7.53 GB。其 [RP-SFT 中间检查点](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-3B-RP-SFT)可用于训练阶段消融。7B 版本作为 teacher 和尺度验证，不作为首个开发基座。

[SafeGuard-VL-RL](https://huggingface.co/tyodd/SafeGuard-VL-RL)作为跨方法外部基线：它是 Qwen2.5-VL-7B 级、16.6 GB BF16 完整权重，不是小模型；公开模型卡明确说明它只包含 Stage-2 GRPO，没有论文完整方案的 Stage-1 SFT，不能称为公开的 SafeGuard-VL-Full。

本路线将“无需设计数据并重新训练模型”收紧为：

- **无需重新采集或人工标注安全数据**：直接使用 PolicyShiftBench 的 RP-SFT、boundary-pair、Adaptive/Shift splits 和规则文件，以及 SafeEditBench 的现有图文政策样本；
- **无需从基座重训 Guard**：现成权重既是 full-token 基线，也是压缩教师；
- **仍允许且预计需要轻量压缩感知训练**：先只训练两侧 selector；若不够，再对 Guard 加 LoRA。完全零训练仅作为基线，不作为成功前提。

PolicyShiftBench 为非商业研究条款；SafeEditBench 为 CC BY 4.0 但需要接受 gated research access。实验发布前必须再次核对具体 LICENSE/TERMS。

## 论文命题与 CVPR 边界

文本—视觉联合剪枝并不偏离 CVPR：MADTP 已在 CVPR 2024 同时压缩视觉和语言分支；SafeEditBench/SafeGuard-VL 已在 CVPR 2026 研究运行时政策变化的图像 Guard。相应地，本路线不能声称“首次联合图文 token 剪枝”，贡献要落在已有工作没有覆盖的交叉处：

- decoder-only Guard 的**长政策主导**成本，而非 BLIP/BERT 短文本双分支；
- 保留否定、例外、作用域和优先级的**结构化政策编译**，而非任意 BPE Top-k；
- 条款与视觉证据的**协同覆盖**，而非两侧独立打分；
- 同图异策、未见政策、fixed-FPR unsafe recall 和真实冷/热路径时延。

CVPR 叙事应是“policy-conditioned visual computation under long multimodal context”，而不是通用 prompt compression。若最终方法主要是文本摘要、视觉机制弱，NeurIPS/ICLR 或 NLP venue 会更自然。

## 方法设计

### 1. Policy compiler

把完整政策按发布的规则/条款边界解析为风险类别、触发条件、允许项、否定、例外、作用域与优先级。每个条款产生短文本、embedding 或少量 latent/gist token；完整政策保留为教师输入和审计原件。固定/重复政策缓存编译结果，并区分首次出现的 cold path 与复用的 warm path。第一阶段不新造政策标签，只使用 PolicyShiftBench 已发布的规则和 bundle 字段。

### 2. 高召回条款检索

用低分辨率图像、patch projection 或廉价视觉概念与条款表示匹配。保留所有可能违规条款、全局政策摘要和否定/例外锚点；不确定、OCR、小目标和未见政策触发预算扩展或 full-policy fallback。

### 3. 视觉—政策协同选择

为避免“必须先看完整图像才能选政策、又必须先读完整政策才能选图像”的循环依赖，先缓存条款 embedding，并用低分辨率图像、patch projection 或浅层视觉 stem 得到廉价 preview。preview 先高召回检索条款；条款再指导 pre-ViT patch 选择；可选的一轮视觉摘要反向更新条款预算。该模块形成显式二部覆盖目标。pure visual Dyna-ViT/QuietPrune 式 selector 作为退化基线，不能代表完整方法。

### 4. 风险约束训练

采用三级训练预算：`training-free` 直接打分；`selector-only` 冻结 Guard、只训练条款/patch selector；`selector + LoRA` 在压缩输入上轻量适配 Guard。监督包含 full-policy/full-vision teacher 蒸馏、同图异策 boundary pair、政策释义一致性、多预算一致性、条款覆盖和 unsafe-to-safe flip 惩罚。默认优化 fixed benign FPR 下的 unsafe recall，而不是平均 token retention。

### 5. 回退与输出

低置信、政策新颖度高或证据覆盖不足时回到更大预算。Guard 输出优先使用短结构化 verdict；只有需要审计时才生成解释，避免把长 decode 混入输入压缩贡献。

## 数据计划

- LlavaGuard：固定 taxonomy 基线，不独自支撑可变政策结论。
- SafeEditBench：公开卡列出五种政策、901 张训练图、128 张测试图和 601 个 policy-conditioned 测试实例；论文另描述 62 组近邻 safe/unsafe 图像对。作为跨政策和局部证据外部评测，数量口径在使用前按下载版本核对。
- PolicyShiftBench：2,000 个评测实例、265 张图、28 个政策变体；公开包同时包含 RP-SFT、BP-Adapt boundary pairs、Adaptive/Shift split、完整 bundle 和可执行规则，作为主训练/评测骨架。
- SingGuard 动态规则：作为简短类别名与详细自然语言规则的相邻评测来源。

第一阶段不构造新安全数据集，也不新增人工 verdict。对现有完整 bundle 做条款切分、预算采样、selector target 和 full/compressed 成对视图；这些是方法训练与效率评测的派生输入，不宣称新 benchmark。不得让测试政策、同一 boundary group 或同一基础图像泄漏到 selector 训练。若现有政策长度分布不足以支持长上下文主张，再把扩展长政策列为后续条件，而不是预先扩大工程范围。

## 分阶段执行

### Phase 0：冻结模型可行性闸门

在 PolicyShiftGuard-3B 上复现 full-token Adaptive/Shift 指标和分阶段时延；实现四个无需训练的基线：vision-only、policy-only、两侧独立、单轮相互指导。若联合压缩不能明显优于简单 policy-only 压缩或 KV/prefix cache，则停止复杂 selector。

### Phase 1：只训练 selector

冻结全部 Guard 权重，用现有 RP-SFT 与 boundary-pair split 训练 policy selector 和 visual selector；full-token PolicyShiftGuard-3B 提供软标签/排序分数。目标是把新训练参数和成本限制在选择模块，同时保持 PSS、unsafe recall 和结构化输出正确率。

### Phase 2：压缩感知轻量适配

若 Phase 1 仍有系统性政策翻转或局部证据损失，对 Guard 加 LoRA，并加入 full/compressed 一致性和 boundary-pair margin。该阶段是推荐的论文方法上限；不进行从 Qwen 基座开始的完整安全对齐。

### Phase 3：架构迁移

先在同族 7B 验证尺度一致性，再选择一个不同 VLM 架构验证可迁移性。公开代码只直接示范 Qwen2.5-VL，因此跨架构训练是待验证研究假设：需要适配 processor、视觉 token hook、prompt 和输出 parser，并至少重新执行 SFT/LoRA 与 boundary-pair adaptation，不能直接搬运 Qwen 权重。

## 实验矩阵

### 强基线

- full policy + full vision；
- PolicyShiftGuard-3B、PolicyShiftGuard-3B-RP-SFT 和 Qwen2.5-VL-3B 基座；
- SafeGuard-VL-RL-7B 外部跨方法基线；
- Dyna-ViT/QuietPrune 式 pure visual pruning；
- policy KV/prefix cache；
- Gist/soft prompt 与抽取式条款选择；
- text-only 与 vision-only 压缩；
- 两侧独立选择与联合 co-selection；
- 更小分辨率/视觉骨干；
- 小型 policy encoder + visual encoder + 分类头的非生成式 Guard；
- full-token 模型上的阈值校准、class-balanced/focal loss、困难负例与随机 patch dropout。

### 质量

unsafe recall at fixed benign FPR、macro/micro F1、worst-policy/worst-category recall、Policy Shift Score、同图异策一致性、未见政策、unsafe-to-safe flip、条款召回、OCR/小目标/多区域子群。

### 效率

政策长度 × 图像分辨率二维网格；逐段记录 policy compile/retrieval、patch projection/selector、ViT、projector、LLM prefill 和 verdict decode。报告 cold/warm policy、P50/P95、吞吐、峰值显存和至少两种骨干；所有数字包含 compact/gather 与回退成本。

## “剪枝提高精度”的位置

视觉剪枝可能通过去除背景相关性改善 2B Guard，但目前只能作为 hypothesis。必须先排除阈值不当、类别不平衡、损失函数、困难负例不足和普通 dropout 正则化。只有当 policy-conditioned 视觉选择在这些对照后仍改善 policy-shift、worst-group 或 OOD 背景鲁棒性，才能成为第二贡献；平均 accuracy 上升不单独支撑主论文。

## Go / Pivot / No-Go

### Go

- 联合方案在真实长政策分布上显著超过 pure-visual 的约 1.15× 净上限，同时满足预注册安全非劣界；
- 联合 co-selection 优于视觉与政策各自独立压缩；
- 同图异策、未见政策和否定/例外不出现系统性漏报；
- 至少两个 backbone 上呈现一致的风险—时延 Pareto 改善。

### Pivot

- 若任意政策文本压缩不稳，改为“policy compiler + full-policy fallback”的摊销 Guard，而不强求每样本硬裁剪；
- 若生成式 decoder 是主要浪费，升格双塔/浅层 cross-attention 分类架构，并把 token pruning 降为组件；
- 若视觉选择只提高鲁棒性而不加速，将问题重写为 policy-conditioned evidence bottleneck，但必须有 policy-shift/OOD 因果证据。

### No-Go

- 简单 KV cache、政策摘要或更小模型达到相同前沿；
- 只在短政策数据上出现收益；
- 条款检索遗漏导致高危 unsafe recall 明显下降；
- 只减少 Token/FLOPs，没有可重复端到端收益；
- “精度提升”被校准、重加权或普通随机 dropout 完全解释。

## 与路线一的边界

本路线中的文本是运行时政策，不是与图片共同组成恶意语义的用户请求。[[LLM-Wiki/research/multimodal-compositional-safety/research-plan.md|路线一]]负责 strict `S-S-U` 攻击、专业 Guard 漏洞和防御；本路线负责政策自适应图像 Guard 的协同预算和执行成本。strict 数据可以作为压力测试，但不能重复列为主贡献。
