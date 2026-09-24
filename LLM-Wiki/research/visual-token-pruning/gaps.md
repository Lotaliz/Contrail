---
id: visual-token-pruning-gaps
type: synthesis
title: "长政策 Guard 的视觉—政策协同压缩缺口"
tags: [research, visual-token-pruning, multimodal-safety, efficient-inference]
project_id: visual-token-pruning
sources: [paper-cao-2024-madtp, paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, paper-mu-2023-gist-tokens, paper-gao-2026-quietprune, paper-rubab-2026-dyna-vit, paper-chen-2025-safewatch]
status: deprecated
created: 2026-09-08
updated: 2026-09-23
---

# 长政策 Guard 的视觉—政策协同压缩缺口

> **历史问题清单。** 本页对应 2026-09-22 的联合压缩路线；当前研究问题、短政策数据构造及 baseline 协议见 [[LLM-Wiki/research/visual-token-pruning/policy-conditioned-visual-pruning-research-plan.md|新版课题方案]]。下列问题与停止条件作为可复用背景保留。

以下是有限调研后仍值得实验验证的问题，不是“全领域首次”的断言。

## G0：长政策主导时，联合预算能否突破 pure-visual 的端到端上限

用户报告政策 token 通常超过视觉 token 四倍，90% pre-ViT 剪枝仅有 1.14× 加速。MADTP 证明联合视觉/语言 token 剪枝存在，但其短文本双分支架构没有解决长政策 decoder-only Guard。

**可证伪问题：** 政策条款编译/检索与视觉 patch 协同选择，是否在 fixed-FPR unsafe recall 非劣时，显著超过 pure-visual 约 1.15× 的净收益上限；是否优于两侧独立压缩和简单 KV cache？

**停止条件：** 简单政策摘要、prefix cache 或更小模型达到相同前沿；联合选择只在短政策上有效；条款遗漏造成系统性高危漏报。

## G0.5：政策压缩能否保持否定、例外与未见规则

Gist token 证明提示可被压缩，但通用任务质量不能保证安全政策语义。政策中的否定、白名单、作用域和优先级可能由极少 token 决定。

**可证伪问题：** 条款级编译是否在同图 pass/block 翻转、政策释义、未见政策和例外增删上保持判定；可审计的抽取式表示是否优于黑盒 soft prompt？

**停止条件：** 只有见过的模板可压缩，或必须保留接近完整政策才能维持条款召回。

## G1：政策语义能否在首个 ViT block 前可靠定位视觉证据

Dyna-ViT 说明纯视觉 pre-encoder saliency 可行，QuietPrune 说明 query-guided early pruning 有效；但 raw/patch-projected token 缺少全局语义，复杂政策可能无法在这一位置可靠匹配。

**可证伪问题：** 在相同 Token 预算下，policy-conditioned pre-ViT scorer 是否稳定优于 policy-blind saliency、uniform grid 和 policy-adapted QuietPrune；优势是否在未见政策和同图换政策上保留？

**停止条件：** 政策条件增益在 text-shuffle 后仍存在，或必须先运行多个 ViT block 才出现，则严格 pre-ViT 主张失败。

## G2：早剪是否删除低显著度高风险证据

安全证据可能是小字、角落物体、低对比度细节或跨区域关系。一般视觉显著性和 Top-K 容易偏向主体。

**可证伪问题：** 全局底图/空间覆盖与政策相关性联合选择，是否比纯 Top-K 在 OCR、小目标和多区域子群上减少 unsafe-to-safe flip？

**停止条件：** 需要保留接近全量 patch 才维持这些子群，或统一提高分辨率即可匹配，则方法缺少有效压缩区间。

## G3：可变政策是否是真需求而非固定 class prompt

如果数据中政策几乎固定，selector 可能只学类别先验。SafeWatch 已证明自定义政策场景存在，但图像 Guard 需要独立验证。

**可证伪问题：** 同一图像在政策增删、释义、白名单和例外条款下，选择区域与 verdict 是否随语义合理变化；对未见政策是否优于固定类别 prompt？

**停止条件：** 去掉政策文本、只输入 policy ID 或类别名称即可达到相同结果，则“可变政策”贡献不成立。

## G4：selector 总成本是否吃掉 ViT 节省

越早选择越可能节省更多 ViT 计算，但政策编码、patch scorer、Top-K、gather 和不规则 shape 都有成本。

**可证伪问题：** 在同硬件、同 batch、同精度和同输出协议下，计入 cached/uncached policy 两种路径后，方法是否改善 end-to-end time-to-verdict 和 P95，而不只是 FLOPs？

**停止条件：** 真实加速只在 batch 1 或单一分辨率出现，或 selector 占掉大部分收益，则降级为方法诊断。

## G5：剪枝适配收益与新增安全数据收益如何分离

SafeWatch 表明 pruning-aware training 很重要；新数据本身也会提高 Guard。若不控制，无法知道收益来自 selector 还是更多监督。

**可证伪问题：** full-token SFT、policy-blind selector、policy-conditioned selector 和各自 KD/反事实训练在同数据、同算力下的交互是什么？

**停止条件：** full-token SFT 获得全部质量提升，selector 只带来与普通 resize 相同的速度收益，则方法贡献不足。

## G6：安全质量能否以非劣而非平均精度定义

平均 accuracy/F1 可能掩盖高危类别漏报。路线目标是轻量 Guard，因此必须约束 fixed-FPR recall、worst policy 和 legacy benchmark。

**可证伪问题：** 在测试前设定质量非劣 margin 后，方法能否在至少两种骨干上形成优于现有基线的风险—时延 Pareto 前沿？

**停止条件：** 加速必须依赖显著降低 unsafe recall、提高 benign FPR 或删除困难政策，论文不能声称 safety-preserving。

## 优先级

1. **先做 G0 + G0.5：** 用真实 policy-length 分布、cache 基线和小规模同图异策验证联合压缩是否值得继续。
2. **再做 G4 + G1：** 将 pre-ViT selector 作为联合系统的视觉子模块，测净收益和政策条件选择。
3. **再做 G3 + G5：** 用同图异策和同数据消融证明政策编译、协同选择与新增训练数据的独立贡献。
4. **最后做 G2 + G6：** 扩充高风险子群、两骨干、非劣统计和完整 Pareto 评测。
