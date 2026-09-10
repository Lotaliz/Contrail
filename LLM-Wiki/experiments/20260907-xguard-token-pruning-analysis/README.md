---
id: 20260907-xguard-token-pruning-analysis
type: experiment
title: XGuard 视觉 Token 与语言层剪枝实验复核
tags: [experiment, data, research, safety, visual-token-pruning, structured-pruning, efficient-inference]
status: active
created: 2026-09-07
updated: 2026-09-07
project_id: visual-token-pruning
---

# XGuard 视觉 Token 与语言层剪枝实验复核

> **状态：已有实验的二次分析，未重新运行模型。** 原始记录以只读副本保存于 [[LLM-Wiki/experiments/20260907-xguard-token-pruning-analysis/raw/20260907-token-prune.md]]；副本 SHA-256 为 `FCAA8D7B8198BF7A499F7216662B4271C10EDD879B7AD47EB10F7834045C276A`，与用户提供文件一致。本文中的百分比、匹配比较和研究建议为基于原始结果的派生分析，不应误写成原实验作者的结论。

## 1. 实验回答了什么

该实验使用 LoRA 微调后的 Qwen3-VL-2B-Instruct 完成 41 类安全分类和归因生成，比较了：

- 语言模型层删除与 Ghosted Layers 线性旁路恢复；
- FastV、DivPrune 和输入降分辨率三种视觉 Token 压缩；
- 仅分类首 Token、教师归因 PPL、自生成 PPL、TTFT 和长归因生成吞吐。

其价值在于同时覆盖了分类质量、生成归因和真实端到端时延，并且 FastV 已修正为单次前向的 canonical 实现。它可以作为当前“resolution-first + 失败恢复 + evidence selector”路线的 Phase A 探索证据，但数据覆盖和统计强度不足以支持安全保证。

## 2. 数据与评测边界

| 项目 | 实际设置 | 对结论的影响 |
|---|---|---|
| 训练 / 测试 / 校准 | 9,998 / 1,000 / 256（255 有效） | 测试集规模可做方向判断，校准集对 41 类偏小 |
| 类别 | 41 类；测试仅覆盖 24 类 | 17 类完全无支持，不能报告完整 41 类能力 |
| 有效长尾评测 | 仅 16 类支持数不少于 10 | overall accuracy 和全类 macro 容易被支持度结构扭曲 |
| 随机性 | 单 seed | 1–2 个百分点差异未必稳定 |
| 归因标签 | 教师模型生成 | gold PPL 主要衡量教师风格拟合，不等于人类认可或因果忠实度 |
| 时延 | H20-3e、batch=1 | 能说明单请求路径，不等价于 continuous batching 吞吐 |

完整模型在 16 个有足够支持的类别中已经有明显短板：`L=0.048`、`N=0.047`、`P=0.019`、`g=0`。因此压缩后某些类别的低召回既可能来自压缩，也可能来自基座判别器尚未学会该类。下一轮必须先建立可用的 full-path 类别下限。

## 3. 主要结果复核

### 3.1 语言层剪枝：分类可恢复，归因不可恢复

| 配置 | Accuracy | Macro | Macro（support≥20） | Gold PPL | TTFT P50 |
|---|---:|---:|---:|---:|---:|
| L28 完整模型 | 0.616 | 0.433 | 0.519 | 5.28 | 131.5 ms |
| R15 直接删除 | 0.485 | 0.278 | 0.367 | — | 124.3 ms |
| R15 Ghosted | 0.606 | 0.390 | 0.481 | 16.15 | 124.5 ms |
| R30 Ghosted | 0.460 | 0.238 | 0.340 | 33.20 | 117.8 ms |
| R45 Ghosted | 0.318 | 0.125 | 0.215 | 142.14 | 110.8 ms |

R15 Ghosted 相对完整模型仅将 TTFT 降低约 5.3%，但全类 macro 下降 4.26 个百分点，Gold PPL 增至约 3.06 倍。Ghost 旁路确实显著恢复了直接删层后的首 Token 分类，却没有恢复教师归因分布。R30/R45 的质量和无效输出率进一步恶化，不具备当前主线价值。

