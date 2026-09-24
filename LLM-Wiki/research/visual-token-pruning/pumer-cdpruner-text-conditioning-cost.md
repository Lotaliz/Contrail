---
id: synthesis-pumer-cdpruner-text-conditioning-cost
type: synthesis
title: "PuMer 与 CDPruner：图文关联成本、性能保护与安全判别迁移边界"
tags: [research, vision-language-model, visual-token-pruning, efficient-inference]
status: active
project_id: visual-token-pruning
sources: [paper-cao-2023-pumer, paper-zhang-2025-cdpruner, code-pumer-2026-audit, code-cdpruner-2026-audit]
created: 2026-09-18
updated: 2026-09-24
---

# 图文条件剪枝并不只有一种成本结构

## 范围与证据

用户指定两篇精读，不扩展成全面 SOTA 调研。原始证据集中于 [[LLM-Wiki/research/visual-token-pruning/papers/2023-cao-pumer.md|PuMer]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]] 的原文和固定 revision 只读实现审查；未运行模型。来源事实、个人复杂度推导和 Guard 候选启发分开，不建立正式研究缺口或 Motivation。

## 任务、位置与成本对应

| 维度 | PuMer | CDPruner |
|---|---|---|
| 原任务/模型 | ViLT/METER 图文检索、VQA 类别预测、蕴含/两图推理 | LLaVA/Qwen/InternVL 的生成式问答；视频与多轮对话 |
| 剪枝位置 | 跨模态 encoder 内，先执行一些融合再级联 reduction | 完整视觉塔/projector 后，LLM 入口前 |
| 图文关联 | 复用已有融合层的 attention 图文子块 | aligned embedding cosine；CLIP 文本塔或 LLM input embedding 均值 |
| 额外工作 | attention 聚合、top-k、同模态二分图匹配、平均聚合/compact | 文本表示、图文 cosine、视觉 Gram 核、DPP 增量选择、compact |
| 降开销手段 | 无独立 learned scorer；复用 attention/keys，匹配可并行 | 不取 LLM attention；Cholesky 增量；公开 LLaVA 双 stream 和 crop 分组 |
| 性能保护 | 文本条件 + 合并 + 温和级联 + 压缩路径微调/输出蒸馏 | 指令相关性 + 集合全局多样性；无微调或信息回灌 |
| 关键限制 | 已付早层融合成本；现代 fused attention 权重不一定免费 | 文本塔和核不免费；完整视觉塔未缩短；已有压缩主干较脆弱 |

这不是“训练版与免训练版的同一个算法”：PuMer 使用已上下文化的图文交互作为选择信息，CDPruner 用进入 LLM 前的对齐表示代理关联。前者保留后续计算空间，后者避免为选择先运行 LLM，但承担额外表示与集合优化成本。

## 额外开销如何评价

个人成本模型：

$$
T_{\rm net\ gain}=T_{\rm downstream,full}-T_{\rm downstream,compact}-T_{\rm extra}.
$$

固定共同组件仍要计入 E2E，只是在相对差中可能抵消。$T_{\rm extra}$ 应包括文本编码/评分、attention 提取、kernel、选择/匹配、同步和真实 compact，不能只计函数内张量算术。

PuMer 的图文权重已经存在于其论文宿主 forward，重用可避免新增模型，但 matching 的跨组矩阵和排序仍新增。若现代宿主只提供融合 attention 输出，不输出 $A$，权重提取本身可能引入代价。METER 完整视觉塔不变；作者明确视觉塔占主导的模型中 E2E 加速有限。

CDPruner 一个选择组的 cosine relevance 约 $O(ND)$，Gram 核约 $O(N^2D)$，greedy 更新 $O(NK^2)$，并不是整体全流程只有最后一项。公开 NeXT 以 crop 为组，不能按全图 token 数直接套单组核大小；视频原文按每帧 quota 报告，但本轮未审核其实际 adapter。CUDA stream 可以重叠 CLIP 图文编码，但不能抹去显存、资源竞争和同步。

计时证据边界不同：PuMer 测各模型最优可用 batch 的 30 秒吞吐，相同 batch 只用于显存；CDPruner 在 A100/POPE 上测短回答 prefill/decode，DPP <10ms 未明确覆盖文本塔和全流程。不能从其速度数字直接排序安全 Guard 的 batch=1 时延。

## 性能结果不能脱离压缩与训练条件

PuMer 表 1：METER VQA 77.5→76.8、1.82× throughput；ViLT VQA 69.5→68.9、1.76×。其“不到 1%”应理解为这些设置下不到一个绝对百分点，且是压缩路径训练后的结果。无蒸馏 68.6、完整 PuMer 68.9，同为 1.76×；这支持蒸馏恢复 0.3pp，不等于完整信息恢复。无 TIP/MAM 的消融同时改变压缩率，不能只比较 accuracy。

CDPruner 表 1–4：LLaVA / 32 保留作者聚合性能 94.3%，NeXT / 160 为 96%；Qwen / 128 为 85.2%，其 ChartQA 86.1→59.2、OCRBench 863→632。它依靠选择质量而非训练适应，强压缩仍有明显任务损失。附录 balance factor 可调优，但逐任务 best 不是一个统一零调参策略；多轮平均保留率也不保证任意未来问题可回答。

复现证据缺口：当前 CDPruner 固定公开版本 `llava_arch.py:159` 对 cosine 取负再 min-max，与原文正 relevance 方向不一致；当前版本是否用于论文成绩未知。不能静默纠正代码然后仍称 release-as-is 复现，也不能据此否定所有作者表格。PuMer 默认 VQA 配置支持 output KL，不启用 feature MSE；仓库包含实验/弃用分支，应从宿主调用判断主路径。

## 对安全判别项目的候选启发

1. **场景更像 PuMer，执行结构更像 CDPruner 的目标主干。** Guard 的短标签/类别判定不像长回答生成，但 Qwen-VL 在 ViT 早层没有 PuMer 的 native 图文融合 attention。不能直接假定有免费的政策条件分数。
2. **训练适应可以借用，但不能只复制平均目标。** 在训练中让浅层/压缩前缀承担相同政策判别，并用完整教师输出/证据约束；效果仍需验证。普通 KL 也可能模仿教师偏差，不能替代尾部风险约束。
3. **与攻击文本不相关不等于与安全无关。** 文本条件可能把隐藏局部证据引导到背景；考虑文本相关证据、独立政策证据与多样性/空间覆盖的联合保留。合并还可能抹平小风险区域，文本合并可能影响否定或政策条件，均是待验证风险。
4. **固定少量政策可缓存表示是优化候选，不是论文已实现功能。** 若 query 由可变用户文本决定，仍需在线表示；更重要的是测 shallow 特征与政策 embedding 的实际对齐，不能把同维度 cosine 当语义证明。
5. **先测净收益，再优化复杂 selector。** 固定 batch、设备、图像尺寸和回答长度，分项记录 vision/text/scoring/kernel/select/compact/prefill/decode/E2E；在固定 FNR/召回约束下比较相同预算。短输出 Guard 不能依赖长 decode 来摊薄额外成本。

本轮（2026-09-18）只新增证据与候选启发，未修改当时的主方案、Motivation、gap 或已有实验输出；上述历史方案现已清理。
