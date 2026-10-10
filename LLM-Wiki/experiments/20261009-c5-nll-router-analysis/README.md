---
id: experiment-20261009-c5-nll-router-analysis
type: experiment
title: "C5 NLL 收益 router 的初步负结果与总预算假设"
tags: [experiment, visual-token-pruning, multimodal-safety, adaptive-routing]
status: active
created: 2026-10-09
updated: 2026-10-09
---

# NLL 收益 router 初步分析

## 来源与状态

用户在 2026-10-09 的本次对话中报告：

> 将 NLL 用于构造路径收益训练 router 后，新 router 几乎放弃 50/50，主要选择 75/25 或 Global100；相比原 router，指标几乎没有差异。

这是用户报告的定性结果。本次未收到逐样本输出、路线占比、具体指标、训练配置、运行路径、种子或统计区间，未检查实现或复现。不能把“几乎无差异”写成已证明等价，也不虚构新的宏召回/时延数字。

## 既有场景

C5 固定约 5% 视觉预算，以文本政策＋128×128 预览路由 Global100 或全局＋至多一个局部框。原始汇总、Guard 恢复训练和旧 router 目标见 [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md]]。该记录中的 0.4974 宏召回与 58.90 ms 是原 C5 汇总，不是本次 NLL router 的新结果。

## 观察、解释与缺口

- 观察：新目标改变 profile 选择分布，但未报告明显总体质量改善。
- 假设：5% 下 50/50 的 global 清晰度不足，增加 local 预算的收益被全局损伤抵消，因此低 local 占比更常被选中。
- 反证/替代解释：NLL-only 目标可能偏离原漏报/错类加权代价；收益预测或归一化可能不足；旧单格框不能覆盖关系/狭长证据；Guard 对布局和分辨率的适配仍可能有限。未确认第四项安全惩罚是否保留。
- 用户已有错误分析提示全局模糊、局部选错和单格覆盖不足，但没有扩预算 oracle；总预算是合理的下一步优先假设，尚非已排除所有其他原因的结论。

## 下一步实验计划

先在 train 内独立验证/现有 dev 上测固定 5%、10%、20% 的单图 Global100 与原 C5 所选单框路线的质量—实测时延。保留成功和所有预算均失败的样本，检查高预算实际救回率与新增漏报；最终 test 不生成训练标签。

最小改动是复用现有 preview/router，增加“当前 5% 路线 vs 20% 全局”升级收益门；在线只执行最终选定的一个 Guard 输入。完整设计、混合预算 Guard 适配、共同收益基准和平均预算边界见 [[LLM-Wiki/research/visual-token-pruning/c5-adaptive-total-budget-plan.md]]。

## 环境与证据缺口

新运行的 Guard/checkpoint、代码版本、teacher 精确 NLL 口径、原目标权重保留情况、最终渲染 budget、依赖/硬件/种子均待归档。不把旧实验硬件配置自动当成本轮实测环境。本次只做方案分析，未安排或运行新 GPU 任务。

## 关联

项目：[[LLM-Wiki/research/visual-token-pruning/overview.md]]；既有固定预算设计：[[LLM-Wiki/research/visual-token-pruning/c5-single-region-policy-grounding-improvement.md]]。