这说明“判定首 Token”和“长文本归因”依赖的能力并不等价。若论文关心可解释安全判别，不能用分类恢复推断解释也被恢复；Ghosted Layers 更适合作为恢复基线，而不是当前效率主线。

### 3.2 视觉压缩：输入降分辨率是最强时延基线

以下比较均使用 L28 完整语言主干：

| 方法 | 实际保留率 | Accuracy | Macro | Macro（support≥20） | TTFT P50 | 相对完整模型 |
|---|---:|---:|---:|---:|---:|---:|
| Full | 1.000 | 0.616 | 0.433 | 0.519 | 132.0 ms | — |
| FastV p25 | 0.749 | 0.615 | 0.429 | 0.512 | 121.1 ms | -8.3% |
| FastV p50 | 0.500 | 0.603 | 0.428 | 0.500 | 115.1 ms | -12.8% |
| FastV p75 | 0.249 | 0.555 | 0.388 | 0.442 | 107.7 ms | -18.4% |
| DivPrune p25 | 0.749 | 0.612 | 0.429 | 0.507 | 133.4 ms | +1.1% |
| DivPrune p50 | 0.500 | 0.603 | 0.418 | 0.501 | 123.9 ms | -6.1% |
| DivPrune p75 | 0.249 | 0.577 | 0.406 | 0.479 | 111.3 ms | -15.7% |
| Resize p25 | 0.752 | 0.602 | 0.398 | 0.506 | 101.1 ms | -23.4% |
| Resize p50 | 0.504 | 0.589 | 0.382 | 0.501 | 64.6 ms | -51.1% |
| Resize p75 | 0.250 | 0.566 | 0.378 | 0.476 | 48.2 ms | -63.5% |

三个观察最重要：

1. **FastV p25 是近乎无损的轻度压缩基线。** Accuracy 仅下降 0.1 个百分点，TTFT 降低约 8.3%；p50 则以 1.3 个百分点 accuracy 换取约 12.8% TTFT。
2. **DivPrune 的选择开销在轻剪枝时抵消了收益。** p25 比完整路径还慢约 1.1%；高剪枝率下其质量优于 FastV，但端到端优势仍远弱于 resize。因此“不依赖 attention”不等于低开销。
3. **Resize 构成当前必须击败的效率前沿。** Resize p50 的 support≥20 macro 与 FastV/DivPrune p50 几乎相同（0.501 对 0.500/0.501），TTFT 却为 64.6 ms，而后二者为 115.1/123.9 ms。

一个尤其有研究价值的匹配质量比较是：Resize p25、FastV p50 与 DivPrune p50 的 accuracy 均约为 0.602–0.603，support≥20 macro 也约为 0.500–0.506，但 Resize p25 的 TTFT 分别快约 12% 和 18%。与此同时，Resize p25 的全支持类 macro 只有 0.398，低于 FastV p50 的 0.428 和 DivPrune p50 的 0.418。这提示降分辨率对有足够样本的主流类别很有竞争力，却可能对稀有类别造成更集中的伤害。

### 3.3 结构压缩与 Token 压缩不应现在同时扩展

R15 Ghosted + FastV p50 相对 R15 基线约降低 11.5% TTFT，accuracy 仅下降 0.6 个百分点；但若与真正的 L28 完整基线比较，其 Gold PPL 约为 3.39 倍，support≥20 macro 下降 5.14 个百分点。也就是说，联合方案可能在 overall accuracy 上看起来可接受，但把长尾能力和归因退化隐藏起来。

当前应固定 L28 主干研究视觉压缩。否则一旦出现安全漏报，难以区分是语言层能力损失、视觉证据丢失还是二者交互所致。

### 3.4 长归因生成吞噬了端到端收益

完整模型 256-token 归因生成约为 0.279 requests/s，未达到原实验设定的 1 requests/s。Resize 虽显著缩短 TTFT，但 generate-call 吞吐几乎不变；FastV 的生成吞吐改善也远小于视觉 Token 数减少幅度。原因是长 decode 成为主导项。

系统接口应拆为：

1. 同步返回 `verdict/category/confidence`，优化 time-to-verdict；
2. 仅在审计、低置信度或策略要求时异步生成短归因；
3. 不把每请求 256-token 自由生成归因放在 Guard 的关键路径。

