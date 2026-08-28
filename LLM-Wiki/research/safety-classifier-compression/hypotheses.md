---
id: safety-classifier-compression-hypotheses
type: synthesis
title: 安全判别剪枝与蒸馏待验证假设
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-wang-2024-p-pruning, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-ma-2023-llm-pruner, paper-an-2024-flap, paper-zhong-2025-blockpruner, paper-men-2025-shortgpt, paper-shi-2023-upop, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety]
status: draft
created: 2026-08-24
updated: 2026-08-27
---

# 待验证假设

## H1：安全梯度比通用激活更适合结构剪枝

假设：在相同实测时延预算下，以安全连续损失定义 `gradient × weight`，再用少量真实模块消融校正，比 PPL、raw gradient、通用激活或其中任一单一指标更能保持 rare-category 与 fixed-FPR recall。

验证：比较 PPL、accuracy drop、连续任务损失 drop、BI、activation norm、Wanda、FLAP、raw gradient、Taylor 与 Fisher；先报告它们和真实单模块损失的 rank correlation、top-k overlap、跨 seed 稳定性，再报告最终模型的每类召回、AUPRC、ECE 与真实时延。三级方案为 `forward proxy → Taylor/Fisher → iterative true ablation`。

## H2：学生错误驱动的数据蒸馏优于一次性教师标注

假设：HarmAug 的有害多样性与 PGKD 的 hard-negative feedback 可组合；在相同教师 token 预算下，按学生高置信错误采样比均匀生成更高效。

验证：固定教师调用量，对比随机合成、HarmAug、PGKD、二者组合，绘制 teacher cost—AUPRC—worst-group recall 曲线。

## H3：双阈值路由可减少大 Guard 使用率

假设：以“学生风险置信度 + OOD/校准置信度”共同触发回退，比只用 entropy 或单一危害概率更能降低漏报，并把大 Guard 使用率控制在 5%–15%。

验证：在跨攻击族和时间外测试集上评估 risk-coverage、回退率、总时延和大 Guard 成本。

## H4：多模态安全需要保护型 Token 预算

假设：通用 attention/token saliency 会漏掉低显著度但高风险的 OCR、小目标或跨模态否定线索；加入 OCR region、目标区域和文本条件的最低保留配额，可在相同平均 Token 数下提高安全召回。

验证：在多模态安全集上对比随机、attention、VisionZip/SmartTrim 类选择与保护型选择，并按 OCR、小目标、组合危害切片。

## H5：先剪后调适合频繁 policy 更新

假设：当 taxonomy 每月或每季度更新时，先从基础模型得到结构化小子网再做策略微调，比“全量大模型 SFT → 后剪枝 → 恢复”具有更低累计成本，且精度差距可由 Logit 蒸馏弥补。

验证：模拟多轮 taxonomy 增量，记录每轮 GPU 时、教师调用、数据重放、遗忘和最终端到端时延。

## H6：判定与归因需要不同视觉预算

假设：safe/unsafe 与 category 可用较小 token 集稳定判定，但忠实解释、帧/区域引用和复杂组合危害需要更高覆盖；“先判定、按风险扩容归因”比所有请求固定同一预算有更好的风险—时延 Pareto 前沿。

验证：共享同一 full-token teacher，对 label-only、固定短解释和证据定位解释分别扫描 pruning ratio，测 time-to-verdict、完整 E2E、fixed-FPR recall 与归因 sufficiency/comprehensiveness。

## H7：policy relevance + coverage 保护优于纯 Top-k attention

假设：在相同平均 token 数下，为每帧/事件及 OCR、小目标区域设置最低预算，再按 policy relevance 分配剩余 token，可提高 worst-group recall 和归因忠实度；对普通样本的平均准确率不显著下降。

验证：对比 random、uniform pooling、policy attention Top-k、coverage-protected Top-k 与可逆回退，按 OCR、小目标、短事件和跨模态组合危害切片。

## H8：风险条件 On-policy 蒸馏优于等预算静态 KD

假设：对会生成 `verdict → category → rationale` 的小型自回归 Guard，在保留固定红队/长尾数据的同时，把教师 token 预算集中到当前学生的高风险、错误和不确定 rollout，并提高早期判定 token 权重，会比只在教师/人工固定序列上蒸馏获得更高的 fixed-FPR 与 worst-group recall。

验证：固定学生初始化、训练 token、教师前向 token 与数据切片，对比 SFT、静态 token KD、GKD 混合、risk-conditioned GKD 和 prefix-only OPD；同时记录 ECE、类别召回、解释忠实度、学生 rollout/教师成本、time-to-verdict 和完整 P95。该假设不外推到无自回归轨迹的 encoder Guard。