Self-PPL 在所有压缩强度下仍约为 1.8–2.3，而 Gold PPL 已从 5.28 恶化到 142.14，因此 Self-PPL 不能作为回退置信度或解释质量信号。

## 4. 对当前研究方向的更新

### 4.1 已得到支持的部分

- **Resolution-first 是必要基线。** 本实验第一次在当前 XGuard 实现上给出明确端到端证据，而不仅是 FLOPs 推断。
- **需要为降分辨率失败样本设计恢复路径。** 平均指标支持 resize，但全类 macro 的额外下降和类别级差异说明安全长尾可能需要局部高清证据。
- **选择器净开销必须进入方法目标。** DivPrune p25 的负收益和 FastV 的有限收益都证明只减少后段 Token 不足以保证端到端加速。
- **判定与归因必须分开评测。** Ghost 恢复分类而不恢复 Gold PPL，直接支持 verdict-first 和独立 evidence/attribution 契约。

### 4.2 尚未得到验证的部分

- 尚未证明 attribution stability 能预测哪一个样本会因压缩而翻转；
- 尚未建立 safe 与 unsafe 的 Token 需求非对称性，因为缺少 41 类到安全二分类、严重度和策略层级的映射；
- 尚未验证所选 Token 是因果证据，现有归因文本与 PPL 只能描述生成分布；
- 尚未证明 profile router 在考虑双跑与 fallback 后仍有净时延收益；
- 尚未验证固定 shape 的 coverage/evidence/relation selector。

因此当前论文问题应从“再设计一种通用重要性分数”收束为：

> **普通样本由低分辨率路径高效处理；对可能因小目标、OCR、空间关系或长尾策略而发生有害翻转的样本，用低开销、可审计的证据充分性信号触发局部高清或 full-token 恢复。**

这比“全面替代 FastV/DivPrune”更贴合现有证据，也更容易形成安全场景特有的贡献。

## 5. 下一步实验建议

### P0：先做无需 GPU 的逐样本配对分析

不要立即训练新 selector。先把已有条件按 `sample_id` 对齐，并新增以下派生字段：

- `full_correct`、`compressed_correct` 与四类转换：保持正确、压缩致错、压缩纠错、保持错误；
- 主要风险量 `harm_rate = P(compressed wrong | full correct)`，而不是只看 accuracy 差；
- 压缩前后类别、置信度 margin、无效输出和 Gold PPL 变化；
- 原图尺寸、长宽比、视觉 Token 数、OCR 字符密度、用户文本长度和教师归因长度；
- 标签支持度、风险严重度、safe/unsafe 和 policy family。

对总体和主要切片使用 paired bootstrap 置信区间，并对成对错误使用 McNemar exact test。重点对比：

- Resize p25 vs FastV p50 vs DivPrune p50：近似匹配质量下的时延和长尾差异；
- Resize p50 vs FastV p50：相同视觉保留量下的计算位置差异；
- L28 Full vs R15 Ghosted：分类恢复和归因失配；
- full-correct 子集中的新增错误，而不是把“压缩纠错”与“压缩致错”相互抵消。

**P0 的 Go 条件：** 能定位至少一个跨 bootstrap 稳定、样本量足够、在 resize 下 harm rate 明显升高的安全子群。若找不到，不应直接声称“安全长尾恢复”是必要方法。

### P1：小规模、可判定的确认实验

只保留四个主条件：`L28 Full`、`Resize p25`、`Resize p50`、`FastV p50`；DivPrune p50 可作为第五个机制对照。使用类别平衡测试集并保证每个论文关心的策略类有足够支持，保存首 Token logits，而不只保存类别字符串。

主指标改为：

- 固定 FPR 下 unsafe recall；
- worst-policy recall 和 false-negative severity；
- full-correct 样本的 harmful flip rate；
- ECE/选择性风险；
- vision、selector/resize、prefill、verdict decode 的 P50/P95 分项时延。

至少使用 3 个随机 seed 或对固定模型做足够样本的 paired bootstrap。若 41 类本身不对应 safe/unsafe，应先冻结类别到政策和严重度的映射，避免看到结果后再选择指标。

### P2：把 profile 简化为“低清默认 + 证据不足回退”

第一版 router 不需要预测风险类别，可使用：

- 低清路径的分类 margin、entropy 与 OOD score；
- OCR 密度、原图 Token 数、长宽比和小连通区域统计；
- 低清预测在轻微平移/缩放下的稳定性；
- 候选证据 mask 在简单增强或两档分辨率间的重合度；
- 视觉结论与用户文本/政策匹配的一致性。

以 full-path 是否纠正低清错误作为 router 标签，优化在固定 unsafe recall 或 harmful-flip 上限下的平均 TTFT。必须把 fallback 的第二次视觉编码计入总成本；如果回退率太高，低清先跑可能比直接 Full 更慢。

### P3：再验证 Evidence-Carrying Selector

在 L28 上实现固定长度 `K = Kc + Ke + Kr`：coverage slots 保全局空间，evidence slots 保留政策相关区域，relation slots 保留 OCR 邻域和对象关系。indices 随样本变化，但输出 shape 固定，并保存坐标与 merge provenance。

离线 teacher 可以比较 verdict-token gradient×activation、输入遮挡和 attention，但在线方法必须使用廉价代理。评测至少包括：selected-only、complement-only、原始像素 insertion/deletion，以及平移、缩放、局部遮挡下的 mask stability。只有这些测试通过后，才能把保留 Token 称为 evidence，而非普通 post-hoc heatmap。

### P4：延后语言层剪枝与 serving 扩展

- 暂停 R30/R45；R15 仅保留为分类恢复对照。
- 若未来重启结构剪枝，目标中同时加入 verdict margin、tail-policy loss、归因/证据损失和实测延迟，不再用单一平均梯度×权重决定整层删除。
- profile batching 和 continuous batching 只在单请求策略已经证明净收益后评估，避免过早同时解决算法和系统两个高风险问题。

## 6. 推荐决策

| 决策 | 建议 | 理由 |
|---|---|---|
| 近期主干 | L28 固定 | 排除结构剪枝与 Token 剪枝的交互混淆 |
| 默认效率基线 | Resize p25 / p50 | 当前端到端效率前沿 |
| 轻度在线剪枝基线 | FastV p25 | 近乎无损且已有约 8% TTFT 收益 |
| 复杂 selector 对照 | FastV p50、DivPrune p50 | 分别代表 attention relevance 与 diversity coverage |
| 回退信号 | margin + 输入属性 + 跨变换稳定性 | Self-PPL 已被实验否定 |
| 解释输出 | verdict-first，按需短归因 | 256-token decode 主导吞吐且生成自信不等于正确 |
| 暂停项 | R30/R45、全请求长归因、DivPrune p25 | 当前收益/风险比不足 |

## 7. 可形成的论文叙事

如果 P0/P1 证实长尾 harmful flip，推荐题目方向为 **Risk-Aware Resolution and Evidence Recovery for Multimodal Safety Guards**，核心叙事是：

1. 普通多模态 benchmark 上复杂 selector 的价值常被输入降分辨率基线高估；
2. 安全 Guard 的难点不是平均精度，而是降分辨率引发的少量、高严重度证据丢失；
3. 通过固定 shape 的 evidence coverage 和校准回退，在低回退率下逼近 resize 的时延，同时恢复 worst-policy recall；
4. 保留证据带有坐标/provenance，并通过输入空间干预验证，而不是把 attention 或生成归因直接当作解释。

在获得平衡数据、成对统计和 faithfulness 实验前，只能将其表述为候选研究方向，不能声称“安全保证”“因果解释”或“显著优于现有 Token 剪枝”。

## 关联实体与来源

- [[LLM-Wiki/research/visual-token-pruning/multimodal-safety-token-pruning-research-plan.md|多模态安全判别 Token 剪枝研究方案]]
- [[LLM-Wiki/research/safety-classifier-compression/overview.md|安全判别系统的剪枝与蒸馏]]
- [[LLM-Wiki/experiments/20260826-safety-pruning-finetuned/README.md|先前安全 Token 剪枝实验]]

